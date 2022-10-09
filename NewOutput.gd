extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

	
func _on_Save_pressed():
	#Ascencion Order: Popup, MainUI
	var popup_window = get_parent()
	var neural_canvas = popup_window.get_parent().get_node("ScrollContainer/ViewportContainer/Viewport/NeuralCanvas")
	var neuron_name = $Name.text
	var x = float($x.text)
	var y = float($y.text)
	if not (x>=0.0 and x<=5000.0) or not (y>=0.0 and y<=525.0):
		$InvalidCoordinatePopup.popup(Rect2(150,80,300,180))
		return
	neural_canvas.new_output(neuron_name,x,y)
	$Name.text = ""
	get_parent().hide()
	get_parent().get_parent().restore_scroll()

func _on_Cancel_pressed():
	$Name.text = ""
	get_parent().hide()
	get_parent().get_parent().restore_scroll()
