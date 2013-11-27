#!/usr/bin/php -d short_open_tag=0
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

   // This script generates the OpenSim.exe.config file to configure
   // logging. It assumes that log files should be generated in the
   // directory in ../logs relative to the simulator execution directory

// -----------------------------------------------------------------
// Simulator name from command line parameters
// -----------------------------------------------------------------

$SimName = $argv[1];
$logLevel = $argv[2];

$WindowsPrefix = "";
if (preg_match('/^Windows/',php_uname('s')))
    $WindowsPrefix = "/cygwin";

$OpenSimHome = getenv('OPENSIM');
if ($OpenSimHome == '')
    $OpenSimHome = '/share/opensim';
$LogFileName = "$WindowsPrefix$OpenSimHome/logs/$SimName";
if (preg_match('/^Windows/',php_uname('s')))
    $LogFileName = str_replace(":","_",$LogFileName);

echo '<?xml version="1.0" encoding="utf-8" ?>';
?>
<configuration>
  <configSections>
    <section name="log4net" type="log4net.Config.Log4NetConfigurationSectionHandler,log4net" />
  </configSections>

  <runtime>
    <gcConcurrent enabled="true" />
	<gcServer enabled="true" />
  </runtime>

  <appSettings>
  </appSettings>

  <log4net>
    <appender name="Console" type="OpenSim.Framework.Console.OpenSimAppender, OpenSim.Framework.Console">
      <layout type="log4net.Layout.PatternLayout">
        <conversionPattern value="%date{HH:mm:ss} - %message" />
      </layout>
    </appender>

    <appender name="LogFileRotate" type="log4net.Appender.RollingFileAppender">
       <file value="<?php echo($LogFileName); ?>-" />
       <rollingstyle value="Date" />
       <appendToFile value="true" />
       <maximumFileSize value="500KB" />
       <maxSizeRollBackups value="5" />
       <staticlogfilename value="false" />
       <datePattern value="yyyy-MM-dd" />
      <layout type="log4net.Layout.PatternLayout">
        <conversionPattern value="%date{HH:mm:ss} %-5level - %logger %message%newline" />
      </layout>
    </appender>

    <appender name="LogFileAppender" type="log4net.Appender.FileAppender">
      <file value="<?php echo($LogFileName); ?>.log" />
      <appendToFile value="true" />
      <layout type="log4net.Layout.PatternLayout">
        <conversionPattern value="%date %-5level - %logger %message%newline" />
      </layout>
    </appender>

    <root>
      <level value="<?php echo($logLevel); ?>" />
      <appender-ref ref="Console" />
      <appender-ref ref="LogFileRotate" />
      <!-- <appender-ref ref="LogFileAppender" /> -->
    </root>
  </log4net>
</configuration>
