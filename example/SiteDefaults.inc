;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;; Start Site Configuration for <?=PLAZANAME?>:<?=SIMNAME?> 
;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

<?php

// Pick up a few configuration options
$WindowsPrefix = "";
if (preg_match('/^Windows/',php_uname('s')))
    $WindowsPrefix = "/cygwin";

$OpenSimHome = getenv('OPENSIM');
if ($OpenSimHome == '')
    $OpenSimHome = '/share/opensim';

// Site Constants
define('HTTPBASEPORT',7000);
define('XMLRPCBASEPORT',20800);

// Site Configuration
define('ASSETCACHEMODULE','FlotsamAssetCache');
define('INSTALLROOT',"$WindowsPrefix$OpenSimHome");

if (! defined('DATABASEHOST'))
    define('DATABASEHOST','192.168.1.10');

if (! defined('IRCENABLED'))
  define('IRCENABLED','false');

if (! defined('HYPERGRIDENABLED'))
  define('HYPERGRIDENABLED','false');

if (! defined('VOICEENABLED'))
    define('VOICEENABLED','false');

?> 

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
[Network:Site]
http_listener_port = <?=HTTPBASEPORT+PORTOFFSET?> 
ExternalHostNameForLSL = <?= gethostbyname(gethostname()) ?> 
MaxRequestConcurrency = 0

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
[PacketPool:Site]
RecyclePackets = true
RecycleDataBlocks = true

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
[ClientStack.LindenUDP:Site]
async_packet_handling = true
client_socket_rcvbuf_size = 8388608

; values are bytes per second
scene_throttle_max_bps = 2500000
client_throttle_max_bps = 175000

;PrimUpdatesPerCallback = 500

; Per-client bytes per second rates for the various throttle categories.
; These are default values that will be overriden by clients

resend_default = 10000
land_default = 10000
wind_default = 10000
cloud_default = 10000
task_default = 10000
texture_default = 20000
asset_default = 20000
state_default = 10000

enable_adaptive_throttles = true            

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
[XMLRPC:Site]
;XmlRpcRouterModule = "XmlRpcRouterModule"
XmlRpcPort = <?=XMLRPCBASEPORT+PORTOFFSET ?> 

;; OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
;; OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
;;                            SIMULATOR
;; OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
;; OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
[Sun:Site]
day_length = 6
year_length = 60
day_night_offset = 0.45
update_interval = 100

;; OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
;; OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
;;                               MODULES
;; OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
;; OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
[RemoteAdmin:Site]
enabled = true
;; So long as we leave the bound address on the loopback interface
;; we can reuse the main servers port
port = "<?=HTTPBASEPORT+PORTOFFSET?>"
bind_ip_address = "127.0.0.1"
access_password = "<?=PLAZAPASS?>"
enabled_methods = "admin_shutdown|admin_save_oar"

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
[IRC:Site]
enabled = <?=IRCENABLED?> 

;; Default connection information
server = island.sciencesim.com
port = 6667
user = "USER <?=SIMNAME?> 8 * SciSim on <?=SIMNAME?>"
nick = <?=SIMNAME?> 
nicknum = true
channel = #scisim
msgformat = "PRIVMSG {0} : {1}/{2} -- {3}"

;; Control channel
commands_enabled = true
command_channel = 2777

;; Verbosity
report_clients = false

;; Relay configuration
relay_chat = false
relay_private_channels = true
relay_private_channel_in = 2225
relay_private_channel_out = 2226
access_password = foobar

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
[InterestManagement:Site]
; This section controls how state updates are prioritized for each client
; Valid values are Time, Distance, SimpleAngularDistance, and FrontBack
UpdatePrioritizationScheme = FrontBack
ReprioritizationEnabled = true
ReprioritizationInterval = 2000.0
RootReprioritizationDistance = 5.0
ChildReprioritizationDistance = 20.0

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
[LightShare:Site]
enable_windlight = true

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
[Mesh:Site]
; This section enables Collada mesh support
AllowMeshUpload = true

; if you use Meshmerizer and want collisions for meshies, setting this to true
; will cause OpenSim to attempt to decode meshies assets, extract the physics
; mesh, and use it for collisions. This is currently experimental code and enabling
; it may cause unexpected physics problems.
UseMeshiesPhysicsMesh = true

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
[VivoxVoice:Site]
enabled = <?=VOICEENABLED ?> 

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;; AssetCache
;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
[AssetCache:Site]
<?php if (ASSETCACHEMODULE == 'FlotsamAssetCache') { ?> 
;; -------------------- Options for FlotsamAssetCache --------------------
CacheDirectory = <?=INSTALLROOT?>/assetcache
LogLevel = 1
HitRateDisplay = 100
MemoryCacheEnabled = true
MemoryCacheTimeout = .5
FileCacheTimeout = 0
FileCleanupTimer = .166  ;roughly every 10 minutes
; WaitOnInprogressTimeout = 3000
CacheDirectoryTiers = 2
CacheDirectoryTierLength = 3
;CacheWarnAt = 30000

<?php } else if (ASSETCACHEMODULE == 'CenmoeCache') { ?> 
;; -------------------- Options for CenmoeCache --------------------
MaxSize =  268435456
MaxCount = 16384
ExpirationTime = 60
<?php } ?> 

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
[Modules:Site]
AssetCaching = "<?=ASSETCACHEMODULE?>"

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;; The :Site extension simplifies merge and is removed later
;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
[Startup:Site]

gridmode = true

; ##
; ## STORAGE
; ##
storage_plugin="OpenSim.Data.MySQL.dll"
storage_connection_string="Data Source=<?=DATABASEHOST?>;Database=<?=PLAZANAME?>;User ID=<?=PLAZAUSER?>;Password=<?=PLAZAPASS?>;"

;; --------------------------------------------------
[DatabaseService:Site]

StorageProvider = "OpenSim.Data.MySQL.dll"
ConnectionString = "Data Source=<?=DATABASEHOST?>;Database=<?=PLAZANAME?>;User ID=<?=PLAZAUSER?>;Password=<?=PLAZAPASS?>;"
EstateConnectionString = "Data Source=<?=DATABASEHOST?>;Database=<?=PLAZANAME?>;User ID=<?=PLAZAUSER?>;Password=<?=PLAZAPASS?>;"

;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;; Finish Site Specific Configuration
;; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


