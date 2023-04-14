
extends Node

# need to cut this up for destructible bunkers ( black robot v2 )

func _ready():
	get_node("bunker_body").add_to_group("walls")


func _hit(_other):
	pass

	
func hit_section( proj, block ):
	if proj.is_in_group("bullets"):
		if proj.special: 
			block.queue_free()
		proj.queue_free()
