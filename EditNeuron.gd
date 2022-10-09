extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var RuleRowClass = load("res://RuleRow.tscn")
var RegexRuleRowClass = load("res://RegexRuleRow.tscn")
var operated_neuron

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func validate_rule(some_rule):
	var consume_at_most_trigger = some_rule.trigger >= some_rule.consume
	var release_at_most_consume = some_rule.consume >= some_rule.release
	return consume_at_most_trigger and release_at_most_consume
	
func _on_Save_pressed():
	#Ascencion Order: Popup, MainUI
	var popup_window = get_parent()
	var rule_box = get_node("ScrollRule/RuleBox")
	var rules = {}
	
	for rule_row in rule_box.get_children():
		if rule_row.filled():
			var new_rule = rule_row.make_rule()
			if not validate_rule(new_rule):
				$InvalidError.popup_centered()
				return
			if new_rule.trigger in rules:
				rules[new_rule.trigger].append(new_rule)
			else:
				rules[new_rule.trigger] = [new_rule]
		else:
			$UnfilledError.popup_centered()
			return
	var neuron_name = $Name.text
	var prespikes = int($Prespikes.text)
	var x = float($x.text)
	var y = float($y.text)
	if not (x>=0.0 and x<=5000.0) or not (y>=0.0 and y<=5000.0):
		$InvalidCoordinatePopup.popup(Rect2(150,80,300,180))
		return
	if prespikes < 0:
		$InvalidSpikesPopup.popup(Rect2(150,80,300,180))
		return
	operated_neuron.neuron_label = neuron_name
	operated_neuron.change_rules(rules)
	operated_neuron.prespikes = prespikes
	operated_neuron.spikes = prespikes
	operated_neuron.target(x,y)
	
	
	for every_synapse in operated_neuron.downstream:
		var other_neuron = operated_neuron.downstream[every_synapse].linked_neuron
		operated_neuron.downstream[every_synapse].graphed_synapse.connect_neurons(operated_neuron,other_neuron)
	
	for every_synapse in operated_neuron.upstream:
		var other_neuron = operated_neuron.upstream[every_synapse].linked_neuron
		operated_neuron.upstream[every_synapse].graphed_synapse.connect_neurons(other_neuron,operated_neuron)
	
	operated_neuron.refresh_display()
	$Name.text = ""
	$Prespikes.text = ""
	
	for neuron in rule_box.get_children():
		neuron.queue_free()
	
	popup_window.hide()
	popup_window.get_parent().restore_scroll()


func _on_Cancel_pressed():
	var rule_box = get_node("ScrollRule/RuleBox")
	$Name.text = ""
	$Prespikes.text = "0"
	for neuron in rule_box.get_children():
		neuron.queue_free()
	get_parent().hide()
	get_parent().get_parent().restore_scroll()


func _on_New_pressed():
	var rule_box = get_node("ScrollRule/RuleBox")
	rule_box.add_child(RuleRowClass.instance())

func preconfigure(source_neuron):
	operated_neuron = source_neuron
	var neuron_coordinates = operated_neuron.get_position()
	$Name.text = operated_neuron.neuron_label
	$Prespikes.text = str(source_neuron.prespikes)
	$x.text = str(neuron_coordinates.x)
	$y.text = str(neuron_coordinates.y)
	var rule_box = get_node("ScrollRule/RuleBox")
	for trigger in source_neuron.rules:
		for rule in source_neuron.rules[trigger]:
			var new_rule_row = RuleRowClass.instance()
			new_rule_row.load_rule(rule)
			rule_box.add_child(new_rule_row)


func _on_NewRegex_pressed():
	var rule_box = get_node("ScrollRule/RuleBox")
	rule_box.add_child(RegexRuleRowClass.instance())
