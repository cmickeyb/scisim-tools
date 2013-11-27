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

# -----------------------------------------------------------------
# This script generates the OpenSim.ini, OpenSim.exe.config, and Regions.ini
# files for all of the simulators in a plaza. It assumes that configuration
# files for the estate are in $F_HOME/$F_CFGDIR which defaults to
# /home/opensim/scisim-conf-git
# -----------------------------------------------------------------

F_USAGE='Usage: $0 -b -c cfgdir -f inifile -h rootdir -p proxy -v|--verbose plaza'

F_HOME='/home/opensim/'
if [ -n "$OPENSIM" ]; then
    F_HOME=$OPENSIM
else
    echo "OPENSIM not set; using $F_HOME as root"
fi

# Set up the default parameters
F_VERBOSE=''
F_LOGLEVEL='WARN'
F_INIFILE='OpenSimDefaults.ini'
F_BLDFLAG='no'
F_CLEANFLAG='no'
F_HOSTNAME="$(hostname)"
if [ -n "$OPENSIMCONFHOST" ]; then
    F_HOSTNAME=$OPENSIMCONFHOST
fi

F_CONFDIR='etc'
if [ -n "$OPENSIMCONFDIR" ]; then
    F_CONFDIR=$OPENSIMCONFDIR
fi

F_PROXY=''
if [ -n "$OPENSIMPROXY" ]; then
    F_PROXY=$OPENSIMPROXY
fi

# -----------------------------------------------------------------
# Process command line arguments
# -----------------------------------------------------------------
TEMP=`getopt -o bc:f:h:p:v --long build,clean,config:,file:,home:,help,host:,loglevel:,proxy:,verbose \
     -n 'update-cfg.sh' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"
while true ; do
    case "$1" in
        --help) echo $F_USAGE ; exit 1 ;;
	-b|--build) F_BLDFLAG=yes ; shift 1 ;;
        --clean) F_CLEANFLAG=yes; F_BLDFLAG=yes; shift 1 ;;
	-c|--config) F_CONFDIR=$2 ; shift 2 ;;
	-f|--file) F_INIFILE=$2 ; shift 2 ;; 
	-h|--home) F_HOME=$2 ; shift 2 ;; 
        --host) F_HOSTNAME=$2 ; shift 2 ;;
        --loglevel) F_LOGLEVEL=$2 ; shift 2 ;;
	-p|--proxy) F_PROXY=$2 ; shift 2 ;; 
	-v|--verbose) F_VERBOSE='--verbose' ; shift ;; 
	--) shift ; break ;;
	*) echo "Internal error!" ; exit 1 ;;
    esac
done

if [[ $F_CONFDIR == /* ]] ; then
    CONFROOT=$F_CONFDIR
else
    CONFROOT=$F_HOME/$F_CONFDIR
fi

ECONFDIR=$CONFROOT/plaza/
RCONFDIR=$CONFROOT/region/
SCONFDIR=$CONFROOT/simulator/

# -----------------------------------------------------------------
# Define some functions for cross-platform operation
# -----------------------------------------------------------------
export PLATFORM=`uname -o`
function SafePath()
{
    if [ $PLATFORM == 'Cygwin' ]; then
        cygpath -m $1
    else
        echo $1
    fi
}

function SafeExe()
{
    if [ $PLATFORM != 'Cygwin' ]; then
        echo $1
        return 0
    fi

    # must use the short path version to avoid
    # the ' ' in many windows paths
    newPath=$(cygpath -sm "$(which $1).exe")
    echo "$newPath"
}

# -----------------------------------------------------------------
# Configure each of the plazas
# -----------------------------------------------------------------
for PLAZA in $@ ; do
    echo Updating $PLAZA in $F_HOME

    if [ -e $ECONFDIR/$PLAZA.inc ]; then
        if [ "$F_CLEANFLAG" == "yes" ]; then
            rm -rf $F_HOME/plaza.$PLAZA
        fi

	SIMS=`cat $ECONFDIR/$PLAZA.inc`
	for SIM in $SIMS ; do
            # supports the host name conventions for simulators
            if [[ "$SIM" =~ (.*)@(.*) ]]; then
                SIM="${BASH_REMATCH[1]}"
                SIMHOST="${BASH_REMATCH[2]}"
		if [ `echo $SIMHOST | tr [:upper:] [:lower:]` != `echo $F_HOSTNAME | tr [:upper:] [:lower:]` ]; then
                    continue
                fi
            fi

	    SROOT=$F_HOME/plaza.$PLAZA/run.$SIM

	    if [ "$F_BLDFLAG" == "yes" ]; then
		mkdir -p $SROOT/Regions
	    fi

	    if [ -d $SROOT ]; then
		echo Configure simulator $PLAZA:$SIM

		rm -f $SROOT/Regions/Regions.ini
		"$(SafeExe php)" "$(SafePath $OPENSIM/bin/conf-region.php)" \
                    -r "$(SafePath $RCONFDIR/$PLAZA.inc)" -s $SIM \
		    > $SROOT/Regions/Regions.ini

		rm -f $SROOT/$F_INIFILE
		"$(SafeExe php)" "$(SafePath $OPENSIM/bin/conf-sim.php)" \
                    -l "@$(SafeExe php) $(SafePath $CONFROOT/conflist.php)" \
                    -o "$(SafePath $SROOT/$F_INIFILE)" \
                    -p "$F_PROXY" -- \
		    "@$(SafeExe php) \"$(SafePath $SCONFDIR/$PLAZA.php)\" $SIM"

		rm -f $SROOT/OpenSim.exe.config
		"$(SafeExe php)" "$(SafePath $OPENSIM/bin/conf-logs.php)" \
                    $PLAZA:$SIM $F_LOGLEVEL \
		    > $SROOT/OpenSim.exe.config
		cp $SROOT/OpenSim.exe.config \
		    $SROOT/OpenSim.32BitLaunch.exe.config

		"$(SafePath $OPENSIM/bin/conf-scripts.pl)" -p $SROOT --skip

	    else
		echo "Missing directory for simulator $PLAZA:$SIM"
	    fi
	done
    fi
done

