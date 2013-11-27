#!/usr/bin/python

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
 
import ConfigParser
import xmlrpclib
import optparse
import os.path
import socket
 
if __name__ == '__main__':
    parser = optparse.OptionParser()
    parser.add_option('-c', '--config', dest = 'config', help = 'config file')
    parser.add_option('-f', '--oarfile', dest = 'oarfile', help = 'oar file name')
    parser.add_option('-r', '--region', dest = 'region', help = 'region name')
    (options, args) = parser.parse_args()
 
    configFile = options.config
    if not configFile:
        parser.error('missing option config')
        exit(1)
 
    oarFile = options.oarfile
    if not oarFile:
        parser.error('missing option oarfile')
        exit(1)

    regionName = options.region
    if not regionName:
        parser.error('missing option region')
        exit(1)

    config = ConfigParser.ConfigParser()
    config.readfp(open(configFile))
 
    password = config.get('RemoteAdmin','access_password')
    password = password.replace('"','')

    address = config.get('RemoteAdmin','bind_ip_address')
    address = address.replace('"','')

    port = config.get('RemoteAdmin','port')
    port = port.replace('"','')

    try:
        hgurl = config.get('GridService','Gatekeeper')
        hgurl = hgurl.replace('"','')
    except ConfigParser.NoOptionError:
        hgurl = ""

    server = "http://%s:%s/" % (address, port)
 
    gridServer = xmlrpclib.ServerProxy(server)
    socket.setdefaulttimeout(60)

    # profile is obsolute parameter. Should use 'home' now. See ArchiverModule.cs:146
    # For now, using nothing until I know what to put here.
    # res = gridServer.admin_save_oar({'password': password, 'region_name': regionName, 'filename': oarFile, 'profile': hgurl})
    res = gridServer.admin_save_oar({'password': password, 'region_name': regionName, 'filename': oarFile})
    if res['saved'] :
        print "saved oar file in %s" % (oarFile)
    else:
        print "unable to save oarfile; %s" % (res['error'])

    exit
