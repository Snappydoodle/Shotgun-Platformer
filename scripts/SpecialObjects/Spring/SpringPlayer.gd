extends Node2D

@onready var player = get_parent().get_parent().get_parent()

@export var minSpringBounciness : float = 500
@export var useOldFormula : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(player.shootBullets(1,1))
	pass
func playerCollided(varsDict: Dictionary):
	
	#reflects player based on direction of spring and chracter
	var springDir = varsDict["dirVec"]
	if !useOldFormula:
		if springDir.x != 0:
			player.velocityLaunch.x = abs(player.lastFrameVelocityLaunch.x) * springDir.x 
			player.extraVelocity.x = minSpringBounciness * springDir.x
		if springDir.y != 0:
			player.velocityLaunch.y = abs(player.lastFrameVelocityLaunch.y) * springDir.y
			player.extraVelocity.y = minSpringBounciness * springDir.y
	
	else:
		#old formula
		if springDir.x != 0:
			player.velocityLaunch.x = max(abs(player.lastFrameVelocityLaunch.x), minSpringBounciness) * springDir.x 
			player.extraVelocity.x = abs(player.lastFrameExtraVelocity.x) * springDir.x
		if springDir.y != 0:
			player.velocityLaunch.y = max(abs(player.lastFrameVelocityLaunch.y), minSpringBounciness) * springDir.y
			player.extraVelocity.y = abs(player.lastFrameExtraVelocity.y) * springDir.y
	pass

func playerExited(varsDict: Dictionary):
	pass
