extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#test1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enterLevel(levelName):
	get_tree().change_scene_to_file(levelName)
	return

func _on_test_level_pressed():
	enterLevel("res://Levels/test_level.tscn")
	pass # Replace with function body.


func _on_prototype_1_pressed():
	enterLevel("res://Levels/Prototype1.tscn")
	pass # Replace with function body.


func _on_prototype_2_pressed():
	enterLevel("res://Levels/Prototype2.tscn")
	pass # Replace with function body.
