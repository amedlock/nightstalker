extends Node2D



# whether this path extends in 4 directions
export var north = false
export var east = false
export var south = false
export var west = false

# can we spawn a gun here?
export var gun_spawn = false;
export var human_only = false;

const close_distance = 2 # at this distance from a waypoint we can move along its paths

var links = [ null, null, null, null ] # contains neighboring nodes, N E S W

func _ready():
	if gun_spawn:
		self.add_to_group("gun_spawn")


func has_link():
	for ch in links:
		if ch!=null: return true
	return false



func choose_random():
	var all = []
	for ch in links:
		if ch!=null and not ch.human_only: all.append(ch)
	assert(all.size()>0)
	return all[ randi() % all.size() ]




func between( pt, p1, p2, acc ):
	if p1.x==p2.x and abs(pt.x-p1.x)<acc:
		if pt.y >= min(p1.y,p2.y) and pt.y <= max(p1.y, p2.y):
			return true
	elif p1.y==p2.y and abs(pt.y-p1.y)<acc:
		if pt.x >= min(p1.x,p2.x) and pt.x <= max(p1.x, p2.x):
			return true
	else:
		return false

# returns a new node if v is near to a linked waypoint
func find_closest(v):
	for wp in links:
		if wp!=null:
			var d = v.distance_to( wp.position )
			if d < close_distance:
				return wp
	return self



	
