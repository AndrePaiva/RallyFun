-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- require the widget library
local widget = require "widget"

-- active multitouch
system.activate( "multitouch" )

-- require the physics library
local physics = require "physics"
--physics.setDrawMode( "hybrid" )
physics.start()
physics.setGravity( 0, 9.8 )

local vibrator = require('plugin.vibrator')

local GBCDataCabinet = require("plugin.GBCDataCabinet")


--------------------------------------------

-- forward declarations and other locals
-- constants
local screenW, screenH = display.actualContentWidth, display.actualContentHeight
local centerX, centerY = display.contentCenterX, display.contentCenterY
local originX, originY = display.screenOriginX, display.screenOriginY

-- variables
local horizontal = 0
local vertical = 0

local levelCellDistance = 112
local levelSimulatorDistance = 244

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	success = GBCDataCabinet.load("Scores")
	print( "load no level 3" )
	print( success )
	local totalDistance = GBCDataCabinet.get("Scores", "score")
	local inicialDistance = GBCDataCabinet.get("Scores", "score")

	-- set default screen background color to blue
	display.setDefault( "background", 197/255, 224/255, 220/255 )
	
	--Add elementos do cenario

	local imageFile = "maps/level3.png"
	local imageOutline = graphics.newOutline( 2, imageFile )
	local image = display.newImage( imageFile )
	image.anchorX, image.anchorY = 0, 1
	image.x, image.y = originX, originY + screenH

	physics.addBody( image, "static", { outline=imageOutline, bounce=0, friction=0.8 } )

	--------------------------------------------------------------------------------------------------------------
	-- Adicionado elementos do carro

	local car = display.newImageRect( "images/RenegadeV2.png", 105, 34 )
	car.x, car.y = centerX, centerY + 200
	car.myName = "car"
	physics.addBody( car, "dynamic", { density=1, friction=0.5, bounce=0.2, filter={ groupIndex=-1 } } )

	local rearWheel = display.newImageRect( "images/wheel.png", 27, 27 )
	rearWheel.x, rearWheel.y = car.x - 35, car.y + 24
	physics.addBody( rearWheel, "dynamic",
	    { density=1, friction=5, bounce=0.2, filter={ groupIndex=-1 }, radius=15 }
	)

	local frontWheel = display.newImageRect( "images/wheel.png", 27, 27 )
	frontWheel.x, frontWheel.y = car.x + 31, car.y + 24
	physics.addBody( frontWheel, "dynamic",
	    { density=1, friction=5, bounce=0.2, filter={ groupIndex=-1 }, radius=15 }
	)

	local collisionLine = display.newImageRect( "images/invisibleLine.png", 26, 1 )
	collisionLine.x, collisionLine.y = car.x -20, car.y - 17
	collisionLine.myName = "collisionLine"
	physics.addBody( collisionLine, "dynamic")


	--Variaveis para calcular Distancia
	local initialPoint = frontWheel.x

	-- Fazendo joint das rodas na carroceria

	local rearWheelJoint = physics.newJoint( "wheel", car, rearWheel, rearWheel.x, rearWheel.y, 0, 10 )
	rearWheelJoint.springDampingRatio = 1
	rearWheelJoint.springFrequency = 10

	local frontWheelJoint = physics.newJoint( "wheel", car, frontWheel, frontWheel.x, frontWheel.y, 0, 10 )
	frontWheelJoint.springDampingRatio = 1
	frontWheelJoint.springFrequency = 10

	local collisionLineJoint = physics.newJoint( "distance", collisionLine, car,  collisionLine.x, collisionLine.y, car.x -20, car.y - 17)

