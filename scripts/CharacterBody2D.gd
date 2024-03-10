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
#@export var extraAirResistanceThreshold : float = 750

 #Your motherings ssss read
@onready var bulletsFired = get_node("/root/Node2D").bulletsFired
@onready var timeElapsed = get_node("/root/Node2D").timeElapsed
@onready var startTimer = get_node("/root/Node2D").startTimer

var double_jumps : int = 0
var velocityLaunch = Vector2(0,0)
var beforedir : int = 0
@export var acc = 20
var walkvelocity :  Vector2 = Vector2.ZERO
var acceleration : Vector2 = Vector2.ZERO
var mousePosition = Vector2(0,0)
var mousePlayerAngle : float = 0 #the angle between the mouse and the player

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var animation_locked : bool = false
var direction : Vector2 = Vector2.ZERO
var is_double_jumping : bool = false

func _physics_process(delta):
	
	# Add the gravity.
	if is_on_floor():
		animation_locked = false
		is_double_jumping = false
	else:
		animation_locked = true
		velocity.y += gravity * delta
		if is_double_jumping == false:
			if velocity.y > 0:
				animated_sprite.play("fall")
			else:
				animated_sprite.play("jump")
		else:
			animated_sprite.play("double jump")

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		startTimer = true
		if is_on_floor():
			jump()
			
		elif double_jumps > 0:
			is_double_jumping = true
			velocity.y = double_jump_velocity
			double_jumps -= 1
			
	if Input.is_action_just_pressed("mouseLeftClick"):
		mouseLeftClick(delta)

	direction = Input.get_vector("left", "right", "up", "down")
	
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
	addAirResistance(delta)
	addWallBounce(delta)
	
	updateTimer(delta)
	
	
	#velocity.x = velocityLaunch.x
	velocity.x = walkvelocity.x + velocityLaunch.x
	#velocity.y = velocity.y + velocityLaunch.y
	
	update_animation()
	update_facing_direction()
	move_and_slide()
func updateTimer(delta):
	if startTimer:
		get_node("/root/Node2D").timeElapsed = timeElapsed
		timeElapsed += delta

func update_animation():
	if not animation_locked:
		if direction.x != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")

func update_facing_direction():
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true

func jump():
	velocity.y = jump_velocity
	double_jumps = max_double_jumps

func addWallBounce(delta):
	if is_on_wall():
		velocityLaunch.x *= wallBounciness * -1

func mouseLeftClick(delta):
	updateMousePosition()
	mousePlayerAngle = mousePosition.angle_to_point(position)
	launchPlayer(delta)

func launchPlayer(delta):
	velocityLaunch.x = launchMultiplier * cos(mousePlayerAngle)
	velocity.y = launchMultiplier * sin(mousePlayerAngle) * .75
	startTimer = true
	bulletsFired += 1
	get_node("/root/Node2D").bulletsFired = bulletsFired
	
func addAirResistance(delta):
	airResistanceB(delta)
	#if abs(velocityLaunch.x) >= extraAirResistanceThreshold:
	#	velocityLaunch.x /= extraAirResistance
	#if abs(velocity.y) >= extraAirResistanceThreshold:
	#	velocity.y /= extraAirResistance
	#if (abs(velocityLaunch.x) + abs(velocity.y)) >= extraAirResistanceThreshold * 2:
	#	return
	
func airResistanceA(delta):
	if (velocityLaunch.x <= (airResistance * delta)) and (velocityLaunch.x >= (airResistance * delta * -1)):
		velocityLaunch.x = 0
	elif velocityLaunch.x > 0:
		velocityLaunch.x -= airResistance * delta
	else:
		velocityLaunch.x += airResistance * delta

func airResistanceB(delta):
	if is_on_floor():
		velocityLaunch.x /= groundResistance
	else:
		velocityLaunch.x /= airResistance
		
func updateMousePosition():
	mousePosition = get_global_mouse_position()
	

func _on_death_detection_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is TileMap:
		processTilemapCollision(body, body_rid)

func _on_interactable_detection_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print("hi")
	if body is TileMap:
		processTilemapCollision(body, body_rid)
	
func processTilemapCollision(body, body_rid):
	var collidedTileCoords = body.get_coords_for_body_rid(body_rid)
	#for index in body:
	var tileData = body.get_cell_tile_data(0, collidedTileCoords)
	#print(tileData)
	var interactableType = tileData.get_custom_data_by_layer_id(0) #returns value of custom metadata
	if interactableType == "Deadly": 
		print("die")
		death()
	elif interactableType == "Spring":
		print("boing")
	pass

func death():
	get_tree().change_scene_to_file("res://scripts/test_level.tscn")


func _on_interactable_detection_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.is_in_group("GoalZone"):
		goalTouched.emit()
		print(area_rid)
	pass # Replace with function body.
