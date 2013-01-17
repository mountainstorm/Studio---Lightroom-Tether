--[[----------------------------------------------------------------------------

Mountainstorm Photography

------------------------------------------------------------------------------]]

return {

	LrSdkVersion = 2.0,
	LrSdkMinimumVersion = 2.0,

	LrPluginName = "$$$/LightroomTether/PluginName=LightroomTether",
	LrToolkitIdentifier = 'com.mountainstorm.lightroomtether',
	
	LrExportMenuItems = {
		{
			title = "LightroomTether",
			file = 'LightroomTether.lua',
		},
	},

	LrPluginInfoProvider = 'PluginInfoProvider.lua',
	VERSION = { major=3, minor=6, revision=1, build=0, },
}
