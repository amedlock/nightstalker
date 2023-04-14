extends Area2D

var blink_delay = 0.5
var blink_count = 0

var maze
var player

func _ready():
	maze = get_parent()
	player = maze.get_node("Player")
	connect("body_entered", Callable(self, "_collide"))
	
func _process(delta):	
	blink_count += delta
	if blink_count>=blink_delay:
		blink_count = 0
		if self.is_visible():
			self.hide()
		else:
			self.show()


func _collide( p ):
	if p.is_in_group("player") and p.state=="ok":
		self.queue_free()
		player.bullets += 6
		maze.audio.stream = load("res://sound/pickup.wav")
		maze.audio.play()