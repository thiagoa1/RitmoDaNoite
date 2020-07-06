system.activate( "multitouch" )

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

local composer = require("composer")
local fx = require( "com.ponywolf.ponyfx" )

local preference = require("preference")

local scene = composer.newScene()

local bgMusic
local idleChar
local spawnTimer

local missTimes

local hearts

local score
local scoreText

local enemyCount

-- local hitSound = audio.loadSound( "sfx/Boss hit 1.wav" )
local hitSound = audio.loadSound( "sfx/hit15.mp3.flac" )

-- local missSound = audio.loadSound( "sfx/Hit damage 1.wav" )
local missSound = audio.loadSound( "sfx/hit26.mp3.flac" )

local gruntSounds = {
    grunt1 = audio.loadSound( "sfx/ah.mp3" ),
    grunt2 = audio.loadSound( "sfx/ah2.mp3" ),
    grunt3 = audio.loadSound( "sfx/uh.mp3" )
}

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
local spawnedObjects
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
    spawnTime = 2000,
    spawnOnTimer = 50,
    spawnInitial = 1
}

local maxLifes = 5

local function onLocalCollision( self, event )
   -- if ( event.phase == "began" ) then
   local target = event.other
    print( self.name .. ": collision with " .. target.name )

    if (target.name == "char") then
        display.remove( self )

        if (self.name:find("^leftEnemy")) then
            if (target.sequence == "left_jump") then
                score = score + 10
                audio.play( hitSound )
            else
                missTimes = missTimes + 1
    
                display.remove(hearts[missTimes])
    
                audio.play( missSound )
                audio.play(gruntSounds[math.random(1, 3)])
    
                if (missTimes == maxLifes) then
                    gameover()
                end
            end
        elseif (self.name:find("^rightEnemy")) then
            if (target.sequence == "right_jump") then
                score = score + 10
                audio.play( hitSound )
            else
                missTimes = missTimes + 1
    
                display.remove(hearts[missTimes])
    
                audio.play( missSound )
                audio.play(gruntSounds[math.random(1, 3)])
    
                if (missTimes == maxLifes) then
                    gameover()
                end
            end
        end

        scoreText.text = score

        print( event.other.sequence )
    end
--    elseif ( event.phase == "ended" ) then
--        print( self.name .. ": collision ended with " .. event.other.name )
    --end
end

function gameover()
    preference.save{lastScore=score}

    spawnController(nil, "stop", nil )
    spawnTimer = nil
    hearts = nil
    for i, spawnObj in ipairs(spawnedObjects) do
        display.remove(spawnObj)
        print("Removing enemy: " .. spawnObj.name .. " ".. i )
    end
    spawnedObjects = nil

    composer.removeScene("gameover")
    composer.gotoScene("gameover")
end

-- Spawn an enemy
function spawnLeftEnemy(sceneGroup)
    local leftEnemy
    if (math.random() > 0.5 ) then
        leftEnemy = display.newSprite(sceneGroup, blueEnemy_run, enemy_sequence )
    else
        leftEnemy = display.newSprite(sceneGroup, greenEnemy_run, enemy_sequence )
    end

--    print("bounds: ", bounds.xMin, bounds.xMax, bounds.yMin, bounds.yMax)

    -- Position item randomly within set bounds
    --leftEnem.x = math.random( bounds.xMin, bounds.xMax )
    --leftEnem.y = math.random( bounds.yMin, bounds.yMax )
    leftEnemy.x = display.screenOriginX - math.random(0, 50)
    leftEnemy.y = display.contentCenterY + 80
    leftEnemy.xScale = 4
    leftEnemy.yScale = 4
    leftEnemy.name = "leftEnemy" .. enemyCount
    --idleChar.x = display.contentCenterX
    --idleChar.y = display.contentCenterY + 80
    leftEnemy:play()

    physics.addBody( leftEnemy, { density=3.0, friction=0.5, bounce=0.3 } )
    leftEnemy.collision  = onLocalCollision
    leftEnemy:addEventListener( "collision" )

    local rTime = 700 + math.random(0, 500)

    transition.to(leftEnemy, {x=display.contentCenterX, y=display.contentCenterY + 80, time=rTime})
    
    -- Add item to "spawnedObjects" table for tracking purposes
    spawnedObjects[enemyCount] = leftEnemy
    enemyCount = enemyCount + 1
end

function spawnRightEnemy(sceneGroup)
    local rightEnemy
    if (math.random() > 0.5 ) then
        rightEnemy = display.newSprite(sceneGroup, blueEnemy_run, enemy_sequence )
    else
        rightEnemy = display.newSprite(sceneGroup, greenEnemy_run, enemy_sequence )
    end

--    print("bounds: ", bounds.xMin, bounds.xMax, bounds.yMin, bounds.yMax)

    -- Position item randomly within set bounds
    --blueEnemy.x = math.random( bounds.xMin, bounds.xMax )
    --blueEnemy.y = math.random( bounds.yMin, bounds.yMax )
    rightEnemy.x = display.actualContentWidth + math.random(0, 350)
    rightEnemy.y = display.contentCenterY + 80
    rightEnemy.xScale = -4
    rightEnemy.yScale = 4
    rightEnemy.name = "rightEnemy" .. enemyCount
    --idleChar.x = display.contentCenterX
    --idleChar.y = display.contentCenterY + 80
    rightEnemy:play()

    physics.addBody( rightEnemy, { density=3.0, friction=0.5, bounce=0.3 } )
    rightEnemy.collision  = onLocalCollision
    rightEnemy:addEventListener( "collision" )

    local rTime = 1400 + math.random(0, 500)

    transition.to(rightEnemy, {x=display.contentCenterX, y=display.contentCenterY + 80, time=rTime})
    
    -- Add item to "spawnedObjects" table for tracking purposes
    spawnedObjects[enemyCount] = rightEnemy
    enemyCount = enemyCount + 1
