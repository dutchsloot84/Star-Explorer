-----------------------------------------------------------------------------------------
--
-- main.lua
--Star Explorer - Corona Learning Project - Composer
-----------------------------------------------------------------------------------------

--Require Composer. API for moving from scene to scene
local composer = require("composer")

--Hide Status bar
display.setStatusBar(display.HiddenStatusBar)

--Seed the random number generator
math.randomseed(os.time())

--Reserve Channel 1 for background music
audio.reserveChannels(1)
--Reduce the overall volume of the channel
audio.setVolume(0.5, {channel=1})
--Go to the menu screen
composer.gotoScene("menu")