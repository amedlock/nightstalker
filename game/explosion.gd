extends Area2D

var anim
var total_time = 2

func _ready():
	anim = self.get_node("image/anim")
	anim.play("explosion")
	self.set_process(true)
	
	
func _process(delta):
	total_time -= delta
	if total_time<=0:
		self.queue_free()	