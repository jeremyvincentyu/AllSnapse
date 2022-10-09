extends TextEdit


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var copyright_file = File.new()
	copyright_file.open("res://COPYRIGHT.txt",File.READ)
	text = copyright_file.get_as_text()
	copyright_file.close()
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
