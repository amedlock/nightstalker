extends Node2D


func _ready():
	$Timer.connect("timeout", self, "anim_done" )

func anim_done():
	print("done")
	self.queue_free()

