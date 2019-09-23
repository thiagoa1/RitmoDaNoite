local composer = require( "composer" )

system.activate( "multitouch" )

local scene = composer.newScene()

local charOptions =
{
    width = 71,
    height = 67,
    numFrames = 4,
    sheetContentWidth = 142,
    sheetContentHeight = 134
}

local char_idle = graphics.newImageSheet( "player/idle/idle.png", charOptions )

local char_jump = graphics.newImageSheet( "player/jump/jump.png", charOptions )

local char_sequence = {
    -- consecutive frames sequence
    {
        name = "idle",
        sheet = char_idle,
        start = 1,
        count = 4,
        time = 400,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "jump",
        sheet = char_jump,
        start = 1,
        count = 4,
        time = 400,
        loopCount = 1,
        loopDirection = "forward"
    }
}

local idleChar = display.newSprite( char_idle, char_sequence )


local function jump()
    idleChar:setSequence( "jump" )
    idleChar:play()
    --idleChar:setSequence( "idle" )
    --idleChar:play()
end

local function spriteListener( event ) 
    local thisSprite = event.target  -- "event.target" references the sprite
 
    -- Go back to idle
    if ( event.phase == "ended" ) then
        thisSprite:setSequence( "idle" )  -- switch to "fastRun" sequence
        thisSprite:play()  -- play the new sequence
    end
end
idleChar:addEventListener( "sprite", spriteListener )

function scene:create( event )
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    local background = display.newImageRect(sceneGroup, "img/background.png", 1280, 800 )

    background.x = display.contentCenterX
    background.y = display.contentCenterY

    idleChar.xScale = 4
    idleChar.yScale = 4
    idleChar.x = display.contentCenterX
    idleChar.y = display.contentCenterY + 80
    idleChar:play()

end

local function rightTapListener( event )
    -- Code executed when the button is tapped
    idleChar.xScale = 4
    jump()
    return true
end

local function leftTapListener( event )
    idleChar.xScale = -4
    jump()
    return true
end
 
local rightButton = display.newCircle( display.contentCenterX + 500, display.contentCenterY + 230, 100 )
rightButton.strokeWidth = 3
rightButton:setStrokeColor( 0, 0.5 )
rightButton:setFillColor( 1, 0.53, 0.96, 0.5 )
rightButton:addEventListener( "tap", rightTapListener )

local leftButton = display.newCircle( display.contentCenterX - 500, display.contentCenterY + 230, 100 )
leftButton.strokeWidth = 3  
leftButton:setStrokeColor( 0, 0.5 )
leftButton:setFillColor( 1, 0.53, 0.96, 0.5 )
leftButton:addEventListener( "tap", leftTapListener )

scene:addEventListener( "create", scene )

return scene