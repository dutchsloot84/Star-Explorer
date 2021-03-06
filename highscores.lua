
local composer = require( "composer" )

local scene = composer.newScene()

local font = "Arkitech Light.ttf"

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local json = require("json")
--Initiate table variable for scores
local scoresTable = {}
--Initiate file path to save json file to device Documents Directory
local filePath = system.pathForFile("scores.json", system.DocumentsDirectory)
--Initialize music
local musicTrack

local function loadScores()
  --Confirm if file exists in filePath. "r" open file as read only
  local file = io.open(filePath, "r")
  
  --If file exists then dump local variable 'contents' into file then close
  if file then
    local contents = file:read("*a")
    io.close(file)
    --Decode contents and store in scoresTable
    scoresTable = json.decode(contents)
  end
  --If file doesn't exist we assign scoresTable ten default values of 0
  if (scoresTable == nil or #scoresTable ==0) then
    scoresTable = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  end
end

local function saveScores()
  for i = #scoresTable, 11, -1 do
    table.remove(scoresTable, i)
  end
  --Variable to open file in filePath with 'w' = write access
  local file = io.open(filePath, "w")
  
  if file then
    file:write(json.encode(scoresTable))
    io.close(file)
  end
end

local function gotoMenu()
  composer.gotoScene("menu", {time=800, effect="crossFade"})
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
  
  --Load the previous scores
  loadScores()
  
  --Insert the saved score from the last game into the table, then reset it
  table.insert(scoresTable, composer.getVariable("finalScore"))
  composer.setVariable("finalScore", 0)
  
  --Sort the table entries from highest to lowest
  local function compare(a,b)
    return a>b
  end
  table.sort(scoresTable, compare)
  
  --Save the scores
  saveScores()
  
  local background = display.newImageRect(sceneGroup, "background.png", 800, 1400)
  background.x = display.contentCenterX
  background.y = display.contentCenterY
  
  local highScoresReader = display.newText(sceneGroup, "High Scores", display.contentCenterX, 100, font, 44)
  
  for i = 1, 10 do
    if (scoresTable[i]) then
      local yPos = 150 + (i * 56)
      
      local rankNum = display.newText(sceneGroup, i .. ")", display.contentCenterX-50, yPos, font, 36)
      rankNum:setFillColor(0.8)
      rankNum.anchorX = 1
      
      local thisScore = display.newText(sceneGroup, scoresTable[i], display.contentCenterX-30, yPos, font, 36)
      thisScore.anchorX = 0
    end
  end
  
  local menuButton = display.newText(sceneGroup, "Menu", display.contentCenterX, 810, font, 44)
  menuButton:setFillColor(0.75, 0.78, 1)
  menuButton:addEventListener("tap", gotoMenu)
  
  --Steam music
  musicTrack = audio.loadStream("audio/Midnight-Crawlers_Looping.wav")

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
    --Start the music
    audio.play(musicTrack, {channel=1, loops=-1})
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
    --Stop the music :(
    audio.stop(1)
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
  --Dispose of the audio
  audio.dispose(musicTrack)

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
