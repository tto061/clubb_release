#!/bin/bash
# $Id$
# ------------------------------------------------------------------------------
#
# Compilation script for CLUBB. It generates:
#  - libraries: libclubb_bugsrad.a, libclubb_param.a, libclubb_coamps.a
#  - executables: clubb_standalone clubb_tuner jacobian int2txt
#      clubb_inputfields
#
# Sub-makefiles for each target are automatically generated using the 
# 'mkmf' utility. Dependencies among source files are sorted out by 'mkmf'. 
# A master makefile is generated that invokes all sub-makefiles.
#
# Machine specific settings are included through a configuration
# file located under config/
#
# This script also depends on external files containing a list of source 
# files to be included in each target, which we need to maintain manually:
# - file_list/bugsrad_files : files needed for libclubb_bugsrad.a
# - file_list/param_files : files needed for libclubb_param.a
# - file_list/model_files : files needed for clubb_standalone, clubb_tuner, 
#                           clubb_inputfields, and jacobian
# - file_list/clubb_standalone_files : files needed for clubb_standalone
# - file_list/clubb_inputfields_files : files needed for clubb_inputfields
# - file_list/clubb_tuner_files : files needed for clubb_tuner
# - file_list/jacobian_files : files needed for jacobian
# - file_list/int2txt_files : files needed for int2txt
#
# The following files are automatically generated by the script based on 
# the directories in src:
# - file_list/coamps_files : files needed for libclubb_coamps.a
# - file_list/numerical_recipes_files : Numerical Recipes files for clubb_tuner
# - file_list/clubb_optional_files: Code in the UNRELEASED_CODE blocks of clubb
# These three file lists can be empty if Numerical Recipes or COAMPS 
# microphysics is not available due to licensing restrictions.
# ------------------------------------------------------------------------------

if [ -z $1 ]; then
	# Set using the default config flags

	CONFIG=./config/linux_ia32_g95_optimize.bash
#	CONFIG=/home/cjg/clubb/clubb_dev/scripts/config/gfdl_wks.bash
#	CONFIG=./config/darwin_powerpc_g95.bash
#	CONFIG=./config/linux_ia32_pg.bash
#	CONFIG=./config/linux_ia32_absoft.bash
#	CONFIG=./config/linux_ia32_g95_debug.bash
#	CONFIG=./config/linux_ia32_ss12_debug.bash
#	CONFIG=./config/linux_ia32_ss12_optimize.bash
#	CONFIG=./config/linux_ia32_ifort.bash
#	CONFIG=./config/linux_ia32_gfortran.bash
#	CONFIG=./config/linux_ia64_ifort.bash
#	CONFIG=./config/osf1_alpha_digital.bash
#	CONFIG=./config/solaris_generic_ss12.bash
else
	# Set config based on the first argument given to compile.bash

	CONFIG=$1
fi

# Load desired configuration file

source $CONFIG

# ------------------------------------------------------------------------------
# Append preprocessor flags and libraries as needed

if [ -e $srcdir/COAMPS_micro ]; then
	CPPFLAGS="${CPPFLAGS} -DCOAMPS_MICRO"
	LDFLAGS="${LDFLAGS} -lclubb_coamps"
	COAMPS_LIB="libclubb_coamps.a"
fi
if [ -e $srcdir/Numerical_recipes ]; then
	CPPFLAGS="${CPPFLAGS} -DTUNER"
fi
if [ -e $srcdir/Benchmark_cases/unreleased_cases ]; then
	CPPFLAGS="${CPPFLAGS} -DUNRELEASED_CODE"
fi

# ------------------------------------------------------------------------------
# Required libraries + platform specific libraries from LDFLAGS
LDFLAGS="-L$libdir -lclubb_param -lclubb_bugsrad -lclubb_morrison $LDFLAGS"

# ------------------------------------------------------------------------------
# Generate template for makefile generating tool 'mkmf'


cd $bindir
cat > mkmf_template << EOF
# mkmf_template needed my 'mkmf' and generated by 'compile.bash'
# Edit 'compile.bash' to customize.

FC = ${FC}
LD = ${LD}
CPPFLAGS = ${CPPFLAGS}
FFLAGS = ${FFLAGS}
LDFLAGS = ${LDFLAGS}
EOF
cd $dir

# ------------------------------------------------------------------------------
# Generate file lists
# It would be nice to generate file lists for clubb_standalone / clubb_tuner 
# dynamically, but this not possible without some major re-factoring of 
# the CLUBB the source directories.

# ------------------------------------------------------------------------------
#  Determine which restricted files are in the source directory and make a list
ls $srcdir/Benchmark_cases/unreleased_cases/*.F90 > $dir/file_list/clubb_optional_files
ls $srcdir/CLUBB_core/*.F90 > $dir/file_list/clubb_param_files
ls $srcdir/Latin_hypercube/*.?90 >> $dir/file_list/clubb_param_files
ls $srcdir/COAMPS_micro/*.F > $dir/file_list/clubb_coamps_files
ls $srcdir/Numerical_recipes/*.f90 > $dir/file_list/numerical_recipes_files

# ------------------------------------------------------------------------------
# Generate makefiles using 'mkmf'
# Note: I have done a maleficium thing and put ${WARNINGS} as a preprocessor
# flag when in reality it has nothing to do with preprocessing.  This is because
# 3rd party code from ACM TOMS and Numerical recipes has a .f90 extension and we
# don't want use the warning flags on code we didn't write.  The consequence of
# this is that if we add a new file that has a .f90 extension 
# the warning flags will not be used on that file.  -dschanen 29 Jan 2009

cd $objdir
$mkmf -t $bindir/mkmf_template -p $libdir/libclubb_param.a -m Make.clubb_param \
  -o "${WARNINGS}" $clubb_param_mods $dir/file_list/clubb_param_files

$mkmf -t $bindir/mkmf_template \
  -p $libdir/libclubb_bugsrad.a -m Make.clubb_bugsrad $dir/file_list/clubb_bugsrad_files

$mkmf -t $bindir/mkmf_template \
  -p $libdir/libclubb_coamps.a -m Make.clubb_coamps $dir/file_list/clubb_coamps_files

$mkmf -t $bindir/mkmf_template \
  -p $libdir/libclubb_morrison.a -m Make.clubb_morrison -o "-DCLUBB" $dir/file_list/clubb_morrison_files

$mkmf -t $bindir/mkmf_template -p $bindir/clubb_standalone \
  -m Make.clubb_standalone -c "${WARNINGS}" $clubb_standalone_mods \
  $dir/file_list/clubb_standalone_files $dir/file_list/clubb_optional_files \
  $dir/file_list/clubb_model_files

$mkmf -t $bindir/mkmf_template -p $bindir/clubb_inputfields \
  -m Make.clubb_inputfields -c "${WARNINGS}" $dir/file_list/clubb_inputfields_files \
  $dir/file_list/clubb_optional_files $dir/file_list/clubb_model_files

$mkmf -t $bindir/mkmf_template -p $bindir/clubb_tuner \
  -m Make.clubb_tuner -c "${WARNINGS}" $dir/file_list/clubb_tuner_files \
  $dir/file_list/clubb_optional_files $dir/file_list/clubb_model_files \
  $dir/file_list/numerical_recipes_files

$mkmf -t $bindir/mkmf_template -p $bindir/jacobian \
  -m Make.jacobian -c "${WARNINGS}" $dir/file_list/jacobian_files \
  $dir/file_list/clubb_optional_files $dir/file_list/clubb_model_files

$mkmf -t $bindir/mkmf_template -p $bindir/int2txt -m Make.int2txt \
  -o "${WARNINGS}" $dir/file_list/int2txt_files

cd $dir

# ------------------------------------------------------------------------------
# Generate master makefile
# CLUBB generates libraries.  The dependencies between such libraries must
# be handled manually.

cd $bindir
cat > Makefile << EOF
# Master makefile for CLUBB generated by 'compile.bash'
# Edit 'compile.bash' to customize.

all:	libclubb_param.a libclubb_bugsrad.a clubb_standalone clubb_tuner \
	jacobian clubb_inputfields int2txt
	perl ../utilities/CLUBBStandardsCheck.pl ../src/*.F90
	perl ../utilities/CLUBBStandardsCheck.pl ../src/CLUBB_core/*.F90
	perl ../utilities/CLUBBStandardsCheck.pl ../src/Benchmark_cases/*.F90
	-perl ../utilities/CLUBBStandardsCheck.pl ../src/Benchmark_cases/unreleased_cases/*.F90
	-perl ../utilities/CLUBBStandardsCheck.pl ../src/Latin_hypercube/*.F90

libclubb_param.a:
	cd $objdir; $gmake -f Make.clubb_param

libclubb_bugsrad.a: libclubb_param.a
	cd $objdir; $gmake -f Make.clubb_bugsrad

libclubb_coamps.a:
	cd $objdir; $gmake -f Make.clubb_coamps

libclubb_morrison.a: libclubb_param.a
	cd $objdir; $gmake -f Make.clubb_morrison

clubb_standalone: libclubb_bugsrad.a libclubb_param.a $COAMPS_LIB libclubb_morrison.a
	-rm -f $bindir/clubb_standalone
	cd $objdir; $gmake -f Make.clubb_standalone

clubb_tuner: libclubb_bugsrad.a libclubb_param.a $COAMPS_LIB libclubb_morrison.a
	-rm -f $bindir/clubb_tuner
	cd $objdir; $gmake -f Make.clubb_tuner

clubb_inputfields: libclubb_bugsrad.a libclubb_param.a $COAMPS_LIB libclubb_morrison.a
	-rm -f $bindir/clubb_inputfields
	cd $objdir; $gmake -f Make.clubb_inputfields

jacobian: libclubb_bugsrad.a libclubb_param.a $COAMPS_LIB libclubb_morrison.a
	-rm -f $bindir/jacobian
	cd $objdir; $gmake -f Make.jacobian

int2txt: libclubb_bugsrad.a libclubb_param.a $COAMPS_LIB libclubb_morrison.a
	-rm -rf $bindir/int2txt
	cd $objdir; $gmake -f Make.int2txt

clean:
	-rm -f $objdir/*.o $objdir/*.mod
	
distclean:
	-rm -f $objdir/*.o $objdir/*.mod $objdir/Make.* \
        $libdir/lib* \
        $bindir/clubb_standalone \
        $bindir/clubb_inputfields \
        $bindir/clubb_tuner \
        $bindir/int2txt \
        $bindir/jacobian \
        $bindir/mkmf_template \
        $bindir/Makefile \

EOF
cd $dir

# ------------------------------------------------------------------------------
# Invoke master makefile

cd $bindir
$gmake
# Get the exit status of the gmake command
exit_status=${?}
cd $dir

# Exit returing the result of the make
exit $exit_status
