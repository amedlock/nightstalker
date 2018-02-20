extends Timer



func _ready():
	connect("timeout", $audio, "play" )


