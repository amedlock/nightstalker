extends Timer



func _ready():
	connect("timeout", Callable($audio, "play"))


