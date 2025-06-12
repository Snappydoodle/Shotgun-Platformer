extends Node2D

@onready var player = get_parent().get_parent().get_parent()

@export var minSpringBounciness : float = 500
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
	
	#old formula
	if springDir.x != 0:
		
		player.lastFrameExtraVelocity.x += player.lastFrameVelocityLaunch.x
		player.velocityLaunch.x = 0
		player.lastFrameVelocityLaunch.x = 0
		
		player.extraVelocity.x = max(abs(player.lastFrameExtraVelocity.x), minSpringBounciness) * springDir.x
		
		
		
	if springDir.y != 0:
		player.lastFrameExtraVelocity.y += player.lastFrameVelocityLaunch.y
		player.velocityLaunch.y = 0
		player.lastFrameVelocityLaunch.y = 0
		
		player.extraVelocity.y = max(abs(player.lastFrameExtraVelocity.y), minSpringBounciness) * springDir.y
	pass

func playerExited(varsDict: Dictionary):
	pass
	
	#old old formula
	#if springDir.x != 0:
			#player.velocityLaunch.x = max(abs(player.lastFrameVelocityLaunch.x), minSpringBounciness) * springDir.x 
			#player.extraVelocity.x = abs(player.lastFrameExtraVelocity.x) * springDir.x
			#

		#if springDir.y != 0:
			#player.velocityLaunch.y = max(abs(player.lastFrameVelocityLaunch.y), minSpringBounciness) * springDir.y
			#player.extraVelocity.y = abs(player.lastFrameExtraVelocity.y) * springDir.y
			#
