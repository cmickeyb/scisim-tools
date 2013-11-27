#!/usr/bin/php
<?php
   // -----------------------------------------------------------------            
   // Simulator name from command line parameters                                  
   // -----------------------------------------------------------------            
define('SIMNAME',$argv[1]);

// -----------------------------------------------------------------
// Configure the ports used by the simulators in this plaza         
// -----------------------------------------------------------------
define('PLAZAPORTOFFSET',80);
$SimPortOffsets = array('cramer' => 0,
			'heyburn' => 1,
                        'mcgowan' => 2,
                        'payette' => 3);

// ----------------------------------------------------------------- 
// Set up some variables before we include the SiteDefaults          
// ----------------------------------------------------------------- 
// Simulator constants                                               
define('IRCENABLED','false');
define('HYPERGRIDENABLED','false');
define('VOICEENABLED','false');

// These are used for a variety of things including database access  
define('PLAZANAME','lplaza');
define('PLAZAUSER','lplaza');
define('PLAZAPASS','JUST_AN_EXAMPLE');
define('DATABASEHOST','localhost');

// And some derived configurations                                   
define('PORTOFFSET',PLAZAPORTOFFSET+$SimPortOffsets[SIMNAME]);

// -----------------------------------------------------------------
// This loads a file of common options. In this way you can have one
// file with grid-wide defaults while each simulator can override those
// defaults as necessary.
// -----------------------------------------------------------------
$WindowsPrefix = "";
if (preg_match('/^Windows/',php_uname('s')))
    $WindowsPrefix = "/cygwin";

$OpenSimHome = getenv('OPENSIM');if ($OpenSimHome == '')
   $OpenSimHome = '/share/opensim';

include($WindowsPrefix . $OpenSimHome . '/etc/SiteDefaults.inc');
?>

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;; START SIMULATOR SPECIFIC CONFIGURATION
;; 
;; Note that we tag the source of the configuration information 
;; with a ":" in the section name. The ":" is dropped when the
;; configuration options are merged. This gets around a limitation
;; in OpenSims nini configuration where all future sections replace
;; previous sections rather than merging with previous sections.
;;
;; Using a "@" in the section name forces replacement of all previously
;; specified values in that section
;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

[Startup:Simulator]
physics = BulletSim

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;; END SIMULATOR SPECIFIC CONFIGURATION
;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

