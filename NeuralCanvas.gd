extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var anchored = false
var neuron_database = {}
var input_database = {}
var output_database = {}
var counter = 0;
var NeuronClass = load("res://Neuron.tscn")
var InputNeuronClass = load("res://InputNeuron.tscn")
var OutputNeuronClass = load("res://OutputNeuron.tscn")
var ArrowClass = load("res://Arrow.tscn")
var RoundResultClass = load("res://RoundResult.tscn")
var active_neuron = -1
var active_neuron_type = -1
var source_neuron = -1
var source_neuron_type = -1
var connect_mode: bool = false
var disconnect_mode: bool = false
var input_rounds = {}
var neuron_rounds = {}
var output_rounds = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func delete_active_neuron():
	if active_neuron_type == -1:
		return
	var type_to_database = {0:input_database,1:neuron_database,2:output_database}
	type_to_database[active_neuron_type][active_neuron].self_destruct()
	type_to_database[active_neuron_type].erase(active_neuron)
	active_neuron = -1
	active_neuron_type = -1
	
func clear_canvas():
	for neuron in input_database.keys():
		input_database[neuron].self_destruct()
		input_database.erase(neuron)
	
	for neuron in neuron_database.keys():
		neuron_database[neuron].self_destruct()
		neuron_database.erase(neuron)
	
	for neuron in output_database.keys():
		output_database[neuron].self_destruct()
		output_database.erase(neuron)
	
	active_neuron = -1
	active_neuron_type = -1

func connect_neurons():
	if active_neuron_type == 0 or active_neuron_type == -1 or active_neuron == source_neuron:
		connect_mode =false
		return	
		
	var type_to_db = {0: input_database,1: neuron_database, 2:output_database}
	var source_neuron_pointer = type_to_db[source_neuron_type][source_neuron]
	var destination_neuron_pointer = type_to_db[active_neuron_type][active_neuron]
	connect_source_destination(source_neuron_pointer,destination_neuron_pointer)
	connect_mode = false

func connect_source_destination(source,destination):
	if active_neuron in source.downstream:
		return
	var new_arrow = ArrowClass.instance()
	var destination_id = destination.unique_id
	source.add_destination(destination_id,destination,new_arrow)
	add_child(new_arrow)
	new_arrow.connect_neurons(source,destination)
	

func disconnect_neurons():
	if active_neuron_type == 0 or active_neuron_type == -1:
		disconnect_mode =false
		return	
	var type_to_db = {0: input_database,1: neuron_database, 2:output_database}
	var source_neuron_pointer = type_to_db[source_neuron_type][source_neuron]
	if active_neuron in source_neuron_pointer.downstream:
		source_neuron_pointer.remove_destination(active_neuron)
	disconnect_mode = false
	
func set_active_neuron(unique_id: int,neuron_type: int):
	var type_to_database = {0:input_database,1:neuron_database,2:output_database}
	if not active_neuron_type == -1:
		var old_neuron_pointer = type_to_database[active_neuron_type][active_neuron]
		var old_neuron_state = old_neuron_pointer.get_node("State")
		old_neuron_state.color = Color(1,1,1,1)
	self.active_neuron = unique_id
	self.active_neuron_type = neuron_type
	var active_neuron_pointer = type_to_database[active_neuron_type][active_neuron]
	var active_neuron_state = active_neuron_pointer.get_node("State")
	active_neuron_state.color = Color(0,0,1,1)
	if connect_mode:
		connect_neurons()
	if disconnect_mode:
		disconnect_neurons()
		
func return_active_neuron():
	if active_neuron_type == -1:
		return null
			
	var type_to_db = {0:input_database,1:neuron_database,2:output_database}
	return type_to_db[active_neuron_type][active_neuron]
	
#neuron_rules is a dict with integer keys and list values
func new_neuron(neuron_label: String, neuron_rules: Dictionary, prespikes: int,x: float, y: float):
	var neuron_id = counter
	counter += 1
	neuron_database[neuron_id] = NeuronClass.instance()
	neuron_database[neuron_id].prespikes = prespikes
	neuron_database[neuron_id].spikes = prespikes
	neuron_database[neuron_id].neuron_label = neuron_label
	neuron_database[neuron_id].unique_id = neuron_id
	neuron_database[neuron_id].rules = neuron_rules
	add_child(neuron_database[neuron_id])
	neuron_database[neuron_id].target(x,y)
	neuron_database[neuron_id].connect("select_neuron",self,"set_active_neuron")

