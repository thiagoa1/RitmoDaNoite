local composer = require( "composer" )
local fx = require( "com.ponywolf.ponyfx" )

local bgMusic

local scene = composer.newScene()

local function gotoGame()
    composer.gotoScene( "game" )
end

local function gotoHighScores()
    composer.gotoScene( "highscores" )
end

function scene:create( event )
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    bgMusic = audio.loadStream("music/menu.mp3")


    local background = display.newImageRect(sceneGroup, "img/background.png", display.actualContentWidth, display.actualContentHeight )
--    background.fill.effect = "filter.blur"
    --background.fill.effect = "filter.blur"
    background.fill.effect = "filter.desaturate"
    background.fill.effect.intensity = 1
    
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local title = display.newImageRect(sceneGroup, "img/title.png", 600, 400 )
    
    title.x = display.contentCenterX
    title.y = 200

    local playButton = display.newText( sceneGroup, "Jogar", display.contentCenterX, display.contentCenterY + 80, native.systemFont, 44 )
    playButton:setFillColor( 1, 0.53, 0.96 )
    playButton:addEventListener( "tap", gotoGame )
 
    local rankingButton = display.newText( sceneGroup, "Ranking", display.contentCenterX, display.contentCenterY + 160, native.systemFont, 44 )
    rankingButton:setFillColor( 1, 0.53, 0.96 )
    --rankingButton:addEventListener( "tap", gotoHighScores )
end


local function enterFrame( event )

	local elapsed = event.time

end

-- This function is called when scene comes fully on screen
function scene:show( event )
	local phase = event.phase
	if ( phase == "will" ) then
		fx.fadeIn()
		-- add enterFrame listener
		--Runtime:addEventListener( "enterFrame", enterFrame )
    elseif ( phase == "did" ) then
        timer.performWithDelay( 10, function()
            audio.play( bgMusic, { loops = -1, channel = 1 } )
		    audio.fade({ channel = 1, time = 333, volume = 1.0 } )
		end)
	end
end

-- This function is called when scene goes fully off screen
function scene:hide( event )
	local phase = event.phase
	if ( phase == "will" ) then
        --start:removeEventListener( "tap" )
		audio.fadeOut( { channel = 1, time = 500 } )
	elseif ( phase == "did" ) then
		
	end
end

function scene:destroy( event )
	audio.stop()  -- Stop all audio
	audio.dispose( bgMusic )  -- Release music handle
--s	Runtime:removeEventListener("key", key)
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene