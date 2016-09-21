
extends Node

func _ready():
	get_tree().set_pause(true)
	self.start()	
	
func start():
	self.set_process_input(true)
	self.show()
	
	
func stop():
	self.hide()
	get_tree().set_pause(false)	
	self.set_process_input(false)
	get_tree().get_root().get_node("Game").start_game()
	
func _input(event):
	if event.type==InputEvent.KEY and event.pressed:
		self.stop()
		


