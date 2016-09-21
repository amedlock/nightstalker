extends Area2D

export var speed = 20

var expl = preload("res://game/explosion1.tscn")
var game
var sprite 

var waypoints
var last_wp = null
var next_wp = null


func _ready():
	game = get_tree().get_root().get_node("Game")
	sprite = get_node("image")
	waypoints = game.get_node("waypoints")
	self.add_to_group("enemies")
	set_process(true)
	
func _process(delta):
	if last_wp==null:
		last_wp = waypoints.find_closest( self.get_pos() )
	elif next_wp==null:
		choose_path()
	else:
		follow_path(delta)	
	
const deg90 = deg2rad(90)

# moves this towards a point, returns true if still moving
func move_towards( pt, delta ):
	var pos = get_pos()
	var dist = pos.distance_to(pt)
	if dist < 0.75:
		return false
	var vel = ( pt - pos ).normalized() * delta * speed
	set_pos( pos + vel )
	sprite.set_flip_v( vel.y > 0 )
	if pt.x>pos.x:
		sprite.set_rot( -deg90 )
	elif pt.x<pos.x:
		sprite.set_rot( deg90 )
	else:
		sprite.set_rot( 0 )
	return true
	
		
func follow_path(delta):
	if false==move_towards( next_wp.get_pos(), delta ):
		#print("Arrived at:", str(next_wp.get_pos()))
		set_pos( next_wp.get_pos() ) # we are there
		last_wp = next_wp
		choose_path()
	

func choose_path():
	next_wp = last_wp.choose_random()
	#print("From path :", str( last_wp.get_pos() ) )
	#print("Next path :", str( next_wp.get_pos() ) )
	
	
func _collide(other):
	if other.is_in_group("player"):
		other.stun()
	if other.is_in_group("bullets"):
		if other.source=="player":
			game.add_points(100)
		self.kill()
		
func kill():
	var n = expl.instance()
	n.set_pos( self.get_pos() + Vector2(0,1) )
	n.connect("exit_tree", game, "spawn_spider" )
	self.get_parent().add_child( n )
	self.queue_free()
	