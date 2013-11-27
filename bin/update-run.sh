#!/bin/bash

# Copyright (c) Intel Corporation
# All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# -- Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# -- Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# -- Neither the name of the Intel Corporation nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE INTEL OR ITS
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

F_USAGE='Usage: $0 -d blddir -h rootdir -v|--verbose --32 destdir1 destdir2 ...'

F_HOME='/home/opensim/'
if [ -n "$OPENSIM" ]; then
    F_HOME=$OPENSIM
else
    echo "OPENSIM not set; using $F_HOME as root"
fi

# Set up the default parameters
F_VERBOSE=''
F_BLDDIR='bld'
F_IMAGE=OpenSim.exe
F_CLEAN=no

# -----------------------------------------------------------------
# Process command line arguments
# -----------------------------------------------------------------
TEMP=`getopt -o cd:h:v --long clean,home,help,verbose,32 \
     -n 'update-bld.sh' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"
while true ; do
    case "$1" in
        --help) echo $F_USAGE ; exit 1 ;;
        -c|--clean) F_CLEAN='yes' ; shift 1 ;;
	-d) F_BLDDIR=$2 ; shift 2 ;;
	-h|--home) F_HOME=$2 ; shift 2 ;; 
	-v|--verbose) F_VERBOSE='--verbose' ; shift ;; 
	--32) F_IMAGE='OpenSim.32BitLaunch.exe'; shift ;;
	--) shift ; break ;;
	*) echo "Internal error!" ; exit 1 ;;
    esac
done

# -----------------------------------------------------------------
# Deploy into each of the run directories
# -----------------------------------------------------------------

EXCLUDES=""
EXCLUDES+=" --exclude=OpenSim.exe.config"
EXCLUDES+=" --exclude=OpenSim.32BitLaunch.exe.config"
EXCLUDES+=" --exclude=OpenSimDefaults.ini"

DONTCLEAN=""
DONTCLEAN+=" -not -name Regions"
DONTCLEAN+=" -not -wholename */Regions/*"
DONTCLEAN+=" -not -name OpenSim.exe.config"
DONTCLEAN+=" -not -name OpenSim.32BitLaunch.exe.config"
DONTCLEAN+=" -not -name OpenSimDefaults.ini"

# Loop through the directories in the command line
for DESTDIR in $@ ; do
    BASENAME="$(basename $DESTDIR)"

    # clean out the old stuff first, keep configuration information
    if [ "$F_CLEAN" == "yes" ]; then
	echo Clean $DESTDIR in $F_HOME
	find $F_HOME/$DESTDIR -depth -not -name "$BASENAME" $DONTCLEAN -delete
    fi
        
    echo Updating $DESTDIR in $F_HOME
    cd $F_HOME

    rsync $F_VERBOSE --archive --link-dest=$F_HOME/$F_BLDDIR/bin $EXCLUDES $F_BLDDIR/bin/ $DESTDIR/

    # for some reason cygwin causes windows apps to dislike the dll permissions
    chmod 755 $F_HOME/$DESTDIR/*.dll

    # Create the symbolic link shortcut (helpful for starting later)
    rm -f "$F_HOME/$DESTDIR/$BASENAME"
    ln -s $F_HOME/$DESTDIR/$F_IMAGE "$F_HOME/$DESTDIR/$BASENAME"
done
