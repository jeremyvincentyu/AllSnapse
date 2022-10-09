extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var spiketrain: String;
export var neuron_label: String;
export var unique_id: int;
export var ongoing_simulation: bool = false;
var cursor = 0;
var spike_array = [];
var SynapseClass = load("res://Synapse.tscn");
var downstream = {};
var destination_ids = [];
var neuron_type = 0;
var target_position = Vector2(0,0)
signal select_neuron;

# Called when the node enters the scene tree for the first time.
func _ready():
	$Name.text = neuron_label
	$SpikeTrain.text = spiketrain
	spike_array.clear()
	var spike_string_array = spiketrain.split(",")
	for character in spike_string_array:
		spike_array.append(int(character))
	set_position(Vector2(1000,1000))
	
func self_destruct():
		for neuron in downstream.keys():
			remove_destination(neuron)
		queue_free()

func reload_spiketrain():
	spike_array.clear()
	var spike_string_array = spiketrain.split(",")
	for character in spike_string_array:
		spike_array.append(int(character))

func refresh_display():
	$Name.text = neuron_label
	$SpikeTrain.text = spiketrain


func activate_neuron():
	$State.color = Color(0.678431,0.047059,0.078431,1)

func deactivate_neuron():
	$State.color = Color(1,1,1,1)
	
func pulse_input(_discard):
	deactivate_neuron()
	if len(spike_array)>cursor:
		if spike_array[cursor] == 1:
			activate_neuron()
			for neuron in downstream:
				downstream[neuron].linked_neuron.add_spikes(1)
		cursor += 1

func start_simulation():
	ongoing_simulation = true

func reset_simulation():
	ongoing_simulation = false
	cursor = 0
	deactivate_neuron()
	
var dragging: bool = false
var neural_canvas

func _on_Handle_button_down():
	if not ongoing_simulation:
		neural_canvas = get_viewport()
		dragging = true

func _on_Handle_button_up():
	dragging = false
	emit_signal("select_neuron",unique_id,0)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var current_position = get_position()
	if dragging and not ongoing_simulation:
		var mouse_position = neural_canvas.get_mouse_position()	
		target_position = Vector2((mouse_position.x-50),(mouse_position.y-47))
		move_and_slide(Vector2((mouse_position.x-50-current_position.x)/delta,(mouse_position.y-47-current_position.y)/delta))
		for every_synapse in downstream:
			var downstream_neuron = downstream[every_synapse].linked_neuron
			downstream[every_synapse].graphed_synapse.connect_neurons(self,downstream_neuron)
	else:
		if current_position.x != target_position.x or current_position.y != target_position.y:
			move_and_slide(Vector2((target_position.x-current_position.x)/delta,(target_position.y-47-current_position.y)/delta))
	
func target(x,y):
	var current_position = get_position()
	if abs(current_position.x - x) < 1 and abs(current_position.y-y) < 1:
			return 
	set_position(Vector2(1000,525))
	target_position = Vector2(x,y)
	
func add_destination(destination_id:int,destination_pointer,graphics_pointer):
	downstream[destination_id] = SynapseClass.instance()
	downstream[destination_id].linked_neuron = destination_pointer
	downstream[destination_id].graphed_synapse = graphics_pointer
	destination_pointer.add_source(unique_id,self,graphics_pointer)

func remove_destination(destination_id: int):
	downstream[destination_id].linked_neuron.remove_source(unique_id)
	downstream[destination_id].graphed_synapse.queue_free()
	downstream.erase(destination_id)

func save_data():
	var saved_synapses = downstream.keys()
	var coordinates = get_position();
	var x = coordinates.x
	var y = coordinates.y
	var saved_data = {"x":x,"y":y,"spiketrain":spiketrain,"neuron_label":neuron_label,"unique_id":unique_id,"synapses":saved_synapses}
	
	return saved_data
	
func load_data(loaded_data):
	spiketrain = loaded_data["spiketrain"]
	neuron_label = loaded_data["neuron_label"]
	unique_id = int(loaded_data["unique_id"])
	var x_position = loaded_data["x"]
	var y_position = loaded_data["y"]
	set_position(Vector2(x_position,y_position))
	target_position = get_position()
	var floating_synapses = loaded_data["synapses"]
	for synapse in floating_synapses:
		destination_ids.append(int(synapse))
	refresh_display()
	reload_spiketrain()
