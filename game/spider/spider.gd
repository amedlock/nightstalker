extends Area2D

export var speed = 20

var expl = preload("res://game/explosion1.tscn")
var sprite 

var maze 
var waypoints
var last_wp = null
var next_wp = null


func _ready():
	connect("area_entered", self, "_hit" )
	maze = get_parent()
	sprite = get_node("image")
	waypoints = maze.get_node("waypoints")
	self.add_to_group("enemies")
	set_process(true)
	
func _process(delta):
	if last_wp==null:
		last_wp = waypoints.find_closest( self.position )
	elif next_wp==null:
		choose_path()
	else:
		follow_path(delta)	
	
const deg90 = deg2rad(90)

# moves this towards a point, returns true if still moving
func move_towards( pt, delta ):
	var pos = position
	var dist = pos.distance_to(pt)
	if dist < 0.75:
		return false
	var vel = ( pt - pos ).normalized() * delta * speed
	position = ( pos + vel )
	sprite.set_flip_v( vel.y > 0 )
	if pt.x>pos.x:
		sprite.set_rot( -deg90 )
	elif pt.x<pos.x:
		sprite.set_rot( deg90 )
	else:
		sprite.set_rot( 0 )
	return true
	
		
func follow_path(delta):
	if false==move_towards( next_wp.position, delta ):
		position =  next_wp.position  # we are there
		last_wp = next_wp
		choose_path()
	

func choose_path():
	next_wp = last_wp.choose_random()

	
func _hit(other):
	if other.is_in_group("player"):
		other.stun()
	if other.is_in_group("bullets"):
		if other.source=="player":
			maze.add_points(100)
		self.kill()
		
func kill():
	var n = expl.instance()
	self.get_parent().add_child( n )
	n.position = ( position + Vector2(0,1) )
	n.connect("exit_tree", maze, "spawn_spider" )
	self.queue_free()
	