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

F_USAGE='Usage: $0 -b|--build --clean -d blddir -h|home rootdir -p|--prebuild -s svndir -u|--update -n|--numproc numProcs -v|--verbose -a|--addon addon -t|--target bld_target'

F_BINDIR=$(dirname $(readlink -f $(which $0)))
F_HOME=$(readlink -f "$F_BINDIR/..")

if [ -n "$OPENSIM" ]; then
    F_HOME=$OPENSIM
fi

# Set up the default parameters
F_UPDATE='no'
F_BUILD='no'
F_PREBUILD='no'
F_BLDDIR='bld'
if [ `uname` == 'Linux' ]; then
    F_TARGET='Release'
else
    F_TARGET='build-release'
fi

F_VERBOSE=''
F_CLEAN='no'

F_BUILDTOOL='nant'
if [ -n "$OPENSIMBUILDTOOL" ]; then
    F_BUILDTOOL=$OPENSIMBUILDTOOL
fi

F_ADDONDIR=''
if [ -n "$OPENSIMADDONDIR" ]; then
    F_ADDONDIR=$OPENSIMADDONDIR
fi

F_GITDIR='opensim-git'
if [ -n "$OPENSIMSOURCEDIR" ]; then
    F_GITDIR=$OPENSIMSOURCEDIR
fi

F_NUMPROC=1
if [ -n "$NUMBER_OF_PROCESSORS" ] ; then
    F_NUMPROC=$NUMBER_OF_PROCESSORS
fi

# -----------------------------------------------------------------
# Process command line arguments
# -----------------------------------------------------------------
TEMP=`getopt -o a:bd:h:n:ps:t:uv --long addon:,branch:,build,clean,help,home:,numproc:,prebuild,target:,update,verbose \
     -n 'update-bld.sh' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"
while true ; do
    case "$1" in
        -a|--addon) F_ADDONDIR+="$2 " ; shift 2 ;;
	-b|--build) F_BUILD='yes'; F_PREBUILD='yes' ; shift;;
        --branch) F_BRANCH=$2 ; shift 2 ;;
	--clean) F_CLEAN='yes'; shift;;
	-d) F_BLDDIR=$2 ; shift 2 ;;
        --help) echo $F_USAGE ; exit 1 ;;
	-h|--home) F_HOME=$2 ; shift 2 ;; 
	-p|--prebuild) F_PREBUILD='yes' ; shift ;;
	-s) F_GITDIR=$2 ; shift 2 ;; 
	-t|--target) F_TARGET=$2 ; shift 2 ;;
	-u|--update) F_UPDATE='yes' ; shift ;;
	-n|--numproc) F_NUMPROC=$2 ; shift 2 ;;
	-v|--verbose) F_VERBOSE='--verbose' ; shift ;; 
	--) shift ; break ;;
	*) echo "Internal error!" ; exit 1 ;;
    esac
done

# -----------------------------------------------------------------
# Test the directories first
# -----------------------------------------------------------------
if [ ! -d "$F_HOME" ]; then
    echo "Unable to locate OpenSim home; $F_HOME"
    exit 1
fi

if [ ! -d "$F_HOME/$F_GITDIR" ]; then
    echo "Unable to locate git directory; $F_HOME/$F_GITDIR"
    exit 1
fi

if [ ! -d "$F_HOME/$F_BLDDIR" ]; then
    echo "Unable to locate build directory; $F_HOME/$F_BLDDIR"
    exit 1
fi


# -----------------------------------------------------------------
# Update the source tree
# -----------------------------------------------------------------
cd "$F_HOME"
cd "$F_GITDIR"
if [ "$F_UPDATE" == "yes" ]; then
    git fetch --all --force --prune

    if [ "$F_BRANCH" != "" ]; then
        git checkout --force "$F_BRANCH"
    fi

    git pull
fi

# -----------------------------------------------------------------
# Grab the version information
# -----------------------------------------------------------------
F_GITVERSION=`git log -n 1 --pretty='format:%h: %ci'`

# -----------------------------------------------------------------
# Clean the old directory
# -----------------------------------------------------------------
if [ $F_CLEAN == 'yes' ] ; then
    rm -rf $F_HOME/$F_BLDDIR
    mkdir -p $F_HOME/$F_BLDDIR
fi

# -----------------------------------------------------------------
# Sync the build directory and the source directory
# -----------------------------------------------------------------
# Exclude source code control
EXCLUDES="--exclude=.git"

# Assets and inventory are customized, don't overwrite
EXCLUDES+=" --exclude=assets"
EXCLUDES+=" --exclude=inventory"

cd $F_HOME
echo rsync --archive $EXCLUDES --delete $F_GITDIR/ $F_BLDDIR/
rsync $F_VERBOSE --archive $EXCLUDES --delete $F_GITDIR/ $F_BLDDIR/

if [ -n "$F_ADDONDIR" ]; then
    for addondir in $F_ADDONDIR; do
        if [ -d "$addondir" ]; then
            echo rsync $F_VERBOSE --archive $EXCLUDES $addondir/ $F_BLDDIR/addon-modules
            rsync $F_VERBOSE --archive $EXCLUDES $addondir/ $F_BLDDIR/addon-modules
        fi
    done
fi

# -----------------------------------------------------------------
# Write the Git version
# -----------------------------------------------------------------
cd $F_HOME
cd $F_BLDDIR/bin
echo $F_GITVERSION > .version

# -----------------------------------------------------------------
# Apply any patches that are necessary
# -----------------------------------------------------------------
# Not done yet

# -----------------------------------------------------------------
# Run pre-build
# -----------------------------------------------------------------
if [ $F_PREBUILD == 'yes' ] ; then
    cd $F_HOME/$F_BLDDIR

    if [ `uname` == 'Linux' ]; then
        ### ./runprebuild.sh vs2010
	mono bin/Prebuild.exe /target nant
	mono bin/Prebuild.exe /target vs2010
    else
        # the git repository permissions for this are wrong
        ##chmod 755 ./runprebuild2010.bat
	##./runprebuild2010.bat
        bin/Prebuild.exe /target nant
        bin/Prebuild.exe /target vs2010

        F_REGPATH='\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSBuild\ToolsVersions\4.0\MSBuildToolsPath'
        F_MSBUILDPATH="$(regtool get $F_REGPATH)" 
        if [ -z "$F_MSBUILD" ]; then
            F_MSBUILDPATH="C:\\WINDOWS\\Microsoft.NET\\Framework\\v4.0.30319"
        fi
        F_MSBUILD="$(cygpath -w $F_MSBUILDPATH\\msbuild)"

        # there might be an issue here if the path to msbuild contains spaces, can use the
        # dos path instead of the windows path
        rm -f compileRelease.bat compileDebug.bat
        echo "$F_MSBUILD" OpenSim.sln /maxcpucount:$F_NUMPROC '/property:Configuration=Release' \
            > compileRelease.bat
        echo "$F_MSBUILD" OpenSim.sln /maxcpucount:$F_NUMPROC '/property:Configuration=Debug' \
            > compileDebug.bat
        chmod 755 compileRelease.bat compileDebug.bat

    fi
fi


# -----------------------------------------------------------------
# And Build It
# NOTE: this appears to fail in strange ways; weird things like
# sync'ing the file system seem to make it work
# -----------------------------------------------------------------
if [ $F_BUILD == 'yes' ] ; then
    if [ `uname` == 'Linux' ]; then
        # this is really ugly but seems to fix the problems (at times)
	cd $F_HOME/$F_BLDDIR/.nant; sync; sleep 5
	cd $F_HOME/$F_BLDDIR
        if [ $F_BUILDTOOL == 'xbuild' ] ; then
            xbuild /property:Configuration=$F_TARGET /verbosity:quiet
        elif [ $F_BUILDTOOL == 'nant' ] ; then
            nant $F_TARGET
        else
            echo 'Unknown build tool'
            exit
        fi
    else
	cd $F_HOME/$F_BLDDIR

        if [ $F_TARGET == 'build-release' ]; then
            ./compileRelease.bat
        else
	    ./compileDebug.bat
        fi
    fi
fi