--ADD Sounds and Musics-------------------------------------------------------------------------------------------
	local accidentSound = audio.loadStream("sounds/car-accident.mp3")
	-- Add BackGround Music----------------------------------------------------------------------------------------

	local backgroundMusic = audio.loadStream( "sounds/foot_race.mp3" )
	local backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1 } )

	audio.setVolume( 0.30, { channel=1 } )

	-- Add Car Start Sound ----------------------------------------------------------------------------------------

	local starTCarSound = audio.loadStream("sounds/car-ignition-start.mp3")
	local starTCarSoundChannel = audio.play( starTCarSound, { channel=2, loops=0, duration=3000 } )


	-- Add Accelerartion Sound Effect -----------------------------------------------------------------------------

	local accelerationSound = audio.loadStream( "sounds/car_acceleration_with_one_long_rev.mp3" )	

	local function enterFrame( event )
	    if horizontal > 0 then
	        rearWheel:applyTorque( 10 )
	        frontWheel:applyTorque( 10 )
	    elseif horizontal < 0 then
	        rearWheel:applyTorque( -10 )
	        frontWheel:applyTorque( -10 )
	    end
		    
	    car:applyTorque( 80 * vertical )    
	    car.parent.x = centerX - car.x
	end
	Runtime:addEventListener( "enterFrame", enterFrame )


	--Add controles do carro e das rodas---------------------------------------------------------------------------

	local function controlHandler( event )
	    local id = event.target.id
	    local phase = event.phase
			    
	    if phase == "began" or phase == "moved" then
	        if id == "forward" then
	            horizontal = 1
	            accelerationSoundChannel()
	        elseif id == "backward" then
	            horizontal = -1
	            accelerationSoundChannel()
	        end
	        if id == "rotate-back" then
	            vertical = -1
	        elseif id == "rotate-forward" then
	            vertical = 1
	        end
	    else
	        if id == "forward" or id == "backward" then
	            horizontal = 0
	        end
	        if id == "rotate-back" or id == "rotate-forward" then
	            vertical = 0
	        end
	    end
	end

	local btnForward = widget.newButton{
    defaultFile = "buttons/btnRight.png",
    width=100, height=100,
    id="forward",
    onEvent=controlHandler
	}
	btnForward.x = originX + screenW - btnForward.height * 0.5 - 20
	btnForward.y = originY + screenH - btnForward.height * 0.5 - 20

	local btnBackward = widget.newButton{
	    defaultFile = "buttons/btnRight.png",
	    width=100, height=100,
	    id="backward",
	    onEvent=controlHandler
	}
	btnBackward.rotation = 180
	btnBackward.x = btnForward.x - btnForward.width - 40
	btnBackward.y = btnForward.y

	local btnRotBack = widget.newButton{
	    defaultFile = "buttons/btnRotate.png",
	    width=100, height=100,
	    id="rotate-back",
	    onEvent=controlHandler
	}
	btnRotBack.x = originX + btnRotBack.width * 0.5 + 15
	btnRotBack.y = originY + screenH - btnRotBack.height * 0.5 - 40
	btnRotBack.rotation = 180
	btnRotBack.yScale = -1

	local btnRotForward = widget.newButton{
	    defaultFile = "buttons/btnRotate.png",
	    width=100, height=100,
	    id="rotate-forward",
	    onEvent=controlHandler
	}
	btnRotForward.x = btnRotBack.x + btnRotForward.width + 30
	btnRotForward.y = originY + screenH - btnRotForward.height * 0.5 - 10
	btnRotForward.rotation = 180
	-- Add Accelerartion Sound Effect -----------------------------------------------------------------------------
	function accelerationSoundChannel()
	    audio.play( accelerationSound, { channel=3, loops=0, duration=2000 } )
	end
	audio.setVolume( 0.90, { channel=3 } )
	---------------------------------------------------------------------------------

	--Add medição de distância----------------------------------------------------------------------------------
	function frameUpdate()
	    local widthCar=car.width
	    local difference=car.x-initialPoint
	    if(difference>=widthCar) then 
	        initialPoint=car.x
	        totalDistance=totalDistance+4
	        updateText()
	        if (totalDistance >= levelCellDistance + inicialDistance) then
	        	success = GBCDataCabinet.load("Scores")
	        	print("Load ao chegar na distancia")
	        	print( success )
	        	if (success) then
	        		success = GBCDataCabinet.set("Scores", "score", totalDistance)
	        		print("Set ao chegar na distancia")
	        		print( success )
					if (success) then
						success = GBCDataCabinet.save("Scores")
						print("Save ao chegar na distancia")
	        			print( success )
					end
				end
				sceneGroup:removeSelf( )
		        btnRotForward:removeSelf( )
		        btnRotBack:removeSelf( )
		        btnForward:removeSelf( )
		        btnBackward:removeSelf( )
		        textdistance:removeSelf( )
		        audio.stop( backgroundMusicChannel )
		        Runtime:removeEventListener( "enterFrame", frameUpdate )
		        Runtime:removeEventListener( "enterFrame", enterFrame )
		        display.setDefault( "background", 0,0,0 )
		        composer.gotoScene( "scenes.level4", { effect = "fade", time = 200 } )
		        composer.removeHidden()
	        end
	    end
	end

	local function newText()
	    textdistance = display.newText("DISTANCE: "..totalDistance, 150, 20, "fonts/misterfirley.ttf", 34)
	    textdistance:setTextColor(0,0,0) 
	end 

	function updateText() 
	    textdistance.text = "DISTANCE: "..totalDistance
	end  

	newText()


	Runtime:addEventListener( "enterFrame", frameUpdate )

