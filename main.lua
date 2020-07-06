-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )


-- Removes status bar on iOS
-- https://docs.coronalabs.com/api/library/display/setStatusBar.html
display.setStatusBar( display.HiddenStatusBar )

-- Removes bottom bar on Android 
if system.getInfo( "androidApiLevel" ) and system.getInfo( "androidApiLevel" ) < 19 then
	native.setProperty( "androidSystemUiVisibility", "lowProfile" )
else
	native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )
end

-- Are we running on the Corona Simulator?
-- https://docs.coronalabs.com/api/library/system/getInfo.html
local isSimulator = "simulator" == system.getInfo( "environment" )
local isMobile = ( "ios" == system.getInfo("platform") ) or ( "android" == system.getInfo("platform") )

-- If we are running in the Corona Simulator, enable debugging keys
-- "F" key shows a visual monitor of our frame rate and memory usage
if isSimulator then 

	-- Show FPS
	local visualMonitor = require( "com.ponywolf.visualMonitor" )
	local visMon = visualMonitor:new()
	visMon.isVisible = false

	local function debugKeys( event )
		local phase = event.phase
		local key = event.keyName
		if phase == "up" then
			if key == "f" then
				visMon.isVisible = not visMon.isVisible 
			end
		end
	end
	-- Listen for key events in Runtime
	-- See the "key" event documentation for more details:
	-- https://docs.coronalabs.com/api/event/key/index.html
	Runtime:addEventListener( "key", debugKeys )
end

system.activate("multitouch")

-- reserve music channel
audio.reserveChannels(4)

-- go to menu screen
-- composer.gotoScene( "menu" )

-- go to menu screen
composer.gotoScene( "menu", { params={ } } )

