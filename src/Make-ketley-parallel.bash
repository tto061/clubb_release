#-----------------------------------------------------------------------
# $Id: Make-ketley-parallel.bash,v 1.3 2007-09-14 18:17:19 faschinj Exp $
#!/bin/bash

# This script is designed to make HOC simple 
# to compile in parallel on ketley.
#
#
# Created 24 August 2007
#
# Joshua Fasching

USEAGE="sh Make_ketley_parallel (-t|-h)"


if [ $# -lt 1 ] ; then
       gmake -j8
else
       case "$1" in
          -t)time gmake -j8 -s
             ;;
           -h)echo "$USEAGE" ;;
            *)echo "$USEAGE" ;;
        esac
fi

