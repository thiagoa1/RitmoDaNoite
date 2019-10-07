system.activate( "multitouch" )
local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

local composer = require("composer")
local scene = composer.newScene()

local charOptions = {
    width = 71,
    height = 67,
    numFrames = 4,
    sheetContentWidth = 142,
    sheetContentHeight = 134
}

local char8Options = {
    width = 71,
    height = 67,
    numFrames = 8,
    sheetContentWidth = 284,
    sheetContentHeight = 134
}

local char_idle = graphics.newImageSheet( "player/idle/idle.png", charOptions )

local char_jump = graphics.newImageSheet( "player/jump/jump.png", charOptions )

-- ============================== Spawn de inimigos
local spawnTimer
local spawnedObjects = {}
-- Seed the random number generator
math.randomseed( os.time() )

local blueEnemy_run = graphics.newImageSheet( "player/run/run_blue.png", char8Options )
local greenEnemy_run = graphics.newImageSheet( "player/run/run_green.png", char8Options )

local enemy_sequence = {
    -- consecutive frames sequence
    {
        name = "run",
        sheet = char_idle,
        start = 1,
        count = 8,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    }
}

local spawnParams = {
    xMin = 20,
    xMax = 300,
    yMin = 20,
    yMax = 460,
    spawnTime = 500,
    spawnOnTimer = 12,
    spawnInitial = 4
}

--local bounds = {
--    xMin = 0,
--    xMax = display.contentWidth,
--    yMin = 0,
--    yMax = display.contentHeight,
--}

local function onLocalPreCollision( self, event )
   -- if ( event.phase == "began" ) then
        display.remove( self )
        print( self.name .. ": precollision with " .. event.other.name )

 
--    elseif ( event.phase == "ended" ) then
--        print( self.name .. ": collision ended with " .. event.other.name )
    --end
end

local enemyCount = 0

-- Spawn an enemy
local function spawnBlueEnemy()

    -- Create an item
    local blueEnemy = display.newSprite( blueEnemy_run, enemy_sequence )

--    print("bounds: ", bounds.xMin, bounds.xMax, bounds.yMin, bounds.yMax)

    -- Position item randomly within set bounds
    --blueEnemy.x = math.random( bounds.xMin, bounds.xMax )
    --blueEnemy.y = math.random( bounds.yMin, bounds.yMax )
    blueEnemy.x = display.screenOriginX
    blueEnemy.y = display.contentCenterY + 80
    blueEnemy.xScale = 4
    blueEnemy.yScale = 4
    blueEnemy.name = "blueEnemy" .. enemyCount
    --idleChar.x = display.contentCenterX
    --idleChar.y = display.contentCenterY + 80
    blueEnemy:play()

    physics.addBody( blueEnemy, { density=3.0, friction=0.5, bounce=0.3 } )
    blueEnemy.preCollision  = onLocalPreCollision
    blueEnemy:addEventListener( "preCollision" )

    transition.to(blueEnemy, {x=display.contentCenterX, y=display.contentCenterY + 80, time=1000})
    
    -- Add item to "spawnedObjects" table for tracking purposes
    spawnedObjects[enemyCount] = blueEnemy
    enemyCount = enemyCount + 1
end

local function spawnController( action, params )
 
    -- Cancel timer on "start" or "stop", if it exists
    if ( spawnTimer and ( action == "start" or action == "stop" ) ) then
        timer.cancel( spawnTimer )
    end
 
    -- Start spawning
    if ( action == "start" ) then
 
        -- Gather/set spawning bounds
        local spawnBounds = {}
        spawnBounds.xMin = params.xMin or 0
        spawnBounds.xMax = params.xMax or display.actualContentWidth
        spawnBounds.yMin = params.yMin or 0
        spawnBounds.yMax = params.yMax or display.actualContentHeight
 
        -- Gather/set other spawning params
        local spawnTime = params.spawnTime or 1000
        local spawnOnTimer = params.spawnOnTimer or 50
        local spawnInitial = params.spawnInitial or 0
 
        -- If "spawnInitial" is greater than 0, spawn that many item(s) instantly
        if ( spawnInitial > 0 ) then
            for n = 1,spawnInitial do
                spawnBlueEnemy( )
            end
        end
 
        -- Start repeating timer to spawn items
        if ( spawnOnTimer > 0 ) then
            spawnTimer = timer.performWithDelay( spawnTime,
                function() spawnBlueEnemy(); end,
            spawnOnTimer )
        end
 
    -- Pause spawning
    elseif ( action == "pause" ) then
        timer.pause( spawnTimer )
 
    -- Resume spawning
    elseif ( action == "resume" ) then
        timer.resume( spawnTimer )
    end
end

-- ============================== Spawn de inimigos

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

    local background = display.newImageRect(sceneGroup, "img/background.png", display.actualContentWidth, display.actualContentHeight )

    background.x = display.contentCenterX
    background.y = display.contentCenterY

    idleChar.xScale = 4
    idleChar.yScale = 4
    idleChar.x = display.contentCenterX
    idleChar.y = display.contentCenterY + 80
    idleChar.name = "char"
    idleChar:play()

    physics.addBody( idleChar, { density=3.0, friction=100, bounce=0 } )

    -- spawnBlueEnemy()
    spawnController( "start", spawnParams )
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