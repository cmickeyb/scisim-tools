#!/usr/bin/php
<?php

   // Copyright (c) Intel Corporation
   // All rights reserved.
   // Redistribution and use in source and binary forms, with or without
   // modification, are permitted provided that the following conditions
   // are met:
   //
   // -- Redistributions of source code must retain the above copyright
   //    notice, this list of conditions and the following disclaimer.
   // -- Redistributions in binary form must reproduce the above copyright
   //    notice, this list of conditions and the following disclaimer in the
   //    documentation and/or other materials provided with the distribution.
   // -- Neither the name of the Intel Corporation nor the names of its
   //    contributors may be used to endorse or promote products derived from
   //    this software without specific prior written permission.
   //
   // THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   // ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   // LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
   // PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE INTEL OR ITS
   // CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   // EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   // PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   // PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   // LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   // NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   // SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   // This script generates the Regions.ini file from a php data file
   // that sets estate and region information. See www.sciencesim.com
   // for documentation

// -----------------------------------------------------------------
// Global variables
// -----------------------------------------------------------------
$masteruuid = '';
$masterfirst = 'Master';
$masterlast = 'Avatar';
$primnonphys = 256;
$primphys = 10;
$primmax = 150000;
$agentmax = 500;
$autobackup = 'no';
$autobackinterval = 720;
$autobacknaming = 'Time';
$autobackdir = '.';

$extaddr = gethostbyname(php_uname('n'));
$intaddr = '0.0.0.0';

$simname = '';

$region = '';
$simulator = '';

$sizeX = 256;
$sizeY = 256;

// -----------------------------------------------------------------
// Process command line options
// -----------------------------------------------------------------
$opts = getopt('f:l:m:n:p:r:s:u:');
foreach (array_keys($opts) as $opt)
{
    switch ($opt)
    {
      case 'a':
	$agentmax = $opts[$opt];
	break;

      case 'f':
	$masterfirst = $opts[$opt];
	break;

      case 'l':
        $masterlast = $opts[$opt];
        break;

      case 'm':
        $primmax = $opts[$opt];
        break;

      case 'n':
        $primnonphys = $opts[$opt];
        break;

      case 'p':
        $primphys = $opts[$opt];
        break;

      case 'r':
        $region = $opts[$opt];
        break;

      case 's':
        $simulator = $opts[$opt];
        break;

      case 'u':
        $masteruuid = $opts[$opt];
        break;
    }
}

if ($region == '' || $simulator == '')
{
    fprintf(STDERR,"Usage: $argv[0]\n");
    fprintf(STDERR,"\t-f Master First Name [Master]\n");
    fprintf(STDERR,"\t-l Master Last Name [Avatar]\n");
    fprintf(STDERR,"\t-m Max Prim Count []\n");
    fprintf(STDERR,"\t-n Max Nonphysical Prim Size [256]\n");
    fprintf(STDERR,"\t-p Max Physical Prim Size [10] \n");
    fprintf(STDERR,"\t-r Region File\n");
    fprintf(STDERR,"\t-u Master UUID\n");
    fprintf(STDERR,"\t-s Simulator \n");
    exit(-1);
}


// -----------------------------------------------------------------
// -----------------------------------------------------------------
function PostWebRequest(array $post = NULL)
{ 
    $SimianHome = getenv('SIMIAN');
    if ($SimianHome == '')
    {
        fprintf(STDERR,"No SIMIAN URL specified\n");
        exit(-1);
    }

    $defaults = array(CURLOPT_POST => 1, 
                      CURLOPT_HEADER => 0, 
                      CURLOPT_URL => $SimianHome, 
                      CURLOPT_FRESH_CONNECT => 1, 
                      CURLOPT_RETURNTRANSFER => 1, 
                      CURLOPT_FORBID_REUSE => 1, 
                      CURLOPT_TIMEOUT => 4, 
                      CURLOPT_POSTFIELDS => http_build_query($post)); 

    $ch = curl_init(); 
    curl_setopt_array($ch, $defaults);

    if (! $result = curl_exec($ch)) 
    { 
        fprintf(STDERR,"Simian connection failed; " . curl_error($ch));
        exit(-1);
    } 

    curl_close($ch); 
    return json_decode($result); 
} 

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function QuarkLocation($xx,$yy)
{
    global $quarkX, $quarkY;

    $quarkX = $xx;
    $quarkY = $yy;
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function PhysicsServer($saddr,$sport)
{
    global $physAddress, $physPort;

    $physAddress = $saddr;
    $physPort = $sport;
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function SyncServer($saddr,$sport)
{
    global $syncAddress, $syncPort;

    $syncAddress = $saddr;
    $syncPort = $sport;
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function LocalSyncServer($saddr,$sport)
{
    global $localSyncAddress, $localSyncPort;

    $localSyncAddress = $saddr;
    $localSyncPort = $sport;
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function RemoteSyncServer($saddr,$sport)
{
    global $remoteSyncAddress, $remoteSyncPort;

    $remoteSyncAddress = $saddr;
    $remoteSyncPort = $sport;
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function AvatarServer($aaddr,$aport)
{
    global $avatarAddress, $avatarPort;

    $avatarAddress = $aaddr;
    $avatarPort =$aport;
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function AutoBackup($int,$name,$dir)
{
  global $autobackup, $autobackinterval, $autobacknaming, $autobackdir;
  $autobackup = 'yes';
  $autobackinterval = $int;
  $autobacknaming = $name;
  $autobackdir = $dir;
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function SetLimits($nonphys, $phys, $pmax, $amax)
{
  global $primnonphys, $primphys, $primmax, $agentmax;

  $primnonphys = $nonphys;
  $primphys = $phys;
  $primmax = $pmax;
  $agentmax = $amax;
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function Estate($bX,$bY,$bP,$uuid)
{
  global $baseX, $baseY, $basePort, $masteruuid;

  $baseX = $bX;
  $baseY = $bY;
  $basePort = $bP;
  $masteruuid = $uuid;
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function NetworkEndpoint($internal,$external)
{
  global $extaddr, $intaddr;
  $intaddr = $internal;
  $extaddr = $external;
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function RegionSize($x, $y)
{
    global $sizeX, $sizeY;
    $sizeX = $x;
    $sizeY = $y;
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function ReservedRegion($name,$sim)
{
    $params = array('RequestMethod' => 'GetScene', 'Name' => $name);
    $results = PostWebRequest($params);
    if (! isset($results->Success) || ! $results->Success)
    {
        fprintf(STDERR,"Failed to retrieve region informaiton for $name\n");
        exit(-1);
    }

    global $baseX, $baseY;

    $offX = ($results->MinPosition[0] / 256) - $baseX;
    $offY = ($results->MinPosition[1] / 256) - $baseY;
    $uuid = $results->SceneID;

    Region($name,$uuid,$offX,$offY,$sim);
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function Region($name,$uuid,$offX,$offY,$sim)
{
  global $simulator, $baseX, $baseY, $basePort;
  global $masteruuid, $masterfirst, $masterlast;
  global $extaddr, $intaddr;
  global $primnonphys, $primphys, $primmax, $agentmax;
  global $avatarAddress, $avatarPort;
  global $syncAddress, $syncPort;
  global $localSyncAddress, $localSyncPort;
  global $remoteSyncAddress, $remoteSyncPort;
  global $physAddress, $physPort;
  global $quarkX, $quarkY;
  global $autobackup, $autobackinterval, $autobacknaming, $autobackdir;
  global $sizeX, $sizeY;

  if ($sim != $simulator)
  {
      $basePort++;
      return;
  }

  $x = $baseX+$offX;
  $y = $baseY+$offY;
  
  echo <<< EOT
[$name]
RegionUUID = $uuid
Location = $x,$y
InternalAddress = $intaddr
InternalPort = $basePort
AllowAlternatePorts = False
ExternalHostName = $extaddr
NonphysicalPrimMax = $primnonphys
PhysicalPrimMax = $primphys
ClampPrimSize = False
MaxPrims = $primmax
MaxAgents = $agentmax
SizeX = $sizeX
SizeY = $sizeY
EOT;

  $basePort++;

  if ($autobackup == 'yes')
  {
      echo "AutoBackup = yes\n";
      echo "AutoBackupBusyCheck = false\n";
      echo "AutoBackupInterval = $autobackinterval\n";
      echo "AutoBackupNaming = $autobacknaming\n";
      echo "AutoBackupDir = $autobackdir\n";
  }

  if (isset($quarkX) && isset($quarkY))
  {
    echo "SyncQuarkLocation = \"$quarkX,$quarkY\"\n";
  }
  if (isset($syncAddress) && isset($syncPort))
  {
      echo "SyncServerAddress = $syncAddress\n";
      echo "SyncServerPort = $syncPort\n";
  }
  if (isset($localSyncAddress) && isset($localSyncPort))
  {
      echo "LocalSyncServerAddress = $localSyncAddress\n";
      echo "LocalSyncServerPort = $localSyncPort\n";
  }
  if (isset($remoteSyncAddress) && isset($remoteSyncPort))
  {
      echo "RemoteSyncServerAddress = $remoteSyncAddress\n";
      echo "RemoteSyncServerPort = $remoteSyncPort\n";
  }

  if (isset($avatarAddress) && isset($avatarPort))
  {
      echo "AvatarSyncServerAddress = $avatarAddress\n";
      echo "AvatarSyncServerPort = $avatarPort\n";
  }

  if (isset($physAddress) && isset($physPort))
  {
      echo "PhysicsSyncServerAddress = $physAddress\n";
      echo "PhysicsSyncServerPort = $physPort\n";
  }

  echo "\n";
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
// Add Quark information to the region specification. The quark info is
//   output when this is called.
// The old form of "Quark()" is here for downward compatibility and
//   can be removed someday.
function Quarks($sim) {
  global $simulator;

  if ($sim != $simulator)
     return;

  $argList = func_get_args();
  $numQuarks = func_num_args() - 1;
  echo "SyncQuarkCount = $numQuarks\n";

  for ($i = 0; $i < $numQuarks; $i++) {
    $quarkName = $argList[$i + 1];
    echo "SyncQuark$i = $quarkName\n";
  }
  echo "\n";
}

// This is deprecated and left for downward compatibility
function QuarksActive($sim) {
  global $simulator;

  if ($sim != $simulator)
     return;

  $argList = func_get_args();
  $numQuarks = func_num_args() - 1;
  echo "SyncQuarkActiveCount = $numQuarks\n";

  for ($i = 0; $i < $numQuarks; $i++) {
    $quarkName = $argList[$i + 1];
    echo "SyncQuarkActive$i = $quarkName\n";
  }
  echo "\n";
}

// This is deprecated and left for downward compatibility
function QuarksPassive($sim) {
  global $simulator;

  if ($sim != $simulator)
     return;

  $argList = func_get_args();
  $numQuarks = func_num_args() - 1;
  echo "SyncQuarkPassiveCount = $numQuarks\n";

  for ($i = 0; $i < $numQuarks; $i++) {
    $quarkName = $argList[$i + 1];
    echo "SyncQuarkPassive$i = $quarkName\n";
  }
  echo "\n";
}

function SyncActiveQuarks($sim) {
  global $simulator;

  if ($sim != $simulator)
     return;

  $argList = func_get_args();
  $quarkSpec = $argList[1];
  echo "SyncActiveQuarks = $quarkSpec\n";

}

function SyncPassiveQuarks($sim) {
  global $simulator;

  if ($sim != $simulator)
     return;

  $argList = func_get_args();
  $quarkSpec = $argList[1];
  echo "SyncPassiveQuarks = $quarkSpec\n";
}

function SyncActiveQuarkFilters($sim) {
  global $simulator;

  if ($sim != $simulator)
     return;

  $argList = func_get_args();
  $filterSpec = $argList[1];
  echo "SyncActiveQuarkFilters = $filterSpec\n";

}

function SyncPassiveQuarkFilters($sim) {
  global $simulator;

  if ($sim != $simulator)
     return;

  $argList = func_get_args();
  $filterSpec = $argList[1];
  echo "SyncPassiveQuarkFilters = $filterSpec\n";
}

include($region);

?>
