<?php
// -----------------------------------------------------------------
// Lake Plaza
// Estate(GridXBase, GridYBase, RegionPortBase, MasterAv ID)
//     GridXBase, GridYBase provide an origin for the per-region
//     configuration. Changing these can relocate all regions in
//     the plaza.
//
//     RegionPortBase is the first port used for the regions. Each
//     region's UDP port will be offset from RegionPortBase. Note
//     that the http connection to the simulator is configured in
//     other locations.
//
// -----------------------------------------------------------------
Estate(975,1075,9400,"d9cf2921-8d95-42e6-ba6c-cc4c0ae21de1");

// -----------------------------------------------------------------
// Region(RegionName,RegionID,GridXOffset,GridYOffset,SimulatorName)
// 
// -----------------------------------------------------------------
Region("Cramer","446452e1-246d-4667-a212-67e617a9c88c",0,0,"cramer");
Region("Heyburn","7193542c-9615-4748-932b-ef082f037228",0,1,"heyburn");
Region("McGowan","3bca8c6d-e91d-4aa8-804e-66f7b4a7421a",1,0,"mcgowan");
Region("Payette","ee12118a-af44-4bda-b53c-c567cd3ba8f4",1,1,"payette");

?>
