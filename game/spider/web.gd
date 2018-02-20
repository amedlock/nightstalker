extends Node

func _ready():
	connect("area_entered", self, "_hit")


func _hit( other ):
	if other.is_in_group("bullets"):
		other.queue_free()
