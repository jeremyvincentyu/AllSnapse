extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cached_hscroll: int;
var cached_vscroll: int;
var ongoing_simulation = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "Android":
		$SaveDialog.set_current_dir("/storage/emulated/0/Download")
		$LoadDialog.set_current_dir("/storage/emulated/0/Download")
func simulation_guard():
	if ongoing_simulation:
		$DisablePopup.popup(Rect2(240,170,650,301))
	return ongoing_simulation
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Start_pressed():
	if ongoing_simulation:
		$StillSimulating.popup(Rect2(240,170,650,301))
		return
	ongoing_simulation = true
	var neural_canvas = get_node("ScrollContainer/ViewportContainer/Viewport/NeuralCanvas")
	neural_canvas.start_simulation(float($StepTime.text))
	$Indicator.color = Color(0,1,0,1)
	$StepTime.set_readonly(true)

func _on_Input_pressed():
	if simulation_guard():
		return
	cache_scroll()
	$InputPopup.popup(Rect2(240,170,650,301))

func _on_New_pressed():
	if simulation_guard():
		return
	cache_scroll()
	$NewPopup.popup(Rect2(240,170,650,301))

func _on_Output_pressed():
	if simulation_guard():
		return
	cache_scroll()
	$OutputPopup.popup(Rect2(240,170,650,301))
	
func cache_scroll():
	cached_hscroll= $ScrollContainer.get_h_scroll()
	cached_vscroll = $ScrollContainer.get_v_scroll()
	$ScrollContainer.set_h_scroll(7000)
	$ScrollContainer.set_v_scroll(7000)
	
func restore_scroll():
	$ScrollContainer.set_h_scroll(cached_hscroll)
	$ScrollContainer.set_v_scroll(cached_vscroll)


func config_input(source_neuron):
	get_node("InputPopup/NewInput").preconfigure(source_neuron)
	_on_Input_pressed()

func config_neuron(source_neuron):
	get_node("NewPopup/NewNeuron").preconfigure(source_neuron)
	_on_New_pressed()

	
func _on_Duplicate_pressed():
	if simulation_guard():
		return
	var neural_canvas = get_node("ScrollContainer/ViewportContainer/Viewport/NeuralCanvas")
	var active_neuron_type = neural_canvas.active_neuron_type
	if active_neuron_type != -1 and active_neuron_type != 2:
		var active_neuron = neural_canvas.return_active_neuron()
		var type_to_preconfig = {0:"config_input",1:"config_neuron"}
		call(type_to_preconfig[active_neuron_type],active_neuron)


func _on_Connect_pressed():
	if simulation_guard():
		return
	var neural_canvas = get_node("ScrollContainer/ViewportContainer/Viewport/NeuralCanvas")
	neural_canvas.enable_connect_mode()


func _on_Disconnect_pressed():
	if simulation_guard():
		return
	var neural_canvas = get_node("ScrollContainer/ViewportContainer/Viewport/NeuralCanvas")
	neural_canvas.enable_disconnect_mode()

func edit_input(source_neuron):
	get_node("EditInputPopup/EditInput").preconfigure(source_neuron)
	$EditInputPopup.popup(Rect2(240,170,650,301))

func edit_neuron(source_neuron):
	get_node("EditNeuronPopup/EditNeuron").preconfigure(source_neuron)
	$EditNeuronPopup.popup(Rect2(240,170,650,301))

func edit_output(source_neuron):
	get_node("EditOutputPopup/EditOutput").preconfigure(source_neuron)
	$EditOutputPopup.popup(Rect2(240,170,650,301))

func _on_Edit_pressed():
	if simulation_guard():
		return
	var type_to_editor = {0: "edit_input",1: "edit_neuron",2:"edit_output"}
	var neural_canvas = get_node("ScrollContainer/ViewportContainer/Viewport/NeuralCanvas")
	var active_neuron_type = neural_canvas.active_neuron_type
	if active_neuron_type != -1:
		cache_scroll()
		var active_neuron = neural_canvas.return_active_neuron()
		call(type_to_editor[active_neuron_type],active_neuron)


func _on_Delete_pressed():
	if simulation_guard():
		return
	var neural_canvas = get_node("ScrollContainer/ViewportContainer/Viewport/NeuralCanvas")
	neural_canvas.delete_active_neuron()


func _on_Clear_pressed():
	if simulation_guard():
		return
	var neural_canvas = get_node("ScrollContainer/ViewportContainer/Viewport/NeuralCanvas")
	neural_canvas.clear_canvas()


func _on_Save_pressed():
	if simulation_guard():
		return
	cache_scroll()
	$SaveDialog.popup(Rect2(240,170,650,301))


func _on_FileDialog_file_selected(path):
	var step_time = int($StepTime.text)
	var neural_canvas = get_node("ScrollContainer/ViewportContainer/Viewport/NeuralCanvas")
	var neural_map_data = neural_canvas.save_data()
	var save_state = {"step_time":step_time,"neural_map_data":neural_map_data}
	var json_save = to_json(save_state)
	var save_file = File.new()
	save_file.open(path,File.WRITE)
	save_file.store_string(json_save)
	restore_scroll()


func _on_Load_pressed():
	if simulation_guard():
		return
	cache_scroll()
	$LoadDialog.popup(Rect2(240,170,650,301))


func _on_LoadDialog_file_selected(path):
	var data_file = File.new()
	data_file.open(path,File.READ)
	var parsed_data = JSON.parse(data_file.get_as_text())
	data_file.close()
	if parsed_data.get_error() != OK:
		$InvalidFilePopup.popup(Rect2(240,170,650,301))
		restore_scroll()
		return
	var loaded_data = parsed_data.get_result()
	$StepTime.text = str(loaded_data["step_time"])
	var neural_canvas = get_node("ScrollContainer/ViewportContainer/Viewport/NeuralCanvas")
	neural_canvas.load_data(loaded_data["neural_map_data"])
	restore_scroll()


func _on_SaveDialog_popup_hide():
	restore_scroll()


func _on_LoadDialog_popup_hide():
	restore_scroll()


func _on_Reset_pressed():
	ongoing_simulation = false
	var neural_canvas = get_node("ScrollContainer/ViewportContainer/Viewport/NeuralCanvas")
	neural_canvas.reset_simulation()
	$Indicator.color = Color(1,0,0,1)
	$Pause.text = "Pause Simulation"
	$StepTime.set_readonly(false)

func _on_Pause_pressed():
	if not ongoing_simulation:
		$NotYetSimulating.popup(Rect2(240,170,650,301))
		return
		
	
	var neural_canvas = get_node("ScrollContainer/ViewportContainer/Viewport/NeuralCanvas")
	
	if neural_canvas.pause_simulation():
		$Indicator.color = Color(1,1,0,1)
		$Pause.text = "Resume Simulation"
	else:
		$Indicator.color = Color(0,1,0,1)
		$Pause.text = "Pause Simulation"


func _on_ViewLog_pressed():
	cache_scroll()
	var neural_canvas = get_node("ScrollContainer/ViewportContainer/Viewport/NeuralCanvas")
	$Log.set_text(neural_canvas.dump_log())
	$Log.popup(Rect2(119,42,1128,587))


func _on_Log_popup_hide():
	restore_scroll()