end

function spawnController(sceneGroup, action, params )
     -- Cancel timer on "start" or "stop", if it exists
    if ( spawnTimer and ( action == "start" or action == "stop" ) ) then
        timer.cancel( spawnTimer )
    end
 
    -- Start spawning
    if ( action == "start" ) then
 
        -- Gather/set spawning bounds
        local leftSpawnBounds = {}
        leftSpawnBounds.xMin = params.xMin or 0
        leftSpawnBounds.xMax = params.xMax or display.actualContentWidth
        leftSpawnBounds.yMin = params.yMin or 0
        leftSpawnBounds.yMax = params.yMax or display.actualContentHeight
 
        -- Gather/set other spawning params
        local spawnTime = params.spawnTime or 1000
        local spawnOnTimer = params.spawnOnTimer -- or 50
        local spawnInitial = params.spawnInitial or 0
 
        -- If "spawnInitial" is greater than 0, spawn that many item(s) instantly
        if ( spawnInitial > 0 ) then
            for n = 1,spawnInitial do
                spawnLeftEnemy( sceneGroup )
            end
        end
 
        -- Start repeating timer to spawn items
        if ( spawnOnTimer > 0 ) then
            spawnTimer = timer.performWithDelay( spawnTime,
                function() spawnLeftEnemy(sceneGroup); spawnRightEnemy(sceneGroup); end,
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
        name = "left_jump",
        sheet = char_jump,
        --start = 1,
        --count = 4,
        frames= { 4, 3, 2, 1 }, -- frame indexes of animation, in image sheet
        time = 400,
        loopCount = 1,
        loopDirection = "forward"
    },
    {
        name = "right_jump",
        sheet = char_jump,
        --start = 1,
        --count = 4,
        frames= { 4, 3, 2, 1 }, -- frame indexes of animation, in image sheet
        time = 400,
        loopCount = 1,
        loopDirection = "forward"
    }
}

local function jump(left)
    if (left) then
        idleChar:setSequence( "left_jump" )
    else
        idleChar:setSequence( "right_jump" )
    end
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

function scene:create( event )
    local sceneGroup = self.view

    bgMusic = audio.loadSound( "music/ingame.mp3" )
    -- Code here runs when the scene is first created but has not yet appeared on screen

    local background = display.newImageRect(sceneGroup, "img/background.png", display.actualContentWidth, display.actualContentHeight )
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    spawnedObjects = {}
    missTimes = 0
    hearts = {}
    score = 0
    enemyCount = 0

    createControllers(sceneGroup)

    scoreText = display.newText(sceneGroup, score, 915, 35, native.systemFont, 50 )
    scoreText:setFillColor( 1, 1, 1  )

    for i=1, maxLifes do
        hearts[i] = display.newImage(sceneGroup, "img/life_48.png", display.contentCenterX - 340 - (48 * i), 45)
    end

    idleChar = display.newSprite(sceneGroup, char_idle, char_sequence )
    idleChar:addEventListener( "sprite", spriteListener )

    idleChar.xScale = 4
    idleChar.yScale = 4
    idleChar.x = display.contentCenterX
    idleChar.y = display.contentCenterY + 80
    idleChar.name = "char"
    idleChar:play()

    physics.addBody( idleChar, "static")

    spawnController( sceneGroup, "start", spawnParams )
    print(spawnTimer)
end

local function rightTapListener( event )
    -- Code executed when the button is tapped
    idleChar.xScale = 4
    jump(false)
    return true
end

local function leftTapListener( event )
    idleChar.xScale = -4
    jump(true)
    return true
end

function createControllers(sceneGroup)
    local rightButton = display.newCircle( sceneGroup, display.contentCenterX + 500, display.contentCenterY + 230, 100 )
    rightButton.strokeWidth = 3
    rightButton:setStrokeColor( 0, 0.5 )
    rightButton:setFillColor( 1, 0.53, 0.96, 0.5 )
    rightButton:addEventListener( "tap", rightTapListener )

    local leftButton = display.newCircle( sceneGroup, display.contentCenterX - 500, display.contentCenterY + 230, 100 )
    leftButton.strokeWidth = 3  
    leftButton:setStrokeColor( 0, 0.5 )
    leftButton:setFillColor( 1, 0.53, 0.96, 0.5 )
    leftButton:addEventListener( "tap", leftTapListener )
end

-- This function is called when scene comes fully on screen
function scene:show( event )
	local phase = event.phase
	if ( phase == "will" ) then
		fx.fadeIn()
		-- add enterFrame listener
    elseif ( phase == "did" ) then
        timer.performWithDelay( 10, function()
            audio.play( bgMusic, { loops = -1, channel = 3 } )
		    audio.fade({ channel = 3, time = 333, volume = 1.0 } )
		end)
	end
end

-- This function is called when scene goes fully off screen
function scene:hide( event )
	local phase = event.phase
	if ( phase == "will" ) then
		audio.fadeOut( { channel = 3, time = 333 } )
	elseif ( phase == "did" ) then
		
	end
end

function scene:destroy( event )
	audio.stop()  -- Stop all audio
	-- audio.dispose( bgMusic )  -- Release music handle
end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
