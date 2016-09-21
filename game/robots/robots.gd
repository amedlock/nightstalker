
extends Area2D

export var health = 1
export var explosion_color = Color(1,1,1)
export var points = 300
export var speed = 25
export var large_bullet = false
export var special_ammo = false
export var fire_delay = 0.3;

var explosion = preload("res://game/robots/explosion2.tscn")
var bullet 

#var ex = null # current explosion


var is_secondary = false; # if true, will call game.spawn_secondary on death

var dead = false

var ready_to_fire = true # robots have no ammo limit
var fire_timer = 0

var shield_time = 0
var shield_anim ;

var game;
var audio
var waypoints 

var last_wp # last waypoint we crossed, could be done with collisions
var next_wp # next one to move to, these two vars can switch if we change directions


func _ready():
	self.add_to_group("enemies")
	if large_bullet:
		bullet = load("res://game/bullet/bullet2.tscn")
	else:
		bullet = load("res://game/bullet/bullet.tscn")
	game = get_tree().get_root().get_node("Game")
	audio = game.get_node("audio")
	waypoints = get_tree().get_root().get_node("Game/waypoints")
	if self.has_node("shield"):
		shield_anim = self.get_node("shield/anim")
	set_process(true)	


func _process(delta):
	fire_at_player(delta)
	if shield_time>0:
		update_shield(delta)
	if last_wp==null:
		move_to_initial(delta) # move to initial waypoint
	elif next_wp==null:
		choose_path()
		assert(next_wp!=null)
	else:
		follow_path(delta)

func move_to_initial(delta):
	if false==move_towards( Vector2(120,375), delta ):
		last_wp = waypoints.find_closest(get_pos())
		choose_path()

		
# moves this towards a point, returns true if still moving
func move_towards( pt, delta ):
	var pos = get_pos()
	var dist = pos.distance_to(pt)
	if dist < 0.75:
		return false
	var vel = ( pt - pos ).normalized() * delta * speed
	set_pos( pos + vel )
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



func update_shield(delta):
	if shield_anim!=null and shield_time>0:
		shield_time -= delta
		if shield_time<=0:
			shield_time = 0
			shield_anim.stop()
			shield_anim.get_parent().hide()


func _collision( other ):
	if dead: return 
	if other.is_in_group("bullets") and other.source!="robot":
		self.health -= 1
		if self.health<1:
			self.destroy()
		else:
			other.queue_free()						
			if self.shield_anim!=null:
				self.shield_time = 2
				self.shield_anim.play("blink")
				audio.play("force_field")



func destroy():
	audio.bg_playing = false
	audio.play("Explosion")
	self.dead = true
	game.add_points( points )
	var ex = explosion.instance()
	ex.set_pos( self.get_pos() )
	self.get_parent().add_child( ex )
	ex.get_node("gear1").set_modulate( explosion_color )
	ex.get_node("gear2").set_modulate( explosion_color )
	var anim = ex.get_node("anim")
	anim.play("explosion")
	anim.connect("finished", self , "_finish", [ex] )
	self.hide()

func _finish(ex):
	ex.queue_free()
	audio.bg_playing = true
	if is_secondary:
		game.spawn_secondary()
	else:
		game.spawn_robot()
	self.queue_free()


func fire_at_player(delta):
	if game.is_over:
		return
	if fire_timer>0:
		fire_timer =max( fire_timer- delta, 0)		
	var player = game.player
	if player==null or player.is_dead:
		return
	var pos = get_pos()
	var p2 = player.get_pos()
	if abs(p2.y-pos.y) < 20:
		if p2.x > pos.x:
			fire( 1, 0 )
		elif p2.x < pos.x:
			fire( -1, 0 )
	elif abs(p2.x-pos.x) < 20:
		if p2.y < pos.y:
			fire( 0, -1 )
		elif p2.y > pos.y :
			fire( 0, 1 )

func fire( xd, yd ):
	if ready_to_fire and not dead and fire_timer <= 0:
		fire_timer = fire_delay
		var b = bullet.instance()
		b.special = self.special_ammo
		b.source="robot"
		b.dir = Vector2( xd, yd )
		b.set_pos( self.get_pos() )
		self.get_parent().add_child(b)
		self.ready_to_fire = false
		audio.play("fire")
		b.connect("exit_tree", self, "clear_bullet" )

func clear_bullet():
	self.ready_to_fire = true
		