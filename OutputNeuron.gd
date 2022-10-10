extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var neuron_label: String;
export var unique_id: int;
export var ongoing_simulation: bool = false;
var current_state = 0;
var spike_array = [];
var upstream = {};
var neuron_type = 2;
var SynapseClass = load("res://Synapse.tscn");
var collector_lock = Mutex.new()
var target_position = Vector2(0,0)
var neuron_log = ""
signal select_neuron;
# Called when the node enters the scene tree for the first time.
func _ready():
	$Name.text = neuron_label
	set_position(Vector2(1000,1000))
func self_destruct():
	queue_free()

func refresh_display():
	$Name.text = neuron_label
	
func start_simulation():
	ongoing_simulation = true

func reset_simulation():
	ongoing_simulation = false
	$History.text = ""
	
func collect_spikes(_discard):
	$History.text += str(current_state)
	var report = ""
	if current_state > 0:
		var neuron_format = "Output neuron {neuron_label}, with uid {unique_id}, received {current_state} spikes."
		report = neuron_format.format({"neuron_label":neuron_label,"unique_id":str(unique_id),"current_state":str(current_state)})
	current_state = 0
	return report

func add_spikes(new_spikes: int):
	#print("Output neuron add spikes triggered")
	collector_lock.lock()
	current_state += new_spikes
	collector_lock.unlock()

var dragging: bool = false
var neural_canvas

func _on_Handle_button_down():
	if not ongoing_simulation:
		neural_canvas = get_viewport()
		dragging = true

func _on_Handle_button_up():
	dragging = false
	emit_signal("select_neuron",unique_id,2)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var current_position = get_position()
	if dragging and not ongoing_simulation:
		var mouse_position = neural_canvas.get_mouse_position()
		target_position = Vector2(mouse_position.x-75,mouse_position.y-47)
		move_and_slide(Vector2((mouse_position.x-75-current_position.x)/delta,(mouse_position.y-47-current_position.y)/delta))
		for every_synapse in upstream:
			var upstream_neuron = upstream[every_synapse].linked_neuron
			upstream[every_synapse].graphed_synapse.connect_neurons(upstream_neuron,self)
	else:
		if current_position.x != target_position.x or current_position.y != target_position.y:
			move_and_slide(Vector2((target_position.x-current_position.x)/delta,(target_position.y-current_position.y)/delta))
func target(x,y):
	var current_position = get_position()
	if abs(current_position.x - x) < 1 and abs(current_position.y-y) < 1:
			return 
	set_position(Vector2(1000,525))
	target_position = Vector2(x,y)

func add_source(source_id: int, source_pointer,graphics_pointer):
	upstream[source_id] = SynapseClass.instance()
	upstream[source_id].linked_neuron = source_pointer
	upstream[source_id].graphed_synapse = graphics_pointer

func remove_source(source_id: int):
	upstream.erase(source_id)

func save_data():
	var coordinates = get_position();
	var x = coordinates.x
	var y = coordinates.y
	var saved_data = {"x":x,"y":y,"neuron_label":neuron_label,"unique_id":unique_id}
	
	return saved_data
	
func load_data(loaded_data):
	neuron_label = loaded_data["neuron_label"]
	unique_id = int(loaded_data["unique_id"])
	var x_position = loaded_data["x"]
	var y_position = loaded_data["y"]
	set_position(Vector2(x_position,y_position))
	target_position = get_position()
	refresh_display()
