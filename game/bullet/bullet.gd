extends Area2D


export var dir = Vector2(-1,0)
export var speed = 2.2;
export var special = false

var source = "robot"
export var absorbs_bullets = false

func _ready():
	self.add_to_group("bullets")
	self.set_process(true)
		
func _process(delta):
	self.set_pos( self.get_pos() + (dir * self.speed ) )
	var p = get_pos()
	var sz = get_viewport_rect().size
	if p.x < 1 or p.x > sz.width or p.y < 1 or p.y > sz.height:
		self.queue_free()


func _collide(other):
	if absorbs_bullets and other.is_in_group("bullets"):
		other.queue_free()
	if other.is_in_group("player") and source!="player":
		other.kill()
		self.queue_free()

