extends Area2D

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

var score = 0
var bullets = 0;
var stage = 1;
var lives ;
var player = null;
var is_over = false
var player_start = Vector2(300,205)
var gun_spawns = []

var spider_start = Vector2(65,110)
var bat_start = [ Vector2(550,160), Vector2(490,280) ]
var robot_start = Vector2(55,375)

var bunker = preload("res://game/bunker/bunker.tscn")

var gun = preload("res://game/gun/gun.tscn")
var human = preload("res://game/human/human.tscn")

var bat = preload("res://game/bat/bat.tscn")
var spider = preload("res://game/spider/spider.tscn")

var grey = preload("res://game/robots/grey_robot.tscn")
var blue = preload("res://game/robots/blue_robot.tscn")
var white = preload("res://game/robots/white_robot.tscn")
var black = preload("res://game/robots/black_robot.tscn")
var invis = preload("res://game/robots/invis_robot.tscn")

var gui 
var audio

func _ready():
	OS.set_window_maximized(true)
	set_process_input(true)
	gui = get_node("GUI")
	audio = get_node("audio")
	for wp in get_node("waypoints").get_children():
		if wp.gun_spawn:
			gun_spawns.append( wp.get_pos() )
	randomize()
	get_tree().set_pause(true)

func _input(event):
	if event.type==InputEvent.KEY and event.pressed:
		if is_over:
			restart()
		if event.scancode==KEY_F10:
			get_tree().quit()
		elif event.scancode==KEY_DELETE and player!=null and player.is_dead==false:
			print( player.is_dead )
			player.kill()
		elif event.scancode==KEY_F5: # testing cheats
			add_points( 5000 )
		elif event.scancode==KEY_F6: # testing cheats
			bullets += 100

func restart():
	for ch in get_tree().get_nodes_in_group("enemies"):
		ch.queue_free()
	for ch in get_tree().get_nodes_in_group("bullets"):
		ch.queue_free()
	var b = get_node("bunker");
	if b: 
		b.queue_free()
	b = bunker.instance( )
	b.set_pos(Vector2(288,208) )
	start_game()

func start_game():
	is_over=false
	audio.bg_playing = true
	gui.get_node("banner").set_text("")
	score = 0
	gui.get_node("score").set_text( str(score) )
	lives = 6
	gui.get_node("lives").set_text( str(lives) )
	spawn_bat(0)
	spawn_bat(1)
	spawn_spider()
	spawn_gun()
	spawn_robot()
	spawn_player()	

func add_points( n ):
	score += n
	gui.get_node("score").set_text( str( score ))


func spawn_player():
	if lives <= 0:
		get_node("GUI/banner").set_text("Game Over")
		is_over = true
		audio.bg_playing = false
		return
	lives -= 1
	gui.get_node("lives").set_text( str(lives) )		
	player = human.instance()
	player.set_name("player")
	player.set_pos( player_start )
	self.add_child( player )
	player.connect("exit_tree", self, "spawn_player")
	audio.bg_playing = true
	if bullets<1: spawn_gun()

func spawn_gun():
	if bullets>0 or has_node("gun"):
		return 
	var n = randi() % gun_spawns.size()
	var v = gun_spawns[n]
	var g = gun.instance()
	g.set_pos( v )
	self.add_child(g)
	return g

func spawn_spider():
	var sp = spider.instance()
	sp.set_pos( spider_start )
	self.add_child(sp)

func spawn_bat(n):
	if score < 5000:
		var b = bat.instance()
		self.add_child(b)
		b.set_pos( bat_start[n%2] )
		b.index = n
		return b
	else:
		return spawn_secondary()


func spawn_robot():
	if score < 5000:
		make_robot(grey, 300)
	elif score < 15000:
		make_robot(blue, 500)
	elif score < 30000:
		make_robot(white,1000)
	elif score < 80000:
		var r = make_robot(black, 2000)
		r.special_ammo = score >= 50000
	else:
		make_robot(invis, 4000)

func make_robot(k, pts):
	var g = k.instance()
	g.set_pos( robot_start )
	g.points = pts
	self.add_child(g)
	return g
		
func spawn_secondary():
	if score<5000:
		return spawn_bat( randi() % 2 )
	else:
		var g =make_robot(grey, 300)
		g.is_secondary = true
		return g



