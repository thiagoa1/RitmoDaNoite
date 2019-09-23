local composer = require( "composer" )

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

    local background = display.newImageRect(sceneGroup, "img/background.png", 1280, 800 )
--    background.fill.effect = "filter.blur"
    --background.fill.effect = "filter.blur"
    background.fill.effect = "filter.desaturate"
    background.fill.effect.intensity = 1
    
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local title = display.newImageRect(sceneGroup, "img/title.png", 600, 400 )
    
    title.x = display.contentCenterX
    title.y = 200

    local playButton = display.newText( sceneGroup, "Jogar", display.contentCenterX, display.contentCenterY + 50, native.systemFont, 44 )
    playButton:setFillColor( 1, 0.53, 0.96 )
    playButton:addEventListener( "tap", gotoGame )
 
    local rankingButton = display.newText( sceneGroup, "Ranking", display.contentCenterX, display.contentCenterY + 130, native.systemFont, 44 )
    rankingButton:setFillColor( 1, 0.53, 0.96 )
    --rankingButton:addEventListener( "tap", gotoHighScores )
end

scene:addEventListener( "create", scene )

return scene