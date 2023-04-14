extends Node2D


func _ready():
	$Timer.connect("timeout", Callable(self, "anim_done"))

func anim_done():
	self.queue_free()

