extends Node2D

var varsDict : Dictionary

var colorInt : int = 0
var color : String
var type : int = 0

func onCreated():
	if varsDict["extraData"].has("Color"):
		colorInt = varsDict["extraData"]["Color"]
	if varsDict["extraData"].has("Type"):
		type = varsDict["extraData"]["Type"]
	
	match colorInt:
		0:
			color = "Green"
		1:
			color = "Yellow"
		2:
			color = "Red"
	
	var filepath = "res://scripts/SpecialObjects/Conveyor/" + color + ".png"
	$AnimatedSprite2D.material.set_shader_parameter("output_palette_texture", load(filepath))
	
	var animationName = str("idle", type)
	$AnimatedSprite2D.play(animationName)
	pass

func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	pass # Replace with function body.