--Add Evento de colisão do carro----------------------------------------------------------------------------------

	local accidentSound = audio.loadStream("sounds/car-accident.mp3")

	function onCollision(self, event)
	    if(event.target.myName == "collisionLine") then 
	        audio.play(accidentSound)
	        vibrator.vibrate(1000)
	        success = GBCDataCabinet.load("Scores")
	        print( success )
	        if (success) then
	        	local dbvalue = GBCDataCabinet.get("Scores", "score")
	        	if (dbvalue == not nil) then
	        		print( "DBValue: " ..dbvalue )
	        		print( "Total distance: " ..totalDistance )
	        		if (dbvalue < totalDistance) then
	        			print( "DBValue menor que totalDistance" )
	        			success = GBCDataCabinet.set("Scores", "score", totalDistance)
	        			if (success) then
	        				success = GBCDataCabinet.save("Scores")
	        			end
	        		end
	        		print( "DBValue maior que totalDistance" )
	        	else
	        		success = GBCDataCabinet.set("Scores", "score", totalDistance)
	        		if (success) then
	        			success = GBCDataCabinet.save("Scores")
	        			print( "DBValue vazio salvando com totalDistance" )
	        		end
	        	end	        	
	        end
	        print( totalDistance )
	        print(screenW)
	        print(screenH)
	        print( "HIT" )
	        
	        sceneGroup:removeSelf( )
	        btnRotForward:removeSelf( )
	        btnRotBack:removeSelf( )
	        btnForward:removeSelf( )
	        btnBackward:removeSelf( )
	        textdistance:removeSelf( )
	        audio.stop( backgroundMusicChannel )
	        audio.stop( starTCarSound )
	        Runtime:removeEventListener( "enterFrame", frameUpdate )
	        Runtime:removeEventListener( "enterFrame", enterFrame )
	        display.setDefault( "background", 0,0,0 )
	        composer.gotoScene( "scenes.gameOver", { effect = "fade", time = 300 } )
	        composer.removeHidden()
	    end
	end
	collisionLine.collision = onCollision
	collisionLine:addEventListener( "collision", collisionLine )

-- all display objects must be inserted into group
	sceneGroup:insert( image )
	
	sceneGroup:insert( car )
	sceneGroup:insert( rearWheel )
	sceneGroup:insert( frontWheel ) 
	sceneGroup:insert( collisionLine )
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

		physics.start()
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
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


-----------------------------------------------------------------------------------------

return scene