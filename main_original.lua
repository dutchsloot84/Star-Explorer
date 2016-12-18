-----------------------------------------------------------------------------------------
--
-- main.lua
--Star Explorer - Corona Learning Project
-----------------------------------------------------------------------------------------

--Require physics engine, turn it on, and setGravity to (0, 0)
local physics = require("physics")
physics.start()
physics.setGravity(0, 0)

--Seed the random number generator.
math.randomseed(os.time())

-- Configure image sheet. Use Texture Packer for file compression and easier creation of sheets
local sheetOptions =
{
    frames =
    {
        {   -- 1) asteroid 1
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        {   -- 2) asteroid 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {   -- 3) asteroid 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        {   -- 4) ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {   -- 5) laser
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    }
}

--load sprite sheet
local objectSheet = graphics.newImageSheet("gameObjects.png", sheetOptions)

--Initialize variables
local lives = 3
local score = 0
local died = false

--Initialize asteroids table
local asteroidsTable = {}

local ship
local gameLoopTimer
local livesText
local scoreText

--Set up display groups
local backGroup = display.newGroup() --Display group for background image(s)
local mainGroup = display.newGroup() --Display group for the ship, asteroids, lasers, etc.
local uiGroup = display.newGroup()   --Display group for UI objects like the score and lives

-- Load the background. Add to backGroup group
local background = display.newImageRect(backGroup, "background.png", 800, 1400)
background.x = display.contentCenterX
background.y = display.contentCenterY

-- Load the ship. Add to mainGroup group
ship = display.newImageRect(mainGroup, objectSheet, 4, 98, 79)
-- Set screen location of ship, add physics, set to isSensor to detect collision with asteroids but 
-- do not bounce off of them, and finally specify a name for the ship
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100
physics.addBody(ship, {radius=30, isSensor=true})
ship.myName = "ship"

--Display lives and score
livesText = display.newText(uiGroup, "Lives: " .. lives, 200, -100, native.systemFont, 36)
scoreText = display.newText(uiGroup, "Score: " .. score, 400, -100, native.systemFont, 36)

-- Hide the status bar. Not showing in simulator but may need to be uncommented for real devices
display.setStatusBar( display.HiddenStatusBar )

local function updateText()
  livesText.text = "Lives: " .. lives
  scoreText.text = "Score: " .. score
end

--Create asteroid function
local function createAsteroid()
  local newAsteroid = display.newImageRect(mainGroup, objectSheet, 1, 102, 85)
  --Insert new asteroid into asteroidsTable
  table.insert(asteroidsTable, newAsteroid)
  --Add physics to the new asteroid
  physics.addBody(newAsteroid, "dynamic", {radius=40, bounce=0.8})
  --Assign name to asteroid
  newAsteroid.myName = "asteroid"
  --Random number 1 to 3 to determine where asteroid will spawn (left, top, or right of screen)
  local whereFrom = math.random(3)
  
  if (whereFrom == 1) then
    -- Spawn asteroid from the left
    newAsteroid.x = -60
    newAsteroid.y = math.random(500)
    newAsteroid:setLinearVelocity(math.random(40, 120), math.random(20, 60))
    
    elseif ( whereFrom == 2 ) then
    -- Spawn asteroid from the top
    newAsteroid.x = math.random( display.contentWidth )
    newAsteroid.y = -60
    newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    
    elseif ( whereFrom == 3 ) then
    -- Spawn asteroid from the right
    newAsteroid.x = display.contentWidth + 60
    newAsteroid.y = math.random( 500 )
    newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
  end
  newAsteroid:applyTorque(math.random(-6, 6))
end

--Fire laser function
local function fireLaser()
  --Load laser and add to mainGroup
  local newLaser = display.newImageRect(mainGroup, objectSheet, 5, 14, 40)
  --Add physics body to laser, set to dynamic, isSensor= true for collision detection
  physics.addBody(newLaser, "dynamic", {isSensor=true})
  --isBullet = true for constant collision detection instead of periodic
  newLaser.isBullet = true
  --Set laser name
  newLaser.myName = "laser"
  --Set laser position to ships x, y
  newLaser.x = ship.x
  newLaser.y = ship.y
  --Set laser behind ship
  newLaser:toBack()
  --move laser to -40 (slightly off screen) within 500 miliseconds (1/2 second). Cleanup laser from stage 
  --when these requirements are met.
  transition.to(newLaser, {y=-40, time=500,
    onComplete = function() display.remove(newLaser) end
    })
