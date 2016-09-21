
extends Node

# need to cut this up for destructible bunkers ( black robot v2 )

func _ready():
	pass

const bunker_space = Rect2( 290, 180, 30, 30 )

	
func _hit( other ):
	if other.is_in_group("bullets"):
		if other.special: 
			self.queue_free()
		other.queue_free()
