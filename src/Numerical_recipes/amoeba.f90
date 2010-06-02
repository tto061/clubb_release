! $Id: num_rec.f90,v 1.1 2008-07-24 17:31:45 dschanen Exp $
!   From _Numerical Recipes in Fortran 90_
!   (C) 1988-1996 Numerical Recipes Software
SUBROUTINE amoeba( p, y, f_tol, func, iter )
USE nrtype
USE nrutil, ONLY : assert_eq, imaxloc, iminloc, nrerror, swap

IMPLICIT NONE

INTEGER(I4B), INTENT(OUT) :: iter
REAL(SP), INTENT(IN)      :: f_tol
REAL(SP), DIMENSION(:), INTENT(INOUT)   :: y
REAL(SP), DIMENSION(:,:), INTENT(INOUT) :: p
INTERFACE
  FUNCTION func(x)
  USE nrtype
  IMPLICIT NONE
  REAL(SP), DIMENSION(:), INTENT(IN) :: x
  REAL(SP) :: func
  END FUNCTION func
END INTERFACE

INTEGER(I4B), PARAMETER :: ITMAX = 5000
REAL(SP), PARAMETER     :: TINY  = 1.0e-10
INTEGER(I4B)            :: ihi, ndim

REAL(SP), DIMENSION(size( p, 2 )) :: psum

call amoeba_private

RETURN

CONTAINS
!BL
SUBROUTINE amoeba_private
IMPLICIT NONE

INTEGER(I4B) :: i,ilo,inhi
REAL(SP)     :: r_tol,ysave,ytry,ytmp

ndim    = assert_eq( size(p,2), size(p,1)-1, size(y)-1, 'amoeba' )
iter    = 0
psum(:) = sum( p(:,:), dim = 1 )

do
  ilo    = iminloc( y(:) )
  ihi    = imaxloc( y(:) )
  ytmp   = y(ihi)
  y(ihi) = y(ilo)
  inhi   = imaxloc( y(:) )
  y(ihi) = ytmp
  r_tol   = 2.0_sp * abs( y(ihi) - y(ilo) ) /       &
           ( abs( y(ihi) ) + abs( y(ilo) ) + TINY )
  if (r_tol < f_tol) then
    call swap( y(1), y(ilo) )
    call swap( p(1,:), p(ilo,:) )
    RETURN
  end if
!  if (iter >= ITMAX) call nrerror('ITMAX exceeded in amoeba')
! Make amoeba return the non-optimal result. -dschanen 6/14/2005
  if (iter >= ITMAX) then  
    print *, 'ITMAX exceeded in amoeba' 
    RETURN
  endif
  ytry = amotry( -1.0_sp )
  iter = iter + 1
  if (ytry <= y(ilo)) then
    ytry = amotry( 2.0_sp )
    iter = iter + 1
  else if (ytry >= y(inhi)) then
    ysave = y(ihi)
    ytry  = amotry( 0.5_sp )
    iter  = iter + 1
    if (ytry >= ysave) then
      p(:,:) = 0.5_sp * (p(:, :) + spread( p(ilo, :), 1, size(p, 1) ))
      do i=1, ndim+1
        if (i /= ilo) y(i) = func( p(i, :) )
      end do
      iter    = iter + ndim
      psum(:) = sum( p(:, :), dim=1 )
    end if
  end if
end do

RETURN
END SUBROUTINE amoeba_private
!BL
FUNCTION amotry(fac)
IMPLICIT NONE

REAL(SP), INTENT(IN) :: fac
REAL(SP)             :: amotry
REAL(SP)             :: fac1, fac2, ytry

REAL(SP), DIMENSION(size(p,2)) :: ptry

fac1    = (1.0_sp - fac) / ndim
fac2    = fac1 - fac
ptry(:) = psum(:) * fac1 - p(ihi,:) * fac2
ytry    = func( ptry )

if (ytry < y(ihi)) then
  y(ihi)   = ytry
  psum(:)  = psum(:) - p(ihi,:) + ptry(:)
  p(ihi,:) = ptry(:)
end if

amotry = ytry

RETURN
END FUNCTION amotry

END SUBROUTINE amoeba
