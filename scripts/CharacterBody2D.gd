extends CharacterBody2D

signal goalTouched

@export var speed : float = 200.0
@export var jump_velocity : float = -400.0
@export var double_jump_velocity : float = -300.0
@export var max_double_jumps: int = 1
@export var launchMultiplier : float = 1000
@export var airResistance : float = 1.015
@export var groundResistance : float = 1.2
@export var wallBounciness : float = .065
@export var minSpringBounciness : float = 500
@export var clickSpeed : float = .2
@export var spriteScale : int = 2
@export var spriteStretch : float = 1
#@export var extraAirResistance`Threshold : float = 750

 #Your motherings ssss read

@onready var bulletsFired = get_node("/root/Node2D").bulletsFired
@onready var timeElapsed = get_node("/root/Node2D").timeElapsed
@onready var startTimer = get_node("/root/Node2D").startTimer
@onready var Filepath = get_node("/root/Node2D").scene_file_path

var SHOTGUN_PARTICLES = preload("res://scripts/shotgun_particles.tscn")
var BULLET = preload("res://scripts/Bullet.tscn")

var double_jumps : int = 0
var velocityLaunch = Vector2(0,0)
var beforedir : int = 0
@export var acc = 20
var walkvelocity :  Vector2 = Vector2.ZERO
var acceleration : Vector2 = Vector2.ZERO
var mousePosition = Vector2(0,0)
var mousePlayerAngle : float = 0 #the angle between the mouse and the player

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var shoot_cooldown_timer : Timer = $ShootCooldownTimer
@onready var idle_timer : Timer = $IdleTimer
@onready var gun_sprite : AnimatedSprite2D = $Gun/GunSprite

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var animation_locked : bool = false
var direction : Vector2 = Vector2.ZERO
var is_double_jumping : bool = false

var clickBuffer : bool = false
var canClick : bool = true
var deltaGlobal : float = 0.00

var lastIdleRandom : int = -1

var gunReloaded : bool = false

@onready var tileMap = get_node("/root/Node2D/Level/TileMap")

func _ready():
	animated_sprite.play("idle")
	animation_player.play("idle")
func _physics_process(delta):
	deltaGlobal = delta
	# Add the gravity.
	if is_on_floor():
		animation_locked = false
		is_double_jumping = false
	else:
		animation_locked = true
		velocity.y += gravity * delta
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

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		startTimer = true
		if is_on_floor():
			jump()
			
		elif double_jumps > 0:
			is_double_jumping = true
			velocity.y = double_jump_velocity
			double_jumps -= 1
	
	updateMousePosition()
	if Input.is_action_just_pressed("mouseLeftClick"):
		mouseLeftClick()

	#direction = Input.get_vector("left", "right", "up", "down")
	direction = Vector2(sign(direction.x), sign(direction.y))
	
	if direction.x: #checks if input has been pressed
		startTimer = true
		beforedir = direction.x
		if direction.x == 1:
			walkvelocity.x = min(walkvelocity.x + acc, speed)
		else:
			walkvelocity.x = max(walkvelocity.x - acc, -speed)
	else:
		if beforedir == 1:
			walkvelocity.x = max(walkvelocity.x - acc*5, 0)
		else:
			walkvelocity.x = min(walkvelocity.x + acc*5, 0)
		
		
		#velocity.x = move_toward(velocity.x, 0, speed)
		pass
	
	addAirResistance()
	addWallBounce()
	updateTimer()
	
	velocity.x = walkvelocity.x + velocityLaunch.x
	#DO NOT MOVE THIS
	
	update_animation()
	update_facing_direction()
	idleAnimation()
	updateSpriteStretching()
	move_and_slide()
	roundVelocityLaunch()
	reloadGun()
	
	#velocity.y = velocity.y + velocityLaunch.y
func reloadGun():
	if is_on_floor() and !(gunReloaded):
		gun_sprite.play("shotgun_reload")
		$Gun/ShotgunReload.play()
		gunReloaded = true
func roundVelocityLaunch():
	if velocityLaunch.x >= -0.01 and velocityLaunch.x <= 0.01:
		velocityLaunch.x = 0
	
func updateTimer():
	if startTimer:
		get_node("/root/Node2D").timeElapsed = timeElapsed
		timeElapsed += deltaGlobal

func updateSpriteStretching():
	animated_sprite.scale.x = (1 / spriteStretch) * spriteScale
	animated_sprite.scale.y = spriteStretch * spriteScale
	animated_sprite.position.y = -10 * spriteStretch + 10
	#print(animation_player.current_animation)
	if animation_player.current_animation == "air":
		var velocityRatio = abs(velocity.y + 1) / abs(velocityLaunch.x + 1)
		if velocityRatio >= PI / 2:
			velocityRatio = PI / 2
		spriteStretch = .05 * cos(2 * (velocityRatio - (PI / 2))) + 1
		#print(str(velocity.y + 1) + " / " + str(velocityLaunch.x + 1) + " = " + str(velocityRatio))
	
func update_animation():
	if not animation_locked:
		if direction.x != 0:
			#animated_sprite.play("run")
			pass
		else:
			#animated_sprite.play("idle")
			pass

func idleAnimation():
	if velocity.y == 0 and velocityLaunch.x == 0:
		animation_player.play("idle")
		if idle_timer.time_left == 0:
			randomize()
			idle_timer.start(randf_range(4, 6))
	if !(velocity.y == 0 and velocityLaunch.x == 0):
		idle_timer.stop()

