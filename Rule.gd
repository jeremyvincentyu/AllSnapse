extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var trigger: int;
export var consume: int;
export var release: int;
export var delay: int; 
export var strict: bool;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func save_data():
	return {"trigger":trigger,"consume":consume,"release":release,"delay":delay,"strict":strict}

func load_data(loaded_data):
	print(loaded_data)
	trigger = int(loaded_data["trigger"])
	consume = int(loaded_data["consume"])
	release = int(loaded_data["release"])
	delay = int(loaded_data["delay"])
	strict = bool(loaded_data["strict"])
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
