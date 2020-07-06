local composer = require( "composer" )
local fx = require( "com.ponywolf.ponyfx" )

local preference = require("preference")

local bgMusic

local scene = composer.newScene()

local function gotoMenu()
    composer.removeScene("menu")
    composer.gotoScene("menu")
end

local highScoreIndex

function getNewHighscoreIndex(lastScore)
    highscoresPref = preference.getValue("highscores")

    newScoreIndex = -1
    previousScore = 0
    isNewHighScore = false

    newHighscoresPref = {0,0,0,0,0}

    for i, score in ipairs(highscoresPref) do
        print(i .. " : " .. score)
        if (lastScore > score and newScoreIndex == -1) then
            print("lastScore > score and newScoreIndex == -1")
            newScoreIndex = i
            newHighscoresPref[i] = lastScore
        elseif (lastScore > score and newScoreIndex ~= -1) then
            print("lastScore > score and newScoreIndex ~= -1")
            newHighscoresPref[i] = highscoresPref[i - 1]
        else
            print("else")
            newHighscoresPref[i] = score
        end
    end

    for i, score in ipairs(newHighscoresPref) do
        print(i .. " : " .. score)
    end

    preference.save{highscores=newHighscoresPref}
    -- TODO

    return newScoreIndex
end

local function scoreNameTextListener( event )
 
    if ( event.phase == "began" ) then
        -- User begins editing "defaultField"
 
    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
        -- Output resulting text from "defaultField"
        print( event.target.text )
        highscoreNamesPref = preference.getValue("highscoresNames")
        highscoreNamesPref[highScoreIndex] = event.target.text
        preference.save{highscoresNames=highscoreNamesPref}
 
    elseif ( event.phase == "editing" ) then
        highscoreNamesPref = preference.getValue("highscoresNames")
        highscoreNamesPref[highScoreIndex] = event.target.text
        preference.save{highscoresNames=highscoreNamesPref}
        --print( event.newCharacters )
        --print( event.oldText )
        --print( event.startPosition )
        --print( event.text )
    end
end

function scene:create( event )
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    local background = display.newImageRect(sceneGroup, "img/background.png", display.actualContentWidth, display.actualContentHeight)
--    background.fill.effect = "filter.blur"
    --background.fill.effect = "filter.blur"
    background.fill.effect = "filter.desaturate"
    background.fill.effect.intensity = 1
    
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local gameover = display.newImageRect(sceneGroup, "img/gameover.png", 600, 400)
    
    gameover.x = display.contentCenterX
    gameover.y = 200

    local lastScore = preference.getValue("lastScore")

    highScoreIndex = getNewHighscoreIndex(lastScore)

    if (highScoreIndex ~= -1) then
        bgMusic = audio.loadStream("music/ending.mp3")

        local scoreText = display.newText(sceneGroup, "Novo Score!: " .. highScoreIndex .. "º  " .. tostring(lastScore), display.contentCenterX, display.contentCenterY + 50, native.systemFont, 56)
        scoreText:setFillColor( 0.76, 1, 0.72 )

        local scoreNameField = native.newTextField(display.contentCenterX, display.contentCenterY + 150, 180, 50 )
        scoreNameField:addEventListener( "userInput", scoreNameTextListener )
        sceneGroup:insert(scoreNameField)
    else
        bgMusic = audio.loadStream("music/sad_ending.mp3")

        local scoreText = display.newText(sceneGroup, "Pontuação: " .. tostring(lastScore), display.contentCenterX, display.contentCenterY + 50, native.systemFont, 56)
        scoreText:setFillColor( 0.76, 1, 0.72 )
    end

    local playButton = display.newText(sceneGroup, "Menu", display.contentCenterX, display.contentCenterY + 250, native.systemFont, 44)
    playButton:setFillColor( 0.76, 1, 0.72 )
    playButton:addEventListener( "tap", gotoMenu )
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
            audio.play( bgMusic, { loops = -1, channel = 4 } )
		    audio.fade({ channel = 4, time = 333, volume = 1.0 } )
		end)
	end
end

-- This function is called when scene goes fully off screen
function scene:hide( event )
	local phase = event.phase
	if ( phase == "will" ) then
        --start:removeEventListener( "tap" )
		audio.fadeOut( { channel = 4, time = 333 } )
	elseif ( phase == "did" ) then
	end
end

function scene:destroy( event )
    audio.stop()  -- Stop all audio
	-- audio.dispose( bgMusic )  -- Release music handle
--s	Runtime:removeEventListener("key", key)
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene