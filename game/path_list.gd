extends Node2D


# on startup, build the list of waypoint values in the child nodes
# we only set ones above us and to the right, and set their links down and left
# this way all nodes are processed, and only once
func _ready():
	var sz = self.get_children().size()
	for i in range(sz):
		var ch = get_child(i)
		var p1 = ch.get_pos()
		var N = null
		var E = null
		for j in range(sz):
			if i==j: continue # same node
			var ch2 = get_child(j)
			var p2 = ch2.get_pos()
			if p2.x==p1.x and ch.north==true:
				if p2.y < p1.y and ch2.south==true:
					N = closest( ch, N, ch2 )
			elif p2.y==p1.y and ch.east==true:
				if p2.x > p1.x and ch2.west==true:
					E = closest( ch, E, ch2 )
		if N!=null:
			ch.links[0] = N
			N.links[2] = ch
		if E!=null:
			ch.links[1]=E
			E.links[3]=ch


func find_closest( v ):
	var cur
	var dist
	for ch in self.get_children():
		var d2 = ch.get_pos().distance_to(v)
		if cur==null:
			cur = ch
			dist = d2
			continue
		if d2 < dist:
			dist = d2
			cur = ch
	return cur

func closest( n, n2, n3 ):
	if n2==null: return n3
	if n3==null: return n2
	var p1 = n.get_pos()
	if n2.get_pos().distance_to( p1 ) < n3.get_pos().distance_to( p1 ):
		return n2
	else:
		return n3





