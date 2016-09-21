
extends Area2D


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

var safe_rect = Rect2( 399, 217, 42, 87 )


func _hit_enter(other):
	if other.is_in_group("player"):
		var pos = other.get_pos()
		if not safe_rect.has_point( pos ):
			other.backup()

func _hit_exit(other):
	if other.is_in_group("player"):
		other.blocked = false
		print("Free")
