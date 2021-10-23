
extends Area2D


func _ready():
	self.connect("area_entered", get_parent(), "hit_section", [ self ] )



func _hit(other):
	if other.is_in_group("bullets") and other.special:
		self.queue_free()
