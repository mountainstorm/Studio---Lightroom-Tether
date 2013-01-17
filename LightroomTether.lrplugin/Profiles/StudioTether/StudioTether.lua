local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrTasks = import 'LrTasks'
local LrFileUtils = import 'LrFileUtils'
local LrPathUtils = import 'LrPathUtils'

local LrView = import 'LrView'
local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrPrefs = import 'LrPrefs'



return {
	-- isDaemonRunning
	isDaemonRunning = function( path ) 
		return LrTasks.execute( "\""..path.."/isRunning\"" )
	end,
	
	
	-- getDaemonSettings
	getDaemonSettings = function( path )
		local retVal = nil
		local result = nil
	
		LrFunctionContext.callWithContext( "LightroomTetherDialog", function( context )
			retVal = LrBinding.makePropertyTable( context )
			retVal.path = nil
			retVal.mode = "0"
			
			local f = LrView.osFactory() 
			local updateField = f:edit_field {
				value = "<img download folder>",
				enabled = false,
				width_in_chars = 30,
			} 
			local checkbox = f:checkbox {
				value = "0",
				checked_value = "1",
				unchecked_value = "0"
			}
			local c = f:column {
				spacing = f:label_spacing(),
				f:row {
					checkbox,
					f:static_text {
						fill_horizontal = 1,
						title = "Use Custom Extensions"
					}
				},
				f:row {
					updateField,
					f:push_button { 
						title = "Select", 
						action = function()
							retVal.path = LrDialogs.runOpenPanel( { title="Select Download Directory", 
																	prompt="Select",
																	canChooseFiles=false,
																	canChooseDirectories=true,
																	canCreateDirectories=true,
																	allowsMultipleSelection=false,
																	fileTypes=nil,
																	accessoryView=nil } )
							if retVal.path ~= nil then
								retVal.path = retVal.path[ 1 ]
								updateField.value = retVal.path
								retVal.mode = checkbox.value
							end
						end 
					}, 
				},
			}
			result = LrDialogs.presentModalDialog( { 
				title = "LightroomTether", 
				contents = c,
			} ) 
		end )
	
		if result ~= "ok" or retVal.path == nil then
			retVal = nil
		end	
		return retVal
	end,
	
	
	-- startDaemon
	startDaemon = function( path, settings )
		LrTasks.execute( "osascript \""..path.."/start.scpt\" \""..settings.path.."\" "..settings.mode.." \"".._PLUGIN.path.."/Resources/LightroomTether\"" )
	end,
	
	
	-- stopDaemon
	stopDaemon = function( path )
		LrTasks.execute( "osascript \""..path.."/stop.scpt\"" )
	end
}
