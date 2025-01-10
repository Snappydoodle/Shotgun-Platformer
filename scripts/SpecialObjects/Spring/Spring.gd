extends Node2D

var varsDict : Dictionary

func onCreated():
	pass

func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.play("bounce")
	pass # Replace with function body.
