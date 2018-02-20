extends Node2D

# bats = 300 pts
# spider = 100 pts
# grey = 300 pts
# blue = 500 pts
# white = 1000 pts
# black = 2000 pts
# invisible = 4000 pts

# stage 1 = grey ,  0-5000
# stage 2 = blue , bats replaced by greys,  5000-15000
# stage 3 = white ,  15000-30000
# stage 4 = black , ammo absorbs bullets, 30000-50000
# stage 5 = black , bunker busting ammo,  50000-80000
# stage 6 = invisible

var state = "title"


func _ready():
	OS.set_window_maximized(true)
	$maze.hide()
	$title.show()	
	randomize()

func _input(event):
	if event is InputEventKey and event.pressed:
		if state=="title" or state=="game_over":
			state = "playing"
			$maze.start_game()
			$title.hide()
			$maze.show()
			$BG.start()
		if event.scancode==KEY_F10:
			get_tree().quit()
		elif event.scancode==KEY_DELETE and $maze.player!=null:
			$maze.player.kill()
		elif event.scancode==KEY_F5: # testing cheats
			$maze.add_points( 5000 )
		elif event.scancode==KEY_F6: # testing cheats
			$maze.player.bullets += 100

func game_over():
	$maze.get_node("GUI/Container").show()
	state="game_over"
	$audio.stop()



