extends CharacterBody2D
class_name Player

signal goalTouched

@export var speed : float = 200.0
@export var jump_velocity : float = -400.0
@export var double_jump_velocity : float = -300.0
@export var max_double_jumps: int = 1
@export var launchMultiplier : float = 1050
@export var airResistance : float = 1.015
@export var groundResistance : float = 1.2
@export var wallBounciness : float = .065
@export var clickSpeed : float = .2
@export var spriteScale : int = 2
@export var spriteStretch : float = 1
@export var snapAmount : float = .01
@export var isTesting : bool = false
@export var specialTilesPath : String = "res://scripts/SpecialObjects/"
@export var bulletOffset : float = 0
@export var gameSpeed : float = 1

#@export var extraAirResistance`Threshold : float = 750

 #Your motherings ssss read
@onready var rootNode = get_parent().get_parent().get_parent() #get_node("/root/Node2D")
@onready var bulletsFired = rootNode.bulletsFired
@onready var timeElapsed = rootNode.timeElapsed
@onready var startTimer = rootNode.startTimer
@onready var Filepath = rootNode.scene_file_path
@onready var camera = rootNode.get_node("Camera3D")

var SHOTGUN_PARTICLES = preload("res://scripts/shotgun_particles.tscn")
var BULLET = preload("res://scripts/Bullet.tscn")

const TILESET_LIB = preload("res://scripts/Libraries/TilesetLib.gd")
const GENERAL_LIB = preload("res://scripts/Libraries/GeneralLib.gd")

var double_jumps : int = 0
var velocityLaunch = Vector2(0,0)
var lastFrameVelocityLaunch = Vector2(0,0)
var extraVelocity = Vector2(0,0)
var lastFrameExtraVelocity = Vector2(0,0)
var beforedir : int = 0
@export var acc = 20
var walkvelocity :  Vector2 = Vector2.ZERO
var acceleration : Vector2 = Vector2.ZERO
var mousePosition = Vector2(0,0)
var mousePlayerAngle : float = 0 #the angle between the mouse and the player

var enableGroundResistance : bool = true
var enableAirResistance : bool = true
var enableShooting : bool = true
var enableRotation : bool = true

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var player_state : AnimationPlayer = $PlayerState
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var shoot_cooldown_timer : Timer = $ShootCooldownTimer
@onready var idle_timer : Timer = $IdleTimer
@onready var gun_sprite : AnimatedSprite2D = $Gun/Offset/GunSprite
@onready var gun_animation_player : AnimationPlayer = $Gun/GunAnimationPlayer

@onready var mainScale : float = get_parent().scale.x

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var animation_locked : bool = false
var direction : Vector2 = Vector2.ZERO
var is_double_jumping : bool = false

var clickBuffer : bool = false
var canClick : bool = true
var deltaGlobal : float = 0.00

var lastIdleRandom : int = -1

var gunReloaded : bool = false

var specialTilesDict : Dictionary

var testingData : Dictionary = {"velocityLaunch" : [],
								"extraVelocity" : []}

@onready var tileMap = get_node("/root/Node3D/MainSubviewport/TileMap")


func getPos() -> Vector2:
	return scale
	
func _ready():
	animated_sprite.play("idle")
	player_state.play("idle")
	loadScenes()
	gameSpeed = 1
	
func loadScenes():
	pass
	
