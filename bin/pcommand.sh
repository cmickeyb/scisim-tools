#!/bin/bash

# -----------------------------------------------------------------
# Copyright (c) 2010 Intel Corporation
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:

#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.

#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.

#     * Neither the name of the Intel Corporation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE INTEL OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# EXPORT LAWS: THIS LICENSE ADDS NO RESTRICTIONS TO THE EXPORT LAWS OF
# YOUR JURISDICTION. It is licensee's responsibility to comply with any
# export regulations applicable in licensee's jurisdiction. Under
# CURRENT (May 2000) U.S. export regulations this software is eligible
# for export from the U.S. and can be downloaded by or otherwise
# exported or reexported worldwide EXCEPT to U.S. embargoed destinations
# which include Cuba, Iraq, Libya, North Korea, Iran, Syria, Sudan,
# Afghanistan and any other country to which the U.S. has embargoed
# goods and services.
# -----------------------------------------------------------------

F_ACCOUNT="opensim"
if [ -n "$OPENSIMACCOUNT" ]; then
    F_ACCOUNT=$OPENSIMACCOUNT
fi

F_HOSTLIST="m1.virtualportland.org m2.virtualportland.org m3.virtualportland.org"
F_HOSTLIST+=" m4.virtualportland.org m5.virtualportland.org m6.virtualportland.org"
F_HOSTLIST+=" mic01.intel-research.net mic02.intel-research.net"

if [ -n "$OPENSIMHOSTS" ]; then
    F_HOSTLIST=$OPENSIMHOSTS
fi

F_CONFDIR='etc'
if [ -n "$OPENSIMCONFDIR" ]; then
    F_CONFDIR=$OPENSIMCONFDIR
fi

F_LOGNAME="/tmp/log.$(date +%m%d).$RANDOM"

F_BACKGROUND=''
F_OUTPUTMETHOD='>'

TEMP=`getopt -o bhv --long background,hosts:,verbose \
    -n 'pupdate.sh' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"
while true ; do
    case "$1" in
    -h) echo "Usage: pcommand.sh [debug,backup,build,checkout,update-tools,push-conf,update-cfg,clean-logs,eval,copy]"; exit 1;;
	-b|--background) F_BACKGROUND='-f'; shift;;
	-v|--verbose) F_OUTPUTMETHOD='| tee'; shift;;
        --hosts) F_HOSTLIST=$2 ; shift 2 ;;
	--) shift ; break ;;
	*) echo "Internal error! $1" ; exit 1 ;;
    esac
done

F_COMMAND='debug'
if [ -n "$1" ]; then
    F_COMMAND=$1
    shift
fi

# -----------------------------------------------------------------
# debug
# -----------------------------------------------------------------
if [ "$F_COMMAND" == 'debug' ]; then
    F_CMD='echo $OPENSIM'
fi
    
# -----------------------------------------------------------------
# backup
# -----------------------------------------------------------------
if [ "$F_COMMAND" == 'backup' ]; then
    F_CMD="cd /share/opensim; ossim save plaza.*/*"
fi

# -----------------------------------------------------------------
# build
# -----------------------------------------------------------------
if [ "$F_COMMAND" == 'build' ]; then
    F_CMD="/share/opensim/bin/update-bld.sh $@"
fi

# -----------------------------------------------------------------
# checkout
# -----------------------------------------------------------------
if [ "$F_COMMAND" == 'newbranch' ]; then
    F_CMD="cd /share/opensim/scisim-git; git pull; git checkout -b $1 origin/$1"
fi

# -----------------------------------------------------------------
# update-tools
# -----------------------------------------------------------------
if [ "$F_COMMAND" == 'push-tools' ]; then
    F_CMD='cd /share/opensim/scisim-tools-git; git pull; ./install.sh'
fi

# -----------------------------------------------------------------
# push-conf
# -----------------------------------------------------------------
if [ "$F_COMMAND" == 'push-conf' ]; then
    F_CMD="cd /share/opensim/$F_CONFDIR; git pull"
fi

# -----------------------------------------------------------------
# update-cfg
# -----------------------------------------------------------------
if [ "$F_COMMAND" == 'update-cfg' ]; then
    F_CMD="update-cfg.sh --config $F_CONFDIR $@"
fi

# -----------------------------------------------------------------
# clean-logs
# -----------------------------------------------------------------
if [ "$F_COMMAND" == 'clean-logs' ]; then
    F_CMD='rm /tmp/log.*'
fi

echo $F_COMMAND

# -----------------------------------------------------------------
# just eval the command
# -----------------------------------------------------------------
if [ "$F_COMMAND" == 'eval' ]; then
    echo "$@"
    F_CMD="$@"
fi

# -----------------------------------------------------------------
# Copy local file to remote location
# -----------------------------------------------------------------
if [ "$F_COMMAND" == 'copy' ]; then
    F_CMD="scp"
    F_SOURCE=$1
    shift
    F_DEST=$1
fi


# -----------------------------------------------------------------
# Loop through the hosts
# -----------------------------------------------------------------
for host in $F_HOSTLIST; do
    echo ===== $host =====
    if [ "$F_COMMAND" == 'copy' ]; then
        echo "scp $F_SOURCE $F_ACCOUNT@$host:$F_DEST"
        scp $F_SOURCE $F_ACCOUNT@$host:$F_DEST
    else
        echo "$F_CMD > $F_LOGNAME"
        ssh $F_BACKGROUND -A -l $F_ACCOUNT "$host" "/bin/bash -l -c '{ $F_CMD ;} $F_OUTPUTMETHOD $F_LOGNAME'"
    fi
done
