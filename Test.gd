extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var k = to_json({true:1,false:0})
	var reconstructed = JSON.parse(k).get_result()
	for key in reconstructed:
		print(bool(key))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
