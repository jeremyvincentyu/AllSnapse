extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var my_new_popup;
var NewNeuronClass = load("res://NewNeuron.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_New_pressed():
	my_new_popup = Popup.new()
	get_parent().add_child(my_new_popup)
	my_new_popup.add_child(NewNeuronClass.instance())
	my_new_popup.popup(Rect2(140,140,650,301))