func _on_idle_timer_timeout():
	if velocity.y == 0 and velocityLaunch.x == 0:
		randomize()
		var idleRandom = randi_range(1, 3)
		while idleRandom == lastIdleRandom:
			randomize()
			idleRandom = randi_range(1, 3)
		if idleRandom == 1:
			animated_sprite.play("blink")
		elif idleRandom == 2:
			animated_sprite.play("shine")
		else:
			animated_sprite.play("glitch")
		lastIdleRandom = idleRandom
		idle_timer.start(randf_range(8, 10))
	
func update_facing_direction():
	#if velocityLaunch.x > 0: #OLD VERSION
	#	animated_sprite.flip_h = false
	#elif velocityLaunch.x < 0:
	#	animated_sprite.flip_h = true
	if abs(rad_to_deg(mousePlayerAngle)) > 90:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	if $Gun.rotation > PI / 2 and $Gun.rotation < ((3 * PI) / 2):
		$Gun.scale.y = -1
	else:
		$Gun.scale.y = 1
	pass 

func jump():
	velocity.y = jump_velocity
	double_jumps = max_double_jumps

func addWallBounce():
	if is_on_wall():
		velocityLaunch.x *= wallBounciness * -1

func mouseLeftClick():
	if canClick:
		launchPlayer()
		shoot_cooldown_timer.start(clickSpeed)
		canClick = false
	else:
		clickBuffer = true

func _on_ShootCooldownTimer_timeout():
	if clickBuffer:
		clickBuffer = false
		shoot_cooldown_timer.start(clickSpeed)
		launchPlayer()
	else:
		canClick = true
	pass # Replace with function body.

func launchPlayer():
	animated_sprite.play("shoot")
	gun_sprite.play("shotgun_shoot")
	animation_player.play("air")
	$Gun/ShotgunShoot.play()
	$Gun/ShotgunReload.stop()
	gunReloaded = false
	
	var shotgun_particles = SHOTGUN_PARTICLES.instantiate()
	add_child(shotgun_particles)
	shotgun_particles.global_position = Vector2(position.x - cos(mousePlayerAngle) * 37.5 * scale.x, position.y - sin(mousePlayerAngle) * 37.5 * scale.y)
	shotgun_particles.rotation = $Gun.rotation
	#print(str(get_node(shotgun_particles)))
	
	shootBullets(4, 15)
	#shootBullets(1, 0)
	velocityLaunch.x = launchMultiplier * cos(mousePlayerAngle)
	velocity.y = launchMultiplier * sin(mousePlayerAngle) * .75
	
	startTimer = true
	
	bulletsFired += 1
	get_node("/root/Node2D").bulletsFired = bulletsFired
	
func shootBullets(amount, spread):
	for i in range(amount):
		randomize()
		var bullet = BULLET.instantiate()
		add_sibling(bullet)
		bullet.global_position = Vector2(position.x - cos(mousePlayerAngle) * 37.5 * scale.x, position.y - sin(mousePlayerAngle) * 37.5 * scale.y)
		bullet.rotation = $Gun.rotation + deg_to_rad(randf_range(spread * -1, spread))
func addAirResistance():
	airResistanceB()
	#if abs(velocityLaunch.x) >= extraAirResistanceThreshold:
	#	velocityLaunch.x /= extraAirResistance
	#if abs(velocity.y) >= extraAirResistanceThreshold:
	#	velocity.y /= extraAirResistance
	#if (abs(velocityLaunch.x) + abs(velocity.y)) >= extraAirResistanceThreshold * 2:
	#	return
	
func airResistanceA():
	if (velocityLaunch.x <= (airResistance * deltaGlobal)) and (velocityLaunch.x >= (airResistance * deltaGlobal * -1)):
		velocityLaunch.x = 0
	elif velocityLaunch.x > 0:
		velocityLaunch.x -= airResistance * deltaGlobal
	else:
		velocityLaunch.x += airResistance * deltaGlobal

func airResistanceB():
	if is_on_floor():
		velocityLaunch.x /= groundResistance
	else:
		velocityLaunch.x /= airResistance
		
func updateMousePosition():
	mousePosition = get_global_mouse_position()
	mousePlayerAngle = mousePosition.angle_to_point(position)
	$Gun.rotation = mousePlayerAngle + PI

func _on_death_detection_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is TileMap:
		processTilemapCollision(body, body_rid)

func _on_interactable_detection_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is TileMap:
		#print(body)
		processTilemapCollision(body, body_rid)
	
func processTilemapCollision(body, body_rid):
	var collidedTileCoords = body.get_coords_for_body_rid(body_rid)
	#for index in body:
	var tileData = body.get_cell_tile_data(0, collidedTileCoords)
	#print(tileData)
	var interactableType = tileData.get_custom_data_by_layer_id(0) #returns value of custom metadata
	#print("player: " + interactableType)
	if interactableType == "Deadly": 
		death()
	elif interactableType == "SpringRight":
		spring("Right")
	elif interactableType == "SpringUp":
		spring("Up")
	elif interactableType == "SpringLeft":
		spring("Left")
	elif interactableType == "SpringDown":
		spring("Down")

func spring(springDirection):
	if springDirection == "Right":
		velocityLaunch.x = max(abs(velocityLaunch.x), minSpringBounciness)
	elif springDirection == "Left":
		velocityLaunch.x = max(abs(velocityLaunch.x), minSpringBounciness) * -1
	elif springDirection == "Up":
		velocity.y = max(abs(velocity.y), minSpringBounciness)  * -1
	elif springDirection == "Down":
		velocity.y = max(abs(velocity.y), minSpringBounciness)
	pass

func death():
	get_tree().change_scene_to_file(Filepath)
	pass
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
