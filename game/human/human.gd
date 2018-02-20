extends KinematicBody2D

var bullets = 0;
var lives ;

var gun = preload("res://game/gun/gun.tscn")
var bullet = preload("res://game/bullet/bullet.tscn" )

var ready_to_fire = true
var speed = 70

const Start_Position = Vector2(300,205)

var anim  		# user animation
var image1 		# normal image

var game ;  	# reference to game root node
var audio

var waypoints 	# reference to the waypoint node list

var state = "ok" ; # dead, stun, ok

var delay ; # delay between states

# cur_wp is the last waypoint the player was at
# close_wp is the closest waypoint to the player
# if path is set (Rect2), it constrains the players movement

var cur_wp
var close_wp
var path # this is a Rect2 which limits the players movement

var last_pos
var last_vel
var blocked = false

var user_move    # which way is the user attempting to move
var maze 

var gun_spawns = []

func _ready():
	maze = get_parent()
	for wp in maze.get_node("waypoints").get_children():
		if wp.gun_spawn:
			gun_spawns.append( wp.position )	
	game = maze.get_parent()
	audio = maze.get_node("audio")
	waypoints = maze.get_node("waypoints")
	self.add_to_group("player")
	image1 = find_node("image")	
	anim = image1.get_node("anim")
	anim.play("stand")



var move_dir = { "stand": Vector2(0,0), "move_left":Vector2(-1,0), "move_up":Vector2(0,-1),
		"move_right":Vector2(1,0), "move_down":Vector2(0,1) }
		
func check_dir():
	if move_dir.has( user_move ):
		return move_dir[user_move]
	else:
		return Vector2(0,0)


# move the player, manage animations
func _process(delta):
	if cur_wp==null: # no waypoint? snap to one
		set_waypoint( waypoints.find_closest( position ) )
		return
	if state=="stun":
		self.stun_process( delta )
	elif state=="dead":
		self.dead_process( delta )
	else:
		if move_dir.has( user_move ): 
			var md = move_dir[user_move]
			var d = move_and_slide( md * speed )
			set_anim()

func backup():
	translate( -last_vel )


func reset():
	if self.lives <1: 
		self.state = "dead"
		self.hide()
	self.state = "ok"
	anim.play("stand")
	self.bullets = 0
	self.position = Start_Position
	spawn_gun()


func spawn_gun():
	if bullets>0 or maze.has_node("gun"):
		return 
	var n = randi() % gun_spawns.size()
	var v = gun_spawns[n]
	var g = gun.instance()
	g.position =  v 
	maze.add_child(g)
	return g

# check player movement and firing
func _input(event):
	if state!="ok":
		user_move = ""
		return
	user_move = check_movement(event)
	if event is InputEventKey:
		if event.pressed:
			if event.scancode==KEY_KP_4:
				self.fire( -1, 0 )
			elif event.scancode==KEY_KP_8:
				self.fire( 0, -1 )
			elif event.scancode==KEY_KP_6:
				self.fire( 1, 0 )
			elif event.scancode==KEY_KP_2:
				self.fire( 0, 1 )


# sets waypoint and pos to closest
func set_waypoint(wp):
	self.position =  wp.position
	cur_wp = wp
	path = null	



func constrain( v ):
	if path!=null:
		if v.x < path.pos.x:
			v.x = path.pos.x
		elif v.x > path.end.x:
			v.x = path.end.x
		if v.y < path.pos.y:
			v.y = path.pos.y
		elif v.y > path.end.y:
			v.y = path.end.y
	return v




var anim_lookup = { 
	'move_down': 'walk_vertical',
	'move_up': 'walk_vertical',
	'move_left': 'walk_horizontal',
	'move_right': 'walk_horizontal'
}

func set_anim():
	var cur = anim.current_animation
	var target = "stand"
	image1.set_flip_h( user_move=='move_left' )
	if anim_lookup.has( user_move ):
		target = anim_lookup[user_move]
	if cur!=target:
		anim.play( target )



func check_movement( event ):
	var move_actions = ['move_down', 'move_left', 'move_up', 'move_right']
	for ma in move_actions:
		if event.is_action(ma):
			if event.is_pressed():
				return ma
			else:
				return "stand"
	return user_move



func fire( xd, yd ):
	if bullets > 0 and ready_to_fire:
		bullets -= 1
		var b = bullet.instance()
		b.special = false
		b.source="player"
		b.dir = Vector2( xd, yd )
		b.position = ( self.position )
		maze.add_child(b)
		self.ready_to_fire = false
		b.connect("tree_exited", self, "clear_bullet" )
		audio.stream = load("res://sound/fire.wav")
		audio.play()


func clear_bullet():
	self.ready_to_fire = true
	if bullets<1: spawn_gun()
	
func stun():
	if state=="dead": return
	anim.play("stun")
	delay = 3
	state = "stun"

func stun_process(delta):
	delay -= delta
	if delay <=0:
		anim.play("stand")
		reset()
		
	
func kill():
	state = "dead"
	anim.play("death")
	audio.stream = load("res://sound/death1.wav")
	audio.play()	
	delay = 3
	bullets = 0 
		
func dead_process(delta):
	delay -= delta
	if delay <=0:
		self.reset()
		


func _hit( other ):
	if other.is_in_group("bullets") and other.source!="player":
		self.kill()
		other.queue_free()
