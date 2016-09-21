extends Area2D

var blink_delay = 0.5
var blink_count = 0

var game

func _ready():
	game = get_tree().get_root().get_node("Game")
	self.set_process(true)
	
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
		game.bullets += 6
		game.audio.play("pickup")