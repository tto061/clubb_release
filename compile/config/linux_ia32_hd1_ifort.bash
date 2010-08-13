# $Id$
# Makefile definitions customized for Linux x86_64 using the Intel Fortran 
# compiler 


# Fortran 95 compiler and linker
FC=ifort
LD=ifort

# Define path to directories
dir=`pwd` # dir where this script resides
bindir="$dir/../bin"  # dir for Makefile and executable
objdir="$dir/../obj"  # dir for *.o and *.mod files
libdir="$dir/../lib"  # dir for *.a library files
srcdir="$dir/../src"  # dir where the source files reside

DEBUG="-g -traceback -check bounds -check uninit"

# == Warnings ==
WARNINGS="-warn -warn notruncated_source"

# == Machine specific options ==
ARCH="-fp-model precise" # This should work on carson/steele (AMD Opteron)
#ARCH="-mssse3 -fp-model precise"# Core2 Duo (overlie)

# == Optimization ==
OPTIMIZE="-O3 -vec-report0"

# == NetCDF Location ==
NETCDF="/sharedapps/LS/vlarson_group/local/netcdf-intel64/"

# == LAPACK libraries ==
# Intel Math Kernel Library (v10.1)
MKLPATH="/sharedapps/uwm/common/intel-fortran-compiler/11.1.072-v1/mkl/lib/em64t"


LAPACK="-L$MKLPATH -Wl,-rpath,$MKLPATH -lmkl_intel_lp64 -lmkl_sequential -lmkl_lapack -lmkl_solver_lp64 -lmkl_core -lguide -lpthread"

# == Linking Flags ==
# Use -s to strip (no debugging); 
# Use -L<library path> -l<lib> to link in an external library
LDFLAGS="-L$NETCDF/lib -lnetcdf $LAPACK"

FFLAGS="$ARCH $DEBUG"

# Preprocessing Directives:
#   -DNETCDF enables netCDF output
#   -Dradoffline and -Dnooverlap (see bugsrad documentation)
#   -DMKL enables MKL solver (PARDISO/GMRES) support
# You will need to `make clean' if you change these
# Use -I<include path> to set a module or header file directory
# Define include directories. 
# Need location of include and *.mod files for the netcdf library

CPPFLAGS="-DNETCDF -I$MKLPATH/../../include -I$NETCDF/include -Dnooverlap -Dradoffline -DMKL"

# == Static library processing ==
AR=ar
ARFLAGS=cru
RANLIB=ranlib

# == Shared library processing ==
SHARED=$FC
SHAREDFLAGS="-fPIC -shared"

# Location of 'mkmf' utility
mkmf=$dir/mkmf

# gmake command to use and options: '-j 2' enables parallel compilation
gmake="make"