func _physics_process(delta):
	deltaGlobal = delta
	
	lastFrameVelocityLaunch = velocityLaunch
	lastFrameExtraVelocity = extraVelocity
	
	if !(isPlayerStatic()):
		velocity.y = velocityLaunch.y + extraVelocity.y
	
	# Add the gravity.
	if is_on_floor():
		animation_locked = false
		is_double_jumping = false
	
	else:
		animation_locked = true
		
		#gravity
		velocity.y += gravity * delta #old
		#velocityLaunch.y += (gravity * delta) * GENERAL_LIB.percentageOf(velocityLaunch.y, extraVelocity.y)
		#velocity.y = velocityLaunch.y + extraVelocity.y
		
		
		#kinda useless code lol
		if is_double_jumping == false:
			if velocity.y > 0:
				#animated_sprite.play("fall")
				pass
			else:
				#animated_sprite.play("jump")
				pass
		else:
			#animated_sprite.play("double jump")
			pass
	
	
	# Handle Jump (more useless code)
	if Input.is_action_just_pressed("jump"):
		startTimer = true
		if is_on_floor():
			jump()
		elif double_jumps > 0:
			is_double_jumping = true
			velocity.y = double_jump_velocity
			double_jumps -= 1
	
	
	#gets position of mouse
	updateMousePosition()
	
	#if player left clicks run left click code
	#if Input.is_action_just_pressed("mouseLeftClick"):
		#mouseLeftClick()
	
	
	#more useless code lmao
	#direction = Input.get_vector("left", "right", "up", "down")
	direction = Vector2(sign(direction.x), sign(direction.y))
	
	#if direction.x: #checks if input has been pressed
		#startTimer = true
		#beforedir = direction.x
		#if direction.x == 1:
			#walkvelocity.x = min(walkvelocity.x + acc, speed)
		#else:
			#walkvelocity.x = max(walkvelocity.x - acc, -speed)
	#else:
		#if beforedir == 1:
			#walkvelocity.x = max(walkvelocity.x - acc*5, 0)
		#else:
			#walkvelocity.x = min(walkvelocity.x + acc*5, 0)
		#pass
	
	addAirResistance()
	addWallBounce()
	updateTimer()
	
	velocity.x = walkvelocity.x + velocityLaunch.x + extraVelocity.x
	#DO NOT MOVE THIS
	
	update_animation()
	update_facing_direction()
	idleAnimation()
	updateSpriteStretching()
	setGameSpeed(gameSpeed)
	
	velocity *= mainScale
	move_and_slide()
	velocity /= mainScale
	
	var oldVelocityLaunch = velocityLaunch
	if isPlayerStatic():
		velocityLaunch.y = velocity.y
	else:
		velocityLaunch.y = velocity.y * GENERAL_LIB.percentageOf(velocityLaunch.y, extraVelocity.y)
	extraVelocity.y = velocity.y * GENERAL_LIB.percentageOf(extraVelocity.y, oldVelocityLaunch.y)
	
	if Input.is_action_just_pressed("mouseLeftClick"):
		mouseLeftClick()
	
	roundVars()
	
	reloadGun()
	
	#createTestingData()

func isPlayerStatic() -> bool:
	return (velocityLaunch.y == 0 and extraVelocity.y == 0)

func createTestingData():
	if Input.is_action_just_pressed("up"):
		print(testingData["velocityLaunch"])
		print("")
		print(testingData["extraVelocity"])
		
	testingData["velocityLaunch"].append(velocityLaunch.y)
	testingData["extraVelocity"].append(extraVelocity.y)
	
	pass
	
func setGameSpeed(gameSpeed: float):
	Engine.time_scale = gameSpeed

	
func reloadGun():
	#reloads gun
	
	#if player is on floor and has not already reloaded their gun, reload the gun
	if is_on_floor() and !(gunReloaded) and ($JustShotTimer.time_left == 0):
		
		#plays animation
		gun_sprite.play("shotgun_reload")
		$Gun/ShotgunReload.play()
		
		#for preventing reloading more than once
		gunReloaded = true
		
		
		
func roundVars():
	#rounds vars to prevent having rlly small numbers (like 0.000000001), allows character to actually stop
	
	velocityLaunch = GENERAL_LIB.roundVector(velocityLaunch, snapAmount)
	extraVelocity = GENERAL_LIB.roundVector(extraVelocity, snapAmount)
	
	
func updateTimer():
	#updates the variable timeElapsed in the Level.gd script
	
	if startTimer:
		rootNode.timeElapsed = timeElapsed
		timeElapsed += deltaGlobal


func updateSpriteStretching():
	#dictates how the character squshes and stretches (REDO SOON)
	
	animated_sprite.scale.x = (1 / spriteStretch) * spriteScale
	animated_sprite.scale.y = spriteStretch * spriteScale
	animated_sprite.position.y = -10 * spriteStretch + 10
	
	if player_state.current_animation == "air":
		var velocityRatio = abs(velocity.y + 1) / abs(velocity.x + 1)
		if velocityRatio >= PI / 2:
			velocityRatio = PI / 2
		spriteStretch = .05 * cos(2 * (velocityRatio - (PI / 2))) + 1

	
func update_animation():
	#wow! more useless code
	
	if not animation_locked:
		if direction.x != 0:
			#animated_sprite.play("run")
			pass
		else:
			#animated_sprite.play("idle")
			pass

func idleAnimation():
	#handles idle animations. look at _on_idle_timer_timeout() for more info
	
	#runs of character is stationary
	if velocity == Vector2(0, 0):
		
		#plays idle animation
		player_state.play("idle")
		
		#when idle timer reaches zero restarts it at a random value
		if idle_timer.time_left == 0:
			randomize()
			idle_timer.start(randf_range(4, 6))
			
	#stops timer if not stationary
	if !(velocity.y == 0 and velocity.x == 0):
		idle_timer.stop()

