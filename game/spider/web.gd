
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	pass


func _hit( other ):
	if other.is_in_group("bullets"):
		other.queue_free()
