extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	#$AnimatedSprite2D.play("idle")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	#print(body)
	if not (body is TileMap):
		$AnimatedSprite2D.play("bounce")
	pass # Replace with function body.
