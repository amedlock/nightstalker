extends Node2D



var score = 0
var stage = 1;


var player = null;

var spider_start = Vector2(65,110)
var bat_start = [ Vector2(550,160), Vector2(490,280) ]
var robot_start = Vector2(55,375)

var bunker = preload("res://game/bunker/bunker.tscn")


var bat = preload("res://game/bat/bat.tscn")
var spider = preload("res://game/spider/spider.tscn")

var grey = preload("res://game/robots/grey_robot.tscn")
var blue = preload("res://game/robots/blue_robot.tscn")
var white = preload("res://game/robots/white_robot.tscn")
var black = preload("res://game/robots/black_robot.tscn")
var invis = preload("res://game/robots/invis_robot.tscn")


var audio


func _ready():
	audio = $audio
	player = $Player



func restart():
	$title.hide()
	for ch in get_tree().get_nodes_in_group("enemies"):
		ch.queue_free()
	for ch in get_tree().get_nodes_in_group("bullets"):
		ch.queue_free()
	var b = get_node("bunker");
	if b: 
		b.queue_free()
	b = bunker.instance()
	b.position = Vector2(288,208) 
	start_game()

func start_game():
	score = 0	
	player.lives = 6
	player.reset()
	update_ui()
	spawn_bat()
	spawn_bat()
	spawn_spider()
	spawn_robot()

func update_ui():
	$GUI.get_node("score").text = "Score:" + str(score) ;
	$GUI.get_node("lives").text =  "Lives:" + str(player.lives) 


func add_points( n ):
	score += n
	update_ui()



func spawn_spider():
	var sp = spider.instance()
	sp.position = spider_start 
	self.add_child(sp)

func spawn_bat():
	if score < 5000:
		var b = bat.instance()
		self.add_child(b)
		b.position = bat_start[randi()%2] 
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
	g.position =  robot_start 
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


