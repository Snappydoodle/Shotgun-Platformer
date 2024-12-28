extends CharacterBody2D

@export var isTesting : bool = false
@export var speed : float = 15.0
@export var speed_randomness : float = 5.0
@export var springMoveAmount : float = 5.0

var touchedSpringRecently : bool = false
var bulletDirection : Vector2 = Vector2(1,1)
var lastSpringDirection : String
var ranOnce : bool = false

func _ready():
	
	#sets the speed of the bullet
	randomize()
	if isTesting:
		speed = 5
	else:
		speed += randf_range(speed_randomness * -1, speed_randomness)
	
	#flashes the bullet white
	$Node2D/AnimationPlayer.play("shoot")
	pass # Replace with function body.

func _physics_process(delta):
	
	#sets velocity of bullet based on speed
	#DO NOT MOVE TO _ready(), IT WILL BREAK
	if not ranOnce:
		
		velocity.x = speed * cos(rotation)
		velocity.y = speed * sin(rotation)
		
		if velocity.x < 0:
			
			velocity.x = abs(velocity.x)
			bulletDirection.x = -1
			
		if velocity.y < 0:
			
			velocity.y = abs(velocity.y)
			bulletDirection.y = -1
			
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
			if lastSpringDirection == "Right" or lastSpringDirection == "Left":
				position.x += bulletDirection.x * springMoveAmount * -1
			if lastSpringDirection == "Up" or lastSpringDirection == "Down":
				position.y += bulletDirection.y * springMoveAmount * -1
		else:
			#despawns bullet if touches wall
			despawnBullet()

func despawnBullet():
	queue_free()


func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is TileMapLayer:
		processTilemapCollision(body, body_rid)

func processTilemapCollision(body, body_rid):
	var collidedTileCoords = body.get_coords_for_body_rid(body_rid)
	var tileData = body.get_cell_tile_data(collidedTileCoords)
	var interactableType = tileData.get_custom_data_by_layer_id(0) #returns value of custom metadata
	
	
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
	
	lastSpringDirection = springDirection
	var lastDirection = bulletDirection
	if springDirection == "Right":
		bulletDirection.x = 1
	elif springDirection == "Left":
		bulletDirection.x = -1
	elif springDirection == "Up":
		bulletDirection.y = -1
	elif springDirection == "Down":
		bulletDirection.y = 1
	if lastDirection != bulletDirection:#makes sure the bullet actually changed direction
		$SpringCooldown.start()
		touchedSpringRecently = true
	#print(bulletDirection)
	pass

func _on_spring_cooldown_timeout():
	touchedSpringRecently = false
	pass


func _on_bullet_lifespan_timeout():
	despawnBullet()
	pass # Replace with function body.
