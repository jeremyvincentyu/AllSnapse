extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var RuleClass = load("res://Rule.tscn")
var consume: int;
var delay: int;
var trigger: int;
var release: int;
var strict = true;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Delete_pressed():
	queue_free()

func filled():
	return len($Rule.text)>0
	
func make_rule():
	parse_rule()
	var new_rule = RuleClass.instance()
	new_rule.consume = consume
	new_rule.trigger = trigger
	new_rule.release = release
	new_rule.delay = delay
	new_rule.strict = strict
	return new_rule

func parse_rule():
	var source_text = $Rule.text
	var trigger_others = source_text.split("/")
	
	#Step 1: Recover trigger and strict
	var trigger_array = trigger_others[0].split("a")
	
	#Check if trigger is strict
	if trigger_array[1] == "*":
		strict = false
	
	trigger = extract_coefficient(trigger_others[0])
	
	#Step 2: Recover Consume
	var consume_others = trigger_others[1].split("->")
	consume = extract_coefficient(consume_others[0])

	#Step 3: Recover Release
	var release_delay = consume_others[1].split(";")
	release = 	extract_coefficient(release_delay[0])
	
	#Step 4: Recover Delay
	if len(release_delay) == 2:
		delay= int(release_delay[1])
	else:
		delay = 0
		
func extract_coefficient(some_expression):
	var decomposed = some_expression.split("a")
	#Case where rule has no coefficient
	if len(decomposed[0]) == 0:
		return 1
	#Case where rule is preceded by coefficient
	else:
		return int(decomposed[0])
		

	
