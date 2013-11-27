<?php
$WindowsPrefix = "";
if (preg_match('/^Windows/',php_uname('s')))
    $WindowsPrefix = "/cygwin";

$OpenSimHome = getenv('OPENSIM');
if ($OpenSimHome == '')
   $OpenSimHome = '/share/opensim';

$SimianHome = getenv('SIMIAN');
if ($SimianHome == '')
    $SimianHome = 'http://localhost/Grid/';

?>
<?php echo "$WindowsPrefix$OpenSimHome" ?>/bld/bin/OpenSim.ini.example
<?php echo "$WindowsPrefix$OpenSimHome" ?>/bld/bin/OpenSimDefaults.ini
<?php echo "$SimianHome" ?>gridinfo.php?context=Grid
