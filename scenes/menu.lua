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

-- forward declarations and other locals
local playBtn

local credBtn

local selectSound = audio.loadStream("sounds/car_chirp.mp3")

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	audio.play(selectSound, {channel=4, loops = 1})
	composer.gotoScene( "scenes.level1", "fade", 500 )
	composer.removeHidden()
	
	return true	-- indicates successful touch
end

-- 'onRelease' event listener for credBtn
local function onCredBtnRelease()
	
	-- go to level1.lua scene
	audio.play(selectSound, {channel=4})
	composer.gotoScene( "scenes.creditsScreen", "fade", 500 )
	composer.removeHidden()
	
	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local background = display.newImageRect( "images/jeepWheelCartoon.jpg", display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0
	
	-- create/position logo/title image on upper-half of the screen
	local rallyLogo = display.newImage( "images/rallyText.png" )
	rallyLogo:scale( 1.5, 1.5 )
	rallyLogo.x = display.contentWidth * 0.25
	rallyLogo.y = 100

	local funLogo = display.newImage( "images/funText.png" )
	funLogo:scale( 1.5, 1.5 )
	funLogo.x = rallyLogo.x * 1.1
	funLogo.y = rallyLogo.y *2.5
	
	-- create a widget button (which will loads level1.lua on release)
	playBtn = widget.newButton{
		defaultFile="buttons/btnPlay.png",
		width=254, height=60,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = display.contentWidth*0.2
	playBtn.y = display.contentHeight - 270

	-- create a widget button (which will loads creditsScreen.lua on release)
	credBtn = widget.newButton{
		defaultFile="buttons/btnCredits.png",
		width=254, height=60,
		onRelease = onCredBtnRelease	-- event listener function
	}
	credBtn.x = display.contentWidth*0.2
	credBtn.y = display.contentHeight - 130
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( rallyLogo )
	sceneGroup:insert( funLogo )
	sceneGroup:insert( playBtn )
	sceneGroup:insert( credBtn )
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
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end

	if credBtn then
		credBtn:removeSelf()	-- widgets must be manually removed
		credBtn = nil
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