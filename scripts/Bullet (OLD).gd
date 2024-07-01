extends Node2D

@export var speed : float = 15.0
@export var speed_randomness : float = 5.0

var touchedSpringRecently : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	speed += randf_range(speed_randomness * -1, speed_randomness)
	$Node2D/AnimationPlayer.play("shoot")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Node2D.position.x += speed
	pass

func _on_bullet_lifespan_timeout():
	despawnBullet()
	pass # Replace with function body.
	
func despawnBullet():
	queue_free()

func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is TileMap:
		processTilemapCollision(body, body_rid)

func processTilemapCollision(body, body_rid):
	var collidedTileCoords = body.get_coords_for_body_rid(body_rid)
	var tileData = body.get_cell_tile_data(0, collidedTileCoords)
	var interactableType = tileData.get_custom_data_by_layer_id(0) #returns value of custom metadata
	#print("bullet: " + interactableType)
	if interactableType == "SpringRight":
		spring("Right")
	elif interactableType == "SpringUp":
		spring("Up")
	elif interactableType == "SpringLeft":
		spring("Left")
	elif interactableType == "SpringDown":
		spring("Down")
	else:
		if touchedSpringRecently == false:
			despawnBullet()

func spring(springDirection):
	#global_position = Vector2(global_position.x + cos(rotation) * $Node2D.global_position.x, global_position.y + sin(rotation) * $Node2D.global_position.x)
	#rotation = atan2(cos(rotation), sin(rotation))
	global_position = $Node2D.global_position
	$Node2D.position.x = 0
	if springDirection == "Right" and !(rotation_degrees <= 90 or rotation_degrees >= 270):
		rotation = PI - rotation
		$SpringCooldown.start()
		touchedSpringRecently = true
	elif springDirection == "Left" and (rotation_degrees < 90 or rotation_degrees > 270):
		rotation = PI - rotation
		$SpringCooldown.start()
		touchedSpringRecently = true
	elif springDirection == "Up" and (rotation_degrees > 0 and rotation_degrees < 180):
		rotation *= -1
		$SpringCooldown.start()
		touchedSpringRecently = true
	elif springDirection == "Down" and !(rotation_degrees >= 0 and rotation_degrees <= 180):
		rotation *= -1
		$SpringCooldown.start()
		touchedSpringRecently = true
	
	rotation_degrees = fmod(rotation_degrees, 360)
	if rotation < 0:
		rotation_degrees += 360
		

func _on_spring_cooldown_timeout():
	touchedSpringRecently = false
	pass # Replace with function body.