func new_input(neuron_label: String,spiketrain: String,x:float,y:float):
	var input_id = counter
	counter += 1
	input_database[input_id] = InputNeuronClass.instance()
	input_database[input_id].spiketrain = spiketrain
	input_database[input_id].neuron_label = neuron_label
	input_database[input_id].unique_id = input_id
	print("Adding neuron ", counter)
	add_child(input_database[input_id])
	input_database[input_id].target(x,y)
	input_database[input_id].connect("select_neuron",self,"set_active_neuron")

func new_output(neuron_label: String,x:float,y:float):
	var output_id = counter
	counter += 1
	output_database[output_id] = OutputNeuronClass.instance()
	output_database[output_id].neuron_label = neuron_label
	output_database[output_id].unique_id = output_id
	add_child(output_database[output_id])
	output_database[output_id].target(x,y)
	output_database[output_id].connect("select_neuron",self,"set_active_neuron")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func enable_connect_mode():
	if active_neuron_type == 2 or active_neuron_type == -1:
		return
	source_neuron = active_neuron
	source_neuron_type = active_neuron_type
	disconnect_mode = false
	connect_mode = true
	print("connect mode activated")

func enable_disconnect_mode():
	if active_neuron_type == 2 or active_neuron_type == -1:
		return
	source_neuron = active_neuron
	source_neuron_type = active_neuron_type
	connect_mode = false
	disconnect_mode = true

func save_data():
	var saved_input_neurons = {}
	var saved_neurons = {}
	var saved_output_neurons = {}
	
	for neuron in input_database:
		saved_input_neurons[neuron] = input_database[neuron].save_data()
	
	for neuron in neuron_database:
		saved_neurons[neuron] = neuron_database[neuron].save_data()
	
	for neuron in output_database:
		saved_output_neurons[neuron] = output_database[neuron].save_data()
		
	var saved_data = {"counter":counter,"input": saved_input_neurons,"neurons": saved_neurons,"output":saved_output_neurons}
	
	return saved_data

func find_database(neuron_id: int):
	var databases = [input_database,neuron_database,output_database]
	for database in databases:
		if neuron_id in database:
			return database

func load_data(loaded_data: Dictionary):
	clear_canvas()
	
	counter = int(loaded_data["counter"])
	
	var loaded_inputs = loaded_data["input"]
	var loaded_neurons = loaded_data["neurons"]
	var loaded_outputs = loaded_data["output"]
	
	for input_id in loaded_inputs:
		var reconstructed_neuron = InputNeuronClass.instance()
		add_child(reconstructed_neuron)
		reconstructed_neuron.load_data(loaded_inputs[input_id])
		reconstructed_neuron.connect("select_neuron",self,"set_active_neuron")
		input_database[int(input_id)] = reconstructed_neuron
		
	for neuron_id in loaded_neurons:
		var reconstructed_neuron = NeuronClass.instance()
		add_child(reconstructed_neuron)
		reconstructed_neuron.load_data(loaded_neurons[neuron_id])
		reconstructed_neuron.connect("select_neuron",self,"set_active_neuron")
		neuron_database[int(neuron_id)] = reconstructed_neuron
	
	for output_id in loaded_outputs:
		var reconstructed_neuron = OutputNeuronClass.instance()
		add_child(reconstructed_neuron)
		reconstructed_neuron.load_data(loaded_outputs[output_id])
		reconstructed_neuron.connect("select_neuron",self,"set_active_neuron")
		output_database[int(output_id)] = reconstructed_neuron
	
	for input_id in input_database:
		var destination_ids = input_database[input_id].destination_ids
		for destination_id in destination_ids:
			var destination_database = find_database(destination_id)
			connect_source_destination(input_database[input_id],destination_database[destination_id])
	
	for neuron_id in neuron_database:
		var destination_ids = neuron_database[neuron_id].destination_ids
		for destination_id in destination_ids:
			var destination_database = find_database(destination_id)
			connect_source_destination(neuron_database[neuron_id],destination_database[destination_id])	
	
