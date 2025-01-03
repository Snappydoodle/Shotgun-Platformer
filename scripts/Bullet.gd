extends CharacterBody2D

@onready var trail = $Node2D/Line2D
@onready var anim_player = $Node2D/AnimationPlayer

@export var isTesting : bool = false
@export var speed : float = 15.0
@export var speed_randomness : float = 5.0
@export var springMoveAmount : float = 5.0
@export var MAX_TRAIL_LENGTH : int = 7

var touchedSpringRecently : bool = false
var bulletDirection : Vector2 = Vector2(1,1)
var lastSpringDirection : Vector2i
var ranOnce : bool = false

const TILESET_LIB = preload("res://scripts/Libraries/TilesetLib.gd")

var queue : Array

func _ready():
	
	#sets the speed of the bullet
	randomize()
	if isTesting:
		speed = 5
	else:
		speed += randf_range(speed_randomness * -1, speed_randomness)
	
	#flashes the bullet white
	anim_player.play("shoot")
	pass # Replace with function body.
	
	
func global_to_local_pos(global_pos: Vector2) -> Vector2:
	return global_pos + position
	pass
func _physics_process(delta):
	
	#sets velocity of bullet based on speed
	#DO NOT MOVE TO _ready(), IT WILL BREAK
	if not ranOnce:
		
		velocity.x = speed * cos(rotation)
		velocity.y = speed * sin(rotation)
		
		#configures bulletDirection, makes velcity positive as result
		if velocity.x < 0:
			
			velocity.x = abs(velocity.x)
			bulletDirection.x = -1
			
		if velocity.y < 0:
			
			velocity.y = abs(velocity.y)
			bulletDirection.y = -1
		
		#makes sure this code doesn't run more than once
		ranOnce = true
	
		
	#sets direction based on bulletDirection
	velocity.x = abs(velocity.x) * bulletDirection.x
	velocity.y = abs(velocity.y) * bulletDirection.y
	
	#sets rotation of bullet
	if velocity.x < 0:
		rotation = PI + atan(velocity.y / velocity.x)
	else:
		rotation = atan(velocity.y / velocity.x)
	
	
	#detects if hit another hitbox
	if move_and_collide(velocity):
		if touchedSpringRecently:
			
			#teleports bullet outside of spring to prevent firing multiple times if the bullet has touched a spring recently
			if lastSpringDirection.x != 0:
				position.x += bulletDirection.x * springMoveAmount * -1
			if lastSpringDirection.y != 0:
				position.y += bulletDirection.y * springMoveAmount * -1
		else:
			#despawns bullet if touches wall
			despawnBullet()
	
	createTrail()


func createTrail():
	#creates a trail behind the bullet
	
	#gets current global position of bullet
	var pos = global_position
	
	#adds to a list of positions to add to the Line2D
	queue.push_front(pos)
	
	#if queue size is too long cut off the oldest positions
	if queue.size() > MAX_TRAIL_LENGTH:
		queue.pop_back()
	
	#remove previous frame's points
	trail.clear_points()
	
	#adds all points to Line2D
	for point in queue:
		trail.add_point(point)

func despawnBullet():
	anim_player.play("death")
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()
	pass # Replace with function body.


func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is TileMapLayer:
		processTilemapCollision(body, body_rid)

func processTilemapCollision(body, body_rid):
	var collidedTileCoords = body.get_coords_for_body_rid(body_rid)
	var tileData = body.get_cell_tile_data(collidedTileCoords)
	var interactableType = tileData.get_custom_data_by_layer_id(0) #returns value of custom metadata
	var dirVec = TILESET_LIB.get_direction_vector(body, collidedTileCoords)
	
	if interactableType == "Spring":
		spring(dirVec)
	#if interactableType == "SpringRight":
		#spring("Right")
	#elif interactableType == "SpringUp":
		#spring("Up")
	#elif interactableType == "SpringLeft":
		#spring("Left")
	#elif interactableType == "SpringDown":
		#spring("Down")
	else:#if all else fails the bullet must have touched something that should kill it
		if touchedSpringRecently == false:
			despawnBullet()
			
func spring(springDir: Vector2i):
	
	lastSpringDirection = springDir
	var lastDirection = bulletDirection
	
	if springDir.x != 0:
		bulletDirection.x = springDir.x
	if springDir.y != 0:
		bulletDirection.y = springDir.y
		
	#if springDirection == "Right":
		#bulletDirection.x = 1
	#elif springDirection == "Left":
		#bulletDirection.x = -1
	#elif springDirection == "Up":
		#bulletDirection.y = -1
	#elif springDirection == "Down":
		#bulletDirection.y = 1
	if lastDirection != bulletDirection:#makes sure the bullet actually changed direction before setting off cooldown
		$SpringCooldown.start()
		touchedSpringRecently = true
	pass

func _on_spring_cooldown_timeout():
	touchedSpringRecently = false
	pass


func _on_bullet_lifespan_timeout():
	despawnBullet()
	pass # Replace with function body.