func _on_idle_timer_timeout():
	#randomly plays a special idle animation every time IdleTimer reaches 0
	
	#makes sure character is still stationary
	if velocity.y == 0 and velocity.x == 0:
		
		#chooses random number
		randomize()
		var idleRandom = randi_range(1, 3)
		
		#makes sure random number doesn't match previous random number, prevents character playing same animation twice
		while idleRandom == lastIdleRandom:
			randomize()
			idleRandom = randi_range(1, 3)
		
		#plays animation based on value of idleRandom 
		if idleRandom == 1:
			animated_sprite.play("blink")
		elif idleRandom == 2:
			animated_sprite.play("shine")
		else:
			animated_sprite.play("glitch")
			
		#updates lastIdleRandom
		lastIdleRandom = idleRandom
		
		#restarts timer, this time with a longer wait time
		idle_timer.start(randf_range(8, 10))
	
func update_facing_direction():
	#flips character and gun to always face the side of the screen the mouse is on
	
	if !enableRotation:
		return
	#flips character
	if abs(rad_to_deg(mousePlayerAngle)) > 90:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	
	#flips gun
	if $Gun.rotation > PI / 2 and $Gun.rotation < ((3 * PI) / 2):
		$Gun.scale.y = -1
	else:
		$Gun.scale.y = 1
	pass 

func jump():
	#haha! even more useless code
	velocity.y = jump_velocity
	double_jumps = max_double_jumps

func addWallBounce():
	#makes the character bounce a tiny amount when slamming into a wall
	
	if is_on_wall():
		velocityLaunch.x *= wallBounciness * -1
		extraVelocity.x *= wallBounciness * -1

func mouseLeftClick():
	#limits the amount of times the mouse can be left clicked at once, prevents spamming the shoot button
	#look at _on_ShootCooldownTimer_timeout() for more info
	
	#checks if cooldown is not active
	if canClick:
		
		#runs shoot code
		launchPlayer()
		
		#starts cooldown timer
		shoot_cooldown_timer.start(clickSpeed)
		canClick = false
	
	else:
		
		#if player attempts to click during cooldown period, adds a buffer to automatically shoot 
		#once cooldown period ends
		clickBuffer = true

func _on_ShootCooldownTimer_timeout():
	#runs code once ShootCooldownTimer ends
	#look at mouseLeftClick() for more info
	
	#if player attempted to click during cooldown period, automatically shoots
	if clickBuffer:
		
		#updates click buffer
		clickBuffer = false
		
		#starts cooldown timer again since player shot
		shoot_cooldown_timer.start(clickSpeed)
		
		#runs shoot code
		launchPlayer()
	else:
		
		#if the player didn't attempt to click during the cooldown period, update canClick
		canClick = true


func launchPlayer():
	#handles launching the character when the player shoots
	
	if !enableShooting:
		return
	
	#updates animations
	animated_sprite.play("shoot")
	
	gun_sprite.stop()
	gun_sprite.play("shotgun_shoot")
	
	gun_animation_player.stop()
	gun_animation_player.play("shoot")
	$JustShotTimer.start()
	
	player_state.stop()
	player_state.play("air")
	
	animation_player.stop()
	gameSpeed = 1
	animation_player.play("shoot")
	
	$Gun/ShotgunShoot.play()
	$Gun/ShotgunReload.stop()
	
	#allows character to reload once touching ground again
	#look at reloadGun() for more info
	gunReloaded = false
	
	#creates particles
	var shotgun_particles = SHOTGUN_PARTICLES.instantiate()
	add_child(shotgun_particles)
	shotgun_particles.global_position = Vector2(position.x - cos(mousePlayerAngle) * 37.5 * scale.x, position.y - sin(mousePlayerAngle) * 37.5 * scale.y)
	shotgun_particles.rotation = $Gun.rotation
	
	#shake camera
	camera.applyShake(.5, 10)
	
	#creates bullets
	if isTesting:
		print("hi")
		shootBullets(1,0)
	else:
		shootBullets(4, 15)
		shootBullets(1, 0)
	
	
	
	#sets velocities of character to launch them based on mouse's position
	velocityLaunch.x = launchMultiplier * cos(mousePlayerAngle) 
	velocityLaunch.y = launchMultiplier * sin(mousePlayerAngle) * .75
	
	if sign(velocityLaunch.x * extraVelocity.x) == -1:
		extraVelocity.x = 0
	if sign(velocityLaunch.y * extraVelocity.y) == -1:
		extraVelocity.y = 0
	
	#starts timer if not started yet
	#look at updateTimer() for more info
	startTimer = true
	
	#updates amount of bullets fired
	bulletsFired += 1
	rootNode.bulletsFired = bulletsFired
	
