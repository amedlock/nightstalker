
extends Area2D


func _ready():
	self.connect("area_entered", Callable(get_parent(), "hit_section").bind(self))



func _hit(other):
	if other.is_in_group("bullets") and other.special:
		self.queue_free()
