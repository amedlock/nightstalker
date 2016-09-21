
extends SamplePlayer2D

var bg_playing = false

var bg_delay = 1
var bg_timer = 0

func _ready():
	set_process(true)
	
	
func _process(delta):
	if bg_playing:
		if bg_timer<=0:
			play( "BGSound" )
			bg_timer = bg_delay
		else:
			bg_timer -= delta


func fire():
	play("fire" )