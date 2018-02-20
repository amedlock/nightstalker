extends Area2D



export var dir = Vector2(-1,0)
export var speed = 2.2;
export var special = false

var source = "robot"
export var absorbs_bullets = false

func _ready():
	self.add_to_group("bullets")
	connect("area_entered", self, "_hit")
	connect("body_entered", self, "_hit")
		
func _process(delta):
	self.translate( dir * self.speed )
	var p = position
	var sz = get_viewport_rect().size
	if p.x < 1 or p.x > sz.x or p.y < 1 or p.y > sz.y:
		self.queue_free()


func get_sound():
	if self.absorbs_bullets:
		return load("res://sound/RobotFire.wav")
	else:
		return load('res://sound/fire.wav')


func _hit(other):
	if other.is_in_group("walls"):
		self.queue_free()
	elif absorbs_bullets and other.is_in_group("bullets"):
		other.queue_free()
	else:
		other._hit( self )

