--[[----------------------------------------------------------------------------

Mountainstorm Photography

--------------------------------------------------------------------------------

PluginManager.lua
displays the config params

------------------------------------------------------------------------------]]

local LrFileUtils = import "LrFileUtils"
local LrView = import "LrView"
local LrBinding = import "LrBinding"
local app = import 'LrApplication'
local bind = LrView.bind
local LrPrefs = import 'LrPrefs'


PluginManager = {}



return {
	sectionsForBottomOfDialog = function(f, p)
		local prefs = LrPrefs.prefsForPlugin( nil )
		local appProfiles = {}
		local x = 1
		for filePath in LrFileUtils.directoryEntries( _PLUGIN.path.."/Profiles/" ) do
			local filename = string.match( filePath, "/([^\/\?\#]+)\/*$" )
			table.insert( appProfiles, { title = filename, value = x } )
			if filename == "StudioTether" then
				prefs[ "appProfile" ] = x -- select the first one as default
			end
			x = x + 1
		end
		
		return {
			--section for the bottom of the dialog
			{
				title = LOC "$$$/LightroomTether/PluginManager=LightroomTether",
				f:row {
					bind_to_object = prefs,
					f:static_text {
						title = 'Application Profile: ',
						fill_horizontal = 1,
					},
					f:popup_menu { 
						title = "Download Application", 
						items = appProfiles,
						value = bind "appProfile",
						size = 'small',
					}, 
				},
			},
		}
	end
}