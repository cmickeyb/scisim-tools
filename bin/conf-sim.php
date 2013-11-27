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


   // This script generates an OpenSim.ini file that merges configuration
   // information from multiple sources. It defaults to a sciencesim
   // configuration. See www.sciencesim.com for more documentation.

   // This is annoyingly expressive but helpful
error_reporting(E_ALL);

$ProxyHost = '';
$OutputFile = 'OpenSim.ini';
$InputFileList =
  array(
	'./OpenSim.ini.example'
	);

$ConfigArray = array();

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function MergeConfig($newconf)
{
  global $ConfigArray;

  foreach ($newconf as $section => $secval)
    {
      // We can use this to add directives to the sections; this 
      // is how we overcome ini file limitations about merging multiple
      // sections with the same name secname:context@directive
      $pieces = explode('@', $section, 2);
      $label = trim($pieces[0]);
      $directive = isset($pieces[1]) ? trim($pieces[1]) : "";

      $pieces = explode(':', $label, 2);
      $secname = trim($pieces[0]);
      $context = isset($pieces[1]) ? trim($pieces[1]) : "";

      $fullname = $secname . ":" . $context;

      // Replace directive removes any previous section settings
      if ($directive == 'replace' && array_key_exists($secname,$ConfigArray))
	unset($ConfigArray[$secname]);
	  
      // Set up the array for use
      if (! array_key_exists($secname,$ConfigArray))
	$ConfigArray[$secname] = array();

      // Save the context section as well, useful for debugging
      if ($context != "" && !array_key_exists($fullname,$ConfigArray))
	$ConfigArray[$fullname] = array();

      foreach ($secval as $key => $val)
	{
	  $ConfigArray[$secname][$key] = $val;
	  if ($context != "")
	    $ConfigArray[$fullname][$key] = $val;
	}
    }
}

// -----------------------------------------------------------------
// Clean up the value, this is necessary because true/false values
// are lost by the parse ini structure
// -----------------------------------------------------------------
function CleanString($str)
{
  $str = str_replace('True','"<<On>>"',$str);
  $str = str_replace('true','"<<On>>"',$str);
  $str = str_replace('False','"<<Off>>"',$str);
  $str = str_replace('false','"<<Off>>"',$str);
  return $str;
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function ReadFileList($file)
{
  $flist = array();

  if (preg_match('/^@/',$file))
      $ihandle = popen(substr($file,1),"r");
  else
      $ihandle = fopen($file,"r");

  if ($ihandle == false)
    {
      fprintf(STDERR,"Unable to open file list $file\n");
      exit(-1);
    }

  while (!feof($ihandle))
    {
      $str = fgets($ihandle);
      $str = trim($str);
      if (strlen($str) > 0)
	array_push($flist,$str);
    }
	
  if (preg_match('/^@/',$file))
      pclose($ihandle);
  else
      fclose($ihandle);

  return $flist;
}  
  
// -----------------------------------------------------------------
// -----------------------------------------------------------------
function ReadConfigFile($file)
{
  global $ProxyHost;

  $context = stream_context_create();
  if ($ProxyHost != '')
  {
    $opts = array('http' => array('proxy' => "tcp://$ProxyHost/", 'request_fulluri' => true));
    stream_context_set_option($context,$opts);
  }
                                  
  $ihandle = fopen($file,"r",false,$context);
  if ($ihandle == false)
    {
      fprintf(STDERR,"Error opening file $file for reading\n");
      exit(-1);
    }

  $tfile = tempnam(".","ssconf");
  $ohandle = fopen($tfile,"w");

  while (!feof($ihandle))
    {
      $str = fgets($ihandle);
      $str = CleanString($str);
      fputs($ohandle,$str);
    }
	
  fclose($ihandle);
  fclose($ohandle);

  MergeConfig(parse_ini_file($tfile,true));

  // Clean up the temporary file
  unlink($tfile);
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function EvaluateConfigFile($file)
{
  $ihandle = popen($file,"r");
  if ($ihandle == false)
    {
      fprintf(STDERR,"Error opening file $file for evaluation\n");
      exit(-1);
    }

  $tfile = tempnam(".","ssconf");
  $ohandle = fopen($tfile,"w");

  while (!feof($ihandle))
    {
      $str = fgets($ihandle);
      $str = CleanString($str);
      fputs($ohandle,$str);
    }
	
  pclose($ihandle);
  fclose($ohandle);

  MergeConfig(parse_ini_file($tfile,true));

  // Clean up the temporary file
  unlink($tfile);
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
function WriteConfigFile($file)
{
  global $ConfigArray;

  $ohandle = fopen($file,"w");
  if ($ohandle == false)
    {
      fprintf(STDERR,"unable to write $file\n");
      exit(-1);
    }

  $slist = array_keys($ConfigArray);
  sort($slist);
  foreach ($slist as $sindex => $section)
    {
      $secval = $ConfigArray[$section];
      if ($secval == NULL) continue;
      fputs($ohandle,";; --------------------------------------------------\n");
      fputs($ohandle,"[$section]\n\n");
      $klist = array_keys($secval);
      sort($klist);
      foreach ($klist as $kindex => $key)
	{
	  $val = $ConfigArray[$section][$key];
	  if ($val == "<<On>>")
	    $value = "True";
	  else if ($val == "<<Off>>")
	    $value = "False";
	  else if (is_numeric($val))
	    $value = $val;
	  else
	    $value = '"' . $val . '"';

	  fputs($ohandle,"$key = $value\n");
	}
      fputs($ohandle,"\n");
    }
  fclose($ohandle);
}

// -----------------------------------------------------------------
// Process command line options
// -----------------------------------------------------------------
$opts = getopt('cl:o:p:');
foreach (array_keys($opts) as $opt)
  {
    switch ($opt)
      {
      case 'c':
	$InputFileList = array();
	break;

      case 'l':
	$InputFileList = ReadFileList($opts[$opt]);
	break;
	
      case 'o':
        $OutputFile = $opts[$opt];
        break;

      case 'p':
        $ProxyHost = $opts[$opt];
        break;
      }
  }

// Process the files list which starts after '--'
$found = 0;
foreach ($argv as $file)
  {
    if ($found)
	array_push($InputFileList,$file);
    else if ($file == '--')
	$found = 1;
  }

if ($InputFileList == '')
  {
    fprintf(STDERR,"Usage: $argv[0] [-c] [-l ConfList] [-o OutputFile] -- [FileList]\n");
    exit(-1);
  }

// -----------------------------------------------------------------
// Now parse all the files we just read
// -----------------------------------------------------------------
foreach ($InputFileList as $file)
  {
    if (preg_match('/^@/',$file))
      {
	EvaluateConfigFile(substr($file,1));
      }
    else
      {
	ReadConfigFile($file);
      }
  }

WriteConfigFile($OutputFile);

?>
