extends Camera3D

var shakeStrength : float = 0.0
var shakeFade : float = 0.0

var rng = RandomNumberGenerator.new()

@onready var main_subviewport : SubViewport = get_parent().get_node("MainSubviewport")
@onready var mainSubviewportSize : Vector2 = main_subviewport.size_2d_override
@onready var mainSubviewportCenter : Vector2 = mainSubviewportSize / 2

@onready var main_mesh : MeshInstance3D = get_parent().get_node("MainMesh")
@onready var mainMeshSize : Vector2 = main_mesh.mesh.size

@onready var main : Node2D = main_subviewport.get_node("CanvasLayer/Main")
@onready var mainScale : float = main.scale.x

@onready var player : CharacterBody2D = main_subviewport.get_node("CanvasLayer/Player")
@onready var test_object : MeshInstance3D = $testobject

func applyShake(shakeStrenghtInit : float, shakeFadeInit : float):
	#note: a higher shakeFadeInit means the shake fades faster
	
	shakeStrength = shakeStrenghtInit
	shakeFade = shakeFadeInit
	pass

func randomOffset() -> float:
	return rng.randf_range(-shakeStrength, shakeStrength)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	

	#global_position.x = (player.position.x)/100
	#global_position.y = (-player.position.y)/100
	
	#var ratio = Vector2((mainSubviewportCenter.x + (player.position.x * mainScale)) / mainSubviewportSize.x, (mainSubviewportCenter.y + (player.position.y * mainScale)) / mainSubviewportSize.y)
	#var mainMeshCorner = Vector2(main_mesh.position.x - (mainMeshSize.x / 2), main_mesh.position.y + (mainMeshSize.y / 2))
	#test_object.position.x = mainMeshCorner.x + (mainMeshSize.x * ratio.x)
	#test_object.position.y = mainMeshCorner.y - (mainMeshSize.y * ratio.y)
	
	#position.x = player.position.x * mainScale * (main_mesh.mesh.size.x / mainSubviewportSize.x)
	#position.y = -player.position.y * mainScale * (main_mesh.mesh.size.y / mainSubviewportSize.y)
	position.x = player.position.x * mainScale * (main_mesh.mesh.size.x / mainSubviewportSize.x)
	position.y = -player.position.y * mainScale * (main_mesh.mesh.size.y / mainSubviewportSize.y)
	
	#main_mesh.position.x = position.x
	#main_mesh.position.y = position.y
	
	
	#main.position.x = mainSubviewportCenter.x - (player.position.x * main.scale.x)
	#main.position.y = mainSubviewportCenter.y - (player.position.y * main.scale.y)


	
	print("Camera2D: " + str(main_subviewport.get_node("Camera2D").position) + ", CanvasLayer: " + str(main_subviewport.get_node("CanvasLayer").transform))
	
	if shakeStrength > 0:
		shakeStrength = lerpf(shakeStrength, 0, shakeFade * delta)
		h_offset = randomOffset()
		v_offset = randomOffset()
	pass
