extends Area2D

var expl = preload("res://game/explosion1.tscn")

@export var speed = 30

var points = 300
var anim

var stuns_player = true


var maze
var waypoints
var last_wp = null
var next_wp = null


func _ready():
	connect("body_entered", Callable(self, "_hit"))
	connect("area_entered", Callable(self, "_hit"))
	maze = get_parent()
	waypoints = maze.get_node("waypoints")
	anim = self.get_node("anim")
	self.add_to_group("enemies")
	self.set_process(true)


func _process(delta):
	if last_wp==null:
		last_wp = waypoints.find_closest( self.position )
	if next_wp==null:
		choose_path()
	else:
		follow_path( delta )
		
		
		
func follow_path(delta):
	if false==move_towards( next_wp.position, delta ):
		position=( next_wp.position ) # we are there
		last_wp = next_wp
		choose_path()
	

func choose_path():
	next_wp = last_wp.choose_random()



# moves this towards a point, returns true if still moving
func move_towards( pt, delta ):
	var pos = position
	var dist = pos.distance_to(pt)
	if dist < 0.75:
		return false
	var vel = ( pt - pos ).normalized() * delta * speed
	position = ( pos + vel )
	return true
		
			
func kill():
	maze.audio.stream = load("res://sound/bat_death.wav")
	maze.audio.play()
	var n = expl.instantiate()
	self.get_parent().add_child( n )
	n.position = self.position 
	n.connect("tree_exiting", Callable(maze, "spawn_bat"))
	self.queue_free()
	
	
func _hit( other ):
	if other.is_in_group("bullets"):
		if other.source == "player":
			maze.add_points(300)
		self.kill()
	if other.is_in_group("player"):
		other.stun()
