#!/usr/bin/perl -w

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

use FindBin;
use lib "$FindBin::Bin/../lib";

my $gCommand = $FindBin::Script;

use Getopt::Long;


my $gSimPath;
my $gRegionFile;
my $gSkipAssets = 0;
my $gOptions = {};
my $gRegions = [];

# -----------------------------------------------------------------
# NAME: Main
# -----------------------------------------------------------------
sub DumpRegionSaveScript
{
    my $lfile = "$gSimPath/Regions/save.cmd";
    my $sa = $gSkipAssets ? "--noassets" : "";

    open(SFILE,"> $lfile");
    foreach my $region (@gRegions)
    {
	print SFILE "change region $region\n";
	print SFILE "save oar $sa \"Regions/$region.oar\"\n";
    }
    close(SFILE);
}

# -----------------------------------------------------------------
# NAME: Main
# -----------------------------------------------------------------
sub DumpRegionLoadScript
{
    my $lfile = "$gSimPath/Regions/load.cmd";
    my $sa = $gSkipAssets ? "--skip-assets" : "";

    open(LFILE,"> $lfile");
    foreach my $region (@gRegions)
    {
	print LFILE "change region $region\n";
	print LFILE "load oar $sa \"Regions/$region.oar\"\n";
    }
    close(LFILE);
}

# -----------------------------------------------------------------
# NAME: Main
# -----------------------------------------------------------------
sub Main
{
    $gOptions->{'p|path=s'} = \$gSimPath;
    $gOptions->{'s|skip!'} = \$gSkipAssets;

    if (! GetOptions(%{$gOptions}))
    {
	die "Unable to parse option list\n";
    }

    die "Unable to locate simulator directory; $gSimPath\n"
	unless -d $gSimPath && -d "$gSimPath/Regions";

    $gRegionFile = "$gSimPath/Regions/Regions.ini";

    open(RFILE,"<$gRegionFile") || die "Unable to open regions file $gRegionFile\n";

    while (<RFILE>)
    {
	chomp;
	push(@gRegions,$1) if /\[(.*)\]/ ;
    }

    close(RFILE);

    &DumpRegionLoadScript();
    &DumpRegionSaveScript();
}

&Main;



