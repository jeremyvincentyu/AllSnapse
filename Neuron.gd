extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var prespikes: int;
export var neuron_label: String;
export var unique_id: int;
export var ongoing_simulation: bool = false;

signal select_neuron;

var spikes: int;
var next_round_spikes: int = 0;
var spike_collector_lock = Mutex.new();
var rules: Dictionary; #Rules is a dict with integer keys and list values
var downstream = {};
var destination_ids = [];
var upstream = {};
var neuron_type = 1;
var SynapseClass = load("res://Synapse.tscn");
var RuleClass = load("res://Rule.tscn")
var delay = 0;
var delayed_rule;
var target_position = Vector2(0,0);
var neuron_log = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	var abbreviate_bool = {true:"T",false:"F"}
	$Name.text = neuron_label
	$Spike_Count.text = str(prespikes)
	for trigger_event in rules:
		for rule in rules[trigger_event]:
			$RulePreview.text += "T: " + str(rule.trigger) +","
			$RulePreview.text += "C: " + str(rule.consume) +","
			$RulePreview.text += "R: " + str(rule.release) +","
			$RulePreview.text += "D: " + str(rule.delay) +","
			$RulePreview.text += "S: " + abbreviate_bool[rule.strict] +"\n"
	set_position(Vector2(1000,1000))
func self_destruct():
	for neuron in downstream.keys():
		remove_destination(neuron)
		
	for neuron in upstream.keys():
		var source_neuron_pointer = upstream[neuron].linked_neuron
		source_neuron_pointer.remove_destination(unique_id)	
	
	for trigger in rules:
		for rule in rules[trigger]:
			rule.free()
	queue_free()

func refresh_display():
	var abbreviate_bool = {true:"T",false:"F"}
	$Name.text = neuron_label
	$Spike_Count.text = str(spikes)
	$RulePreview.text = ""
	for trigger_event in rules:
		for rule in rules[trigger_event]:
			$RulePreview.text += "T: " + str(rule.trigger) +","
			$RulePreview.text += "C: " + str(rule.consume) +","
			$RulePreview.text += "R: " + str(rule.release) +","
			$RulePreview.text += "D: " + str(rule.delay) +","
			$RulePreview.text += "S: " + abbreviate_bool[rule.strict] +"\n"
	
func activate_neuron():
	$State.color = Color(0.678431,0.047059,0.078431,1)

func deactivate_neuron():
	$State.color = Color(1,1,1,1)
	
func evaluate_rules(_discard):
	if delay > 0:
		delay -= 1
		if delay == 0:
			activate_neuron()
			for neuron in downstream:
				downstream[neuron].linked_neuron.add_spikes(delayed_rule.release)
		return
	deactivate_neuron()
	var applicable = []
	for ruletrigger in rules:
		var ruleset = rules[ruletrigger] 
		for rule in ruleset:
			if rule.strict:
				if spikes == rule.trigger:
					applicable.append(rule)
			else:
				if spikes >= rule.trigger:
					applicable.append(rule)
					
	if len(applicable)>0:
		var chosen_rule = applicable[randi()%len(applicable)]
		var neuron_format = "neuron {neuron_label}, with uid {unique_id}, having {spikes} spikes, committed to {some_rule}."
		neuron_log = neuron_format.format({"neuron_label":neuron_label,"unique_id":str(unique_id),"some_rule":to_json(chosen_rule.save_data()),"spikes":str(spikes)})
		spikes -= chosen_rule.consume
		$Spike_Count.text = str(spikes)
		if chosen_rule.delay>0:
			delayed_rule = chosen_rule
			delay = delayed_rule.delay
			return
		activate_neuron()
		for neuron in downstream:
			downstream[neuron].linked_neuron.add_spikes(chosen_rule.release)

func collect_spikes(_discard):
	if delay >0:
		refresh_display()
		next_round_spikes = 0
		return ""
	
	spikes += next_round_spikes
	next_round_spikes = 0
	refresh_display()
	var current_log = neuron_log
	neuron_log = ""
	return current_log
	
func add_spikes(new_spikes: int):
	if delay>0:
		return
	spike_collector_lock.lock()
	next_round_spikes += new_spikes
	spike_collector_lock.unlock()

func start_simulation():
	ongoing_simulation = true

func reset_simulation():
	ongoing_simulation = false
	spikes = prespikes
	$Spike_Count.text= str(spikes)
	deactivate_neuron()

var dragging: bool = false
var neural_canvas

func _on_Handle_button_down():
	if not ongoing_simulation:
		neural_canvas = get_viewport()
		dragging = true

func _on_Handle_button_up():
	dragging = false
	emit_signal("select_neuron",unique_id,1)
	
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
		for every_synapse in upstream:
			var upstream_neuron = upstream[every_synapse].linked_neuron
			upstream[every_synapse].graphed_synapse.connect_neurons(upstream_neuron,self)
	else:
		if current_position.x != target_position.x or current_position.y != target_position.y:
			move_and_slide(Vector2((target_position.x-current_position.x)/delta,(target_position.y-current_position.y)/delta))

func target(x,y):
	var current_position = get_position()
	if abs(current_position.x - x) < 1 and abs(current_position.y - y)<1:
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
	downstream[destination_id].free()
	downstream.erase(destination_id)

func add_source(source_id: int, source_pointer,graphics_pointer):
	upstream[source_id] = SynapseClass.instance()
	upstream[source_id].linked_neuron = source_pointer
	upstream[source_id].graphed_synapse = graphics_pointer
	

func remove_source(source_id: int):
	upstream[source_id].free()
	upstream.erase(source_id)
	
func change_rules(new_rules: Dictionary):
	for trigger in rules:
		for rule in rules[trigger]:
			rule.free()
	rules = new_rules

func save_data():
	var saved_synapses = downstream.keys()
	var coordinates = get_position();
	var x = coordinates.x
	var y = coordinates.y
	var saved_rules = {};
	
	for trigger in rules:
		saved_rules[trigger] = []
		for rule in rules[trigger]:
			saved_rules[trigger].append(rule.save_data())
	
	var saved_data = {"x":x,"y":y,"prespikes":prespikes,"neuron_label":neuron_label,"unique_id":unique_id,"synapses":saved_synapses,"saved_rules":saved_rules}
	return saved_data
	
func load_data(loaded_data):
	prespikes = int(loaded_data["prespikes"])
	spikes = prespikes
	neuron_label = loaded_data["neuron_label"]
	unique_id = int(loaded_data["unique_id"])
	var x_position = loaded_data["x"]
	var y_position = loaded_data["y"]
	set_position(Vector2(x_position,y_position))
	target_position = get_position()
	var floating_synapses = loaded_data["synapses"]
	for synapse in floating_synapses:
		destination_ids.append(int(synapse))
	var loaded_rules = loaded_data["saved_rules"]
	
	for trigger in loaded_rules:
		rules[int(trigger)] = []
		for rule in loaded_rules[trigger]:
			var reconstructed_rule = RuleClass.instance()
			reconstructed_rule.load_data(rule)
			rules[int(trigger)].append(reconstructed_rule)
			
	refresh_display()
