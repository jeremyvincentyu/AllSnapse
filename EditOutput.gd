extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.

var operated_neuron

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

	
func _on_Save_pressed():
	#Ascencion Order: Popup, MainUI
	var popup_window = get_parent()
	operated_neuron.neuron_label = $Name.text
	var x = float($x.text)
	var y = float($y.text)
	if not (x>=0.0 and x<=5000.0) or not (y>=0.0 and y<=525.0):
		$InvalidCoordinatePopup.popup(Rect2(150,80,300,180))
		return
	operated_neuron.target(x,y)
	for every_synapse in operated_neuron.upstream:
		var other_neuron = operated_neuron.upstream[every_synapse].linked_neuron
		operated_neuron.upstream[every_synapse].graphed_synapse.connect_neurons(other_neuron,operated_neuron)
	operated_neuron.refresh_display()
	$Name.text = ""
	
	popup_window.hide()
	popup_window.get_parent().restore_scroll()

func _on_Cancel_pressed():
	$Name.text = ""
	get_parent().hide()
	get_parent().get_parent().restore_scroll()

func preconfigure(source_neuron):
	operated_neuron = source_neuron
	var neuron_coordinates = operated_neuron.get_position()
	$Name.text = source_neuron.neuron_label
	$x.text = str(neuron_coordinates.x)
	$y.text = str(neuron_coordinates.y)
