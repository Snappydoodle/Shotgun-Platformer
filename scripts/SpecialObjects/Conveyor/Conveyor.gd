extends Node2D

var varsDict : Dictionary

var color : int = 0
var type : int = 0

func onCreated():
	if varsDict["extraData"].has("Color"):
		color = varsDict["extraData"]["Color"]
	if varsDict["extraData"].has("Type"):
		type = varsDict["extraData"]["Type"]
		
	$AnimatedSprite2D.material.set_shader_parameter("color", color)
	
	var animationName = str("idle", type)
	$AnimatedSprite2D.play(animationName)
	pass

func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	pass # Replace with function body.
