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

F_HOME='/home/opensim/'
if [ -n "$OPENSIM" ]; then
    F_HOME=$OPENSIM
else
    echo "OPENSIM not set; using $F_HOME as root"
fi

F_CACHEDIR="$F_HOME/assetcache"
F_CACHEBAK="$F_HOME/ac.bak"

mv $F_CACHEDIR $F_CACHEBAK
mkdir $F_CACHEDIR

cd $F_CACHEBAK
if [ "$(pwd)" == "$F_HOME/ac.bak" ]; then
    for i in 0 1 2 3 4 5 6 7 8 9 a b c d e f j; do
        rm -rf $i*
        sleep 3
    done
fi

cd $F_HOME
rmdir $F_CACHEBAK


