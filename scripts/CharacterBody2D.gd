extends CharacterBody2D


@export var speed : float = 300.0
@export var jump_velocity : float = -400.0
@export var double_jump_velocity : float = -300.0
@export var max_double_jumps: int = 1
@export var launchMultiplier : float = 1000
@export var airResistance : float = 1.015
@export var groundResistance : float = 1.2
@export var extraAirResistance : float = 1.02
@export var wallBounciness : float = .065
#@export var extraAirResistanceThreshold : float = 750

 #Your motherings ssss read

var double_jumps : int = 0
var velocityMovement = Vector2(0,0)
var velocityLaunch = Vector2(0,0)
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
		if is_on_floor():
			jump()
			
		elif double_jumps > 0:
			is_double_jumping = true
			velocityMovement.y = double_jump_velocity
			double_jumps -= 1
			
	if Input.is_action_just_pressed("mouseLeftClick"):
		mouseLeftClick(delta)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left", "right", "up", "down")
	if direction: #checks if input has been pressed
		velocityMovement.x = direction.x * speed
	else:
		velocityMovement.x = move_toward(velocityMovement.x, 0, speed)
	
	addAirResistance(delta)
	addWallBounce(delta)
	
	
	#velocity.x = velocityLaunch.x
	velocity.x = velocityMovement.x + velocityLaunch.x
	#velocity.y = velocityMovement.y + velocityLaunch.y
	
	update_animation()
	update_facing_direction()
	move_and_slide()

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
	print(velocityLaunch.x + velocity.y)
	velocity.y = launchMultiplier * sin(mousePlayerAngle) * .75
	
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
	
