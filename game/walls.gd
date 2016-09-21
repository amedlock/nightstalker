
extends Area2D

func _ready():
	pass


func _collide( other ):
	if other.is_in_group("bullets"):
		other.queue_free()
	if other.is_in_group("player"):
		other.blocked = true


func _uncollide( other ):
	if other.is_in_group("player"):
		other.blocked = false
