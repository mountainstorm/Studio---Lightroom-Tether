--[[----------------------------------------------------------------------------

Mountainstorm Photography

--------------------------------------------------------------------------------

LightroomTether.lua
starts/stops the import processing

------------------------------------------------------------------------------]]



-- Access the Lightroom SDK namespaces
local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrTasks = import 'LrTasks'
local LrFileUtils = import 'LrFileUtils'
local LrPathUtils = import 'LrPathUtils'

local LrView = import 'LrView'
local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrPrefs = import 'LrPrefs'



-- Create a namespace for the functions
LightroomTether = {}



function LightroomTether.getNextEvent( appProfilePath, evPipe, funcs )
	local retVal = nil
	local count = 0
	while retVal == nil do
		if count == 2 then
			count = 0
			if funcs.isDaemonRunning( appProfilePath ) == 0 then
				-- appName is no longer running
				break
			end
		end
		
		-- get the event if ones ready
		if evPipe:read( 0 ) ~= nil then
			local msg = evPipe:read( "*l" ) -- read the event
			if msg ~= "pass:" then
				retVal = msg
			end
		end		
		LrTasks.sleep( 0.5 ) -- can be fractional
		count = count + 1
	end
	return retVal
end



-- process all events being sent to us
function LightroomTether.processEvents( appProfilePath, appProfile, evPipePath, funcs )
	local c = LrApplication.activeCatalog()
	local lastImport = nil
	local imgProgress = nil
	
	LrDialogs.message( appProfile.." started; turn on camera" )

	-- loop through all the events
	local evPipe = io.open( evPipePath, "r" ) -- this will block until something has written to it	
	if evPipe ~= nil then
		local file = LightroomTether.getNextEvent( appProfilePath, evPipe, funcs ) 
		while file ~= nil do
			local tp = false
			
			-- add the photo to the catalog
			c:withWriteAccessDo( "Tethered", function() 
				local img = c:addPhoto( file )
				local tgt = c.targetPhoto
				if tgt ~= nil and lastImport == tgt.path then
					-- We cant programatically select img, so do the next best thing
					tp = true
				end
			end ) 
	
			-- press right in Lightroom ... its the best we can do :)
			if tp == true then
				LrTasks.execute( "osascript \"".._PLUGIN.path.."/Resources/targetPhoto.scpt".."\"" )
			end
			lastImport = file
			file = LightroomTether.getNextEvent( appProfilePath, evPipe, funcs ) 
		end
		LrDialogs.message( appProfile.." stopped; session complete" )
		evPipe:close()
	else
		LrDialogs.message( "Fatal error, failed to open event pipe" )	
	end
end



-- get the LightroomTether application support folder
function LightroomTether.getApplicationSupportDir()
	local tmpName = os.tmpname()
	LrTasks.execute( "\"".._PLUGIN.path.."/Resources/getApplicationSupport\" > \""..tmpName.."\"" )

	local tmpFile = io.open( tmpName, "r" )
	local retVal = tmpFile:read()
	tmpFile:close()
	
	LrTasks.execute( "rm \""..tmpName.."\"" )
	return retVal
end



-- start/stop StudioTether and poll for new files
function LightroomTether.init()
	LrTasks.startAsyncTask( function()	
		local prefs = LrPrefs.prefsForPlugin( nil )
		local appProfilePath = nil
		local appProfile = nil
		local x = 1
		for filePath in LrFileUtils.directoryEntries( _PLUGIN.path.."/Profiles/" ) do
			if LrPrefs.prefsForPlugin( nil )[ "appProfile" ] == x then
				appProfilePath = filePath
				appProfile = string.match( filePath, "/([^\/\?\#]+)\/*$" )
			end	
		end	
		
		local appSupport = LightroomTether.getApplicationSupportDir()
		local funcs = dofile( appProfilePath.."/"..appProfile..".lua" )
		if funcs.isDaemonRunning( appProfilePath ) == 0 then		
			-- get settings and start 
			local settings = funcs.getDaemonSettings( appProfilePath )
			if settings ~= nil then
				-- create evPipe
				local evPipePath = appSupport.."/events"
				LrTasks.execute( "mkfifo \""..evPipePath.."\"" )
				LrTasks.execute( "echo \"pass:\" > \""..evPipePath.."\" &" )
				
				funcs.startDaemon( appProfilePath, settings )
				LightroomTether.processEvents( appProfilePath, appProfile, evPipePath, funcs )
				
				LrTasks.execute( "rm \""..evPipePath.."\"" )
			end
		else
			funcs.stopDaemon( appProfilePath )
		end
	end )
end


-- Start/Stop the tethering session
LightroomTether.init()