end

--Create tap listener for ship
ship:addEventListener("tap", fireLaser)

--Function to touch and drag the ship left/right
local function dragShip(event)
  local ship = event.target
  local phase = event.phase
  
  if ("began" == phase) then
    --Set touch focus on the ship
    display.currentStage:setFocus(ship)
    --Store initial offset position
    ship.touchOffsetX = event.x - ship.x
    
  elseif ("moved" == phase) then
    --Move the ship to the new touch position
    ship.x = event.x -ship.touchOffsetX
  
  elseif ("ended" == phase) then
    --Release touch focus on ship
    display.currentStage:setFocus(nil)
  end
  return true --Prevents touch propogation to underlying objects
end
--Assign touch listener to ship
ship:addEventListener("touch", dragShip)

--Game loop
local function gameLoop()
  --Create new asteroid
  createAsteroid()
  
  --Remove asteroids which have drifted off screen
  --Loop through asteroidsTable. #asteroidsTable '#' is a method that counts the elements in a table.
  --Arg 1: i = total number of elements in table, Arg 2: stop at element 1, Arg 3: decrement by 1
  for i = #asteroidsTable, 1, -1 do
    --Local reference to the current asteroid 'i'
    local thisAsteroid = asteroidsTable[i]
    
    if(thisAsteroid.x < -100 or
       thisAsteroid.x > display.contentWidth + 100 or
       thisAsteroid.y < -100 or
       thisAsteroid.y > display.contentHeight + 100)
    then
      --Remove asteroid from stage
       display.remove(thisAsteroid)
       --Remove asteroid from table
       table.remove(asteroidsTable, i)
    end
  end
end
--game loop timer. Delay every 1/2 second, call gameLoop, iterations = 0 (infinite)
gameLoopTimer = timer.performWithDelay(500, gameLoop, 0)

local function restoreShip()
  --Remove ship from physics simulation while being stored (invincibility)
  ship.isBodyActive = false
  --Reset linear velocity to 0. Cancel any velocity the ship may have had from collision
  ship:setLinearVelocity(0, 0)
  --Reposition ship at bottom center of screen
  ship.x = display.contentCenterX
  ship.y = display.contentHeight - 100
  
  --Fade in the ship. Fade in from 0 alpha to 1 over 4 seconds. On complete, set the ship to active body
  --so it can detect collision, reset died to false
  transition.to( ship, {alpha=1, time=4000,
      onComplete = function()
        ship.isBodyActive = true
        died = false
      end
  } ) 
end

local function onCollision(event)
  if(event.phase == "began") then
    local obj1 = event.object1
    local obj2 = event.object2
    
    if((obj1.myName == "laser" and obj2.myName == "asteroid") or 
       (obj1.myName == "asteroid" and obj2.myName == "laser"))
    then
      --Remove both the laser and asteroid
      display.remove(obj1)
      display.remove(obj2)
      
      for i = #asteroidsTable, 1, -1 do
        if (asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2) then
          table.remove(asteroidsTable, i)
          break
        end
      end
      
      --Increase score
      score = score + 100
      scoreText.text = "Score: " .. score
    elseif ((obj1.myName == "ship" and obj2.myName == "asteroid") or
            (obj1.myName == "asteroid" and obj2.myName == "ship"))
    then
        if (died == false) then
          died = true
          
          --Update lives
          lives = lives - 1
          livesText.text = "Lives: " .. lives
          
          if (lives == 0) then
            display.remove(ship)
          else
            ship.alpha = 0
            timer.performWithDelay(1000, restoreShip)
          end
        end
    end
  end
end
--Collision event listener
Runtime:addEventListener("collision", onCollision)
