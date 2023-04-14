extends Node

func _ready():
	connect("area_entered", Callable(self, "_hit"))


func _hit( other ):
	if other.is_in_group("bullets"):
		other.queue_free()