func shootBullets(amount, spread):
	#creates bullet objects and sets their values accordingly
	#look at Bullet.gd / Bullet.tscn for more info
	
	#repeats the amount of times the amount variable dictates
	for i in range(amount):
		randomize()
		
		#creates bullet object
		var bullet = BULLET.instantiate()
		
		#parenst bullet object
		add_sibling(bullet)
		
		#changes position and rotation of bullet
		bullet.global_position = Vector2(global_position.x - cos(mousePlayerAngle) * bulletOffset * scale.x, global_position.y - sin(mousePlayerAngle) * bulletOffset * scale.y)
		bullet.rotation = $Gun.rotation + deg_to_rad(randf_range(spread * -1, spread))
		
		bullet.mainScale = mainScale
		
		
func addAirResistance():
	airResistanceB()
	
func airResistanceA():
	#overcomplicated version lol (useless)
	if (velocityLaunch.x <= (airResistance * deltaGlobal)) and (velocityLaunch.x >= (airResistance * deltaGlobal * -1)):
		velocityLaunch.x = 0
	elif velocityLaunch.x > 0:
		velocityLaunch.x -= airResistance * deltaGlobal
	else:
		velocityLaunch.x += airResistance * deltaGlobal

func airResistanceB():
	#adds different amounts of air resistance based on if in air or on ground
	
	#for ground resistance
	if is_on_floor():
		if enableGroundResistance:
			velocityLaunch.x /= groundResistance
			extraVelocity.x /= groundResistance
	else:
		#for air resistance
		if enableAirResistance:
			velocityLaunch.x /= airResistance
			extraVelocity.x /= airResistance
		
func updateMousePosition():
	#updates the mouse position
	
	#gets mouse position
	#mousePosition = get_global_mouse_position()
	#mousePosition = get_viewport().get_mouse_position()
	
	#gets the angle between the mouse position and character
	#mousePlayerAngle = mousePosition.angle_to_point(position)
	
	#rotates the gun
	if enableRotation:
		$Gun.rotation = mousePlayerAngle + PI

func _on_death_detection_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	#detects if hitbox interracts with DeathDetection. Used for deadly objects such as spikes
	#only detects hitboxes in collision layer 3 (look at collision mask)
	
	#if the body is a TileMapLayer process the collision
	if body is TileMapLayer:
		processTilemapCollision(body, body_rid)

func _on_interactable_detection_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	#detects if hitbox interracts with InteractableDetection. Used for Interractables such as springs
	#only detects hitboxes in collision layer 4 (look at collision mask)
	
	#if the body is a TileMapLayer process the collision
	if body is TileMapLayer:
		processTilemapCollision(body, body_rid)

func _on_interactable_detection_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	#if the body is a TileMapLayer process the collision
	if body is TileMapLayer:
		processTilemapCollision(body, body_rid, true)

func processTilemapCollision(body, body_rid, isExiting = false):
	#processes collissions between character and tilemap
	
	#finds collided tile
	var collidedTileCoords = body.get_coords_for_body_rid(body_rid)
	
	#gets data of tile
	var tileData = body.get_cell_tile_data(collidedTileCoords)
	
	#setting variables
	var interactableType = tileData.get_custom_data_by_layer_id(0) #returns value of custom metadata
	var isDeadly = tileData.get_custom_data("isDeadly")
	var extraData = tileData.get_custom_data("ExtraData")
	var dirVec = TILESET_LIB.get_direction_vector(body, collidedTileCoords)
	
	
	var varsDict : Dictionary
	varsDict["dirVec"] = dirVec
	varsDict["extraData"] = extraData
	varsDict["body_rid"] = body_rid
	varsDict["body"] = body
	
	#decides what code to run based on interactableType
	if isDeadly:
		death()
	if interactableType == "test":
		print(TILESET_LIB.get_direction_vector(body, collidedTileCoords))
		print(TILESET_LIB.direction_vec_to_rotation(TILESET_LIB.get_direction_vector(body, collidedTileCoords), true))
	
	if interactableType != "" and $Subscripts/SpecialTiles.get_node_or_null(interactableType) != null:
		if isExiting:
			$Subscripts/SpecialTiles.get_node(interactableType).playerExited(varsDict)
		else:
			$Subscripts/SpecialTiles.get_node(interactableType).playerCollided(varsDict)

func preloadSpecialTiles():
	var dir = DirAccess.open(specialTilesPath)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
				var scenePath = str(specialTilesPath, file_name, "/", file_name, ".tscn")
				specialTilesDict[file_name] = load(scenePath)
				
				
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func death():
	#code that runs when player dies
	
	#literally just reloads the scene lmao
	get_tree().change_scene_to_file(Filepath)
	

func _on_interactable_detection_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.is_in_group("GoalZone"):
		goalTouched.emit()
	pass # Replace with function body.

func _on_animated_sprite_2d_animation_finished():
	animated_sprite.play("idle")
	pass # Replace with function body.

func _on_gun_sprite_animation_finished():
	gun_sprite.play("shotgun_idle")
	pass # Replace with function body.