func reset_simulation():
	$Stepper.set_paused(false)
	$Stepper.stop()
	var databases = [input_database,neuron_database,output_database]
	for database in databases:
		for neuron in database:
			database[neuron].reset_simulation()
	
	var rounds = [input_rounds,neuron_rounds,output_rounds]
	
	for round_type in rounds:
		for some_round in round_type:
			round_type[some_round].free()
			round_type.erase(some_round)
	
	
func start_simulation(step_time: float):
	var type_to_database = {0:input_database,1:neuron_database,2:output_database}
	if not active_neuron_type == -1:
		var old_neuron_pointer = type_to_database[active_neuron_type][active_neuron]
		var old_neuron_state = old_neuron_pointer.get_node("State")
		old_neuron_state.color = Color(1,1,1,1)
	var databases = [input_database,neuron_database,output_database]
	var rounds = [input_rounds,neuron_rounds,output_rounds]
	
	for index in [0,1,2]:
		for neuron in databases[index]:
			databases[index][neuron].start_simulation()
			rounds[index][neuron] = RoundResultClass.instance()
	
	$Stepper.wait_time = step_time
	$Stepper.start()
	single_step()

func single_step():
	#Execute Rules for Round
	for input_neuron in input_database:
		input_rounds[input_neuron].associated_thread = Thread.new()
		input_rounds[input_neuron].old_cursor = input_database[input_neuron].cursor
		input_rounds[input_neuron].associated_thread.start(input_database[input_neuron],"pulse_input")
	
	for neuron in neuron_database:
		neuron_rounds[neuron].associated_thread = Thread.new()
		neuron_rounds[neuron].old_spikes = neuron_database[neuron].spikes
		neuron_rounds[neuron].associated_thread.start(neuron_database[neuron],"evaluate_rules")
	
	#Wait for Rule Execution to Finish
	var firers = [input_rounds,neuron_rounds]
	for firer in firers:
		for neuron in firer:
			firer[neuron].associated_thread.wait_to_finish()
	
	#Update Spikes in accordance with Round Results
	for neuron in neuron_database:
		neuron_rounds[neuron].associated_thread = Thread.new()
		neuron_rounds[neuron].associated_thread.start(neuron_database[neuron],"collect_spikes")
		
	for output_neuron in output_database:
		output_rounds[output_neuron].associated_thread = Thread.new()
		output_rounds[output_neuron].associated_thread.start(output_database[output_neuron],"collect_spikes")
	
	#Wait for Spike Collection to Finish
	var collectors = [neuron_rounds,output_rounds]
	for collector in collectors:
		for neuron in collector:
			collector[neuron].associated_thread.wait_to_finish()
			
	var evolution = false
	#Check if Neural network has evolved at all.
	for input_neuron in input_database:
		var cursor_evolution = input_database[input_neuron].cursor != input_rounds[input_neuron].old_cursor
		evolution = evolution or cursor_evolution 
	
	for neuron in neuron_database:
		var spike_evolution = neuron_database[neuron].spikes != neuron_rounds[neuron].old_spikes
		if neuron_database[neuron].delay>0:
			evolution = true
			break
		evolution = evolution or spike_evolution 
	
	#If not, stop the Stepper
	if not evolution:
		$Stepper.stop()
		
func single_step_serial():
	#Execute Rules for Round
	for input_neuron in input_database:
		input_rounds[input_neuron].old_cursor = input_database[input_neuron].cursor
		input_database[input_neuron].pulse_input(0)
	
	for neuron in neuron_database:
		neuron_rounds[neuron].old_spikes = neuron_database[neuron].spikes
		neuron_database[neuron].evaluate_rules(0)
	
	#Update Spikes in accordance with Round Results
	for neuron in neuron_database:
		neuron_database[neuron].collect_spikes(0)
		
	for output_neuron in output_database:
		output_database[output_neuron].collect_spikes(0)
	
			
	var evolution = false
	#Check if Neural network has evolved at all.
	for input_neuron in input_database:
		var cursor_evolution = input_database[input_neuron].cursor != input_rounds[input_neuron].old_cursor
		evolution = evolution or cursor_evolution 
	
	for neuron in neuron_database:
		var spike_evolution = neuron_database[neuron].spikes != neuron_rounds[neuron].old_spikes
		evolution = evolution or spike_evolution 
	
	#If not, stop the Stepper
	if not evolution:
		$Stepper.stop()

func pause_simulation():
	$Stepper.set_paused(not $Stepper.is_paused())
	return $Stepper.is_paused()
