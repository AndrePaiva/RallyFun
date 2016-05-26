-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------
local GBCDataCabinet = require("plugin.GBCDataCabinet")

-- forward declarations and other locals
local backBtn

-- 'onRelease' event listener for backBtn
local function onBackBtnRelease()
	
	-- go to level1.lua scene
	composer.gotoScene( "scenes.menu", "fade", 500 )
	
	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local background = display.newImageRect( "images/gameover.jpg", display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0

	--Display distance-------------------------------------------------------------------------------
	local success = GBCDataCabinet.load("Scores")
	print( success )
	local totalDistance = GBCDataCabinet.get("Scores", "score")

	local textX = display.contentWidth*0.3
	local textY = display.contentHeight - 270
	local textDistance = display.newText("DISTANCE: " ..totalDistance, textX, textY, "fonts/misterfirley.ttf", 48)
	
	-- create a widget button (which will loads menu.lua on release)
	backBtn = widget.newButton{
		defaultFile="buttons/btnMenu.png",
		width=254, height=60,
		onRelease = onBackBtnRelease	-- event listener function
	}
	backBtn.x = display.contentWidth*0.5
	backBtn.y = display.contentHeight - 75
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( backBtn )
	sceneGroup:insert( textDistance )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	if backBtn then
		backBtn:removeSelf()	-- widgets must be manually removed
		backBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene