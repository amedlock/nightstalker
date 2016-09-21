extends Area2D

var expl = preload("res://game/explosion1.tscn")

export var speed = 30

var points = 300
var anim
var game


var index = 0

var waypoints
var last_wp = null
var next_wp = null


func _ready():	
	waypoints = get_tree().get_root().get_node("Game/waypoints")
	anim = self.get_node("anim")
	game = get_tree().get_root().get_node("Game")
	self.add_to_group("enemies")
	self.set_process(true)


func _process(delta):
	if last_wp==null:
		last_wp = waypoints.find_closest( self.get_pos() )
	if next_wp==null:
		choose_path()
	else:
		follow_path( delta )
		
		
		
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


# moves this towards a point, returns true if still moving
func move_towards( pt, delta ):
	var pos = get_pos()
	var dist = pos.distance_to(pt)
	if dist < 0.75:
		return false
	var vel = ( pt - pos ).normalized() * delta * speed
	set_pos( pos + vel )
	return true
		
			
func kill():
	game.audio.play("bat_death")
	var n = expl.instance()
	n.set_pos( self.get_pos() + Vector2(0,1) )
	n.connect("exit_tree", game, "spawn_bat", [index] )
	self.get_parent().add_child( n )	
	self.queue_free()
	
	
func _collide( other ):
	if other.is_in_group("bullets"):
		if other.source == "player":
			game.add_points(300)
		self.kill()
	if other.is_in_group("player"):
		other.stun()
