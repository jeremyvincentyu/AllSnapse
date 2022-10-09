extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var RuleClass = load("res://Rule.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Delete_pressed():
	queue_free()

func filled():
	return len($Trigger.text)>0 and len($Consume.text)>0 and len($Release.text)>0 and len($Delay.text)>0
	
func make_rule():
	var new_rule = RuleClass.instance()
	new_rule.trigger = int($Trigger.text)
	new_rule.consume = int($Consume.text)
	new_rule.release = int ($Release.text)
	new_rule.delay = int($Delay.text)
	new_rule.strict = $Strict.is_pressed()
	return new_rule

func load_rule(rule):
	$Strict.set_pressed(rule.strict)
	$Trigger.text = str(rule.trigger)
	$Consume.text = str(rule.consume)
	$Release.text = str(rule.release)
	$Delay.text = str(rule.delay)


