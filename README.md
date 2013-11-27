scisim-tools
============

This project contains a set of tools that have proven useful for
building, configuring and deploying OpenSim grids.

These tools work on the premise that OpenSim source, grid configuration,
and simulator executables reside under a single directory structure
(although specifically command line switches can override that
assumption). The root of the directory tree is specified in the
environment variable OPENSIM.  The following structure is assumed by the
defaults:

opensim-git
   directory containing source for OpenSim
   override with OPENSIMSOURCEDIR

bld
   directory in which OpenSim is compiled

etc
   directory where the configuration of plazas and simulators resides
   override with OPENSIMCONFDIR

etc/plaza 
   directory containing plaza configuration, a plaza roughly corresponds
   to an estate or a collection of simulators that can be managed as a
   single entity, plaza configuration is a list of simulators in the
   plaza

etc/simulator
   directory containing OpenSim configuration directives for each
   simulator in a plaza, one file per plaza

etc/regions
   directory containing the OpenSim region configuration directives for
   each region in a simulator, one file per plaza containing all of the
   region configuration

plaza.*
   directory for each plaza

plaza.*/run.*
   directory for each simulator