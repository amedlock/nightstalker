extends Area2D

var blink_delay = 0.5
var blink_count = 0

var maze
var player

func _ready():
	maze = get_parent()
	player = maze.get_node("Player")
	connect("area_entered", self, "_collide" )
	
func _process(delta):	
	blink_count += delta
	if blink_count>=blink_delay:
		blink_count = 0
		if self.is_visible():
			self.hide()
		else:
			self.show()


func _collide( area ):
	if area.is_in_group("player") and not (area.is_dead or area.is_stunned):
		self.queue_free()
		player.bullets += 6
		#maze.pickup audio