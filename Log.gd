extends Popup

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Export_pressed():
	$ExportDialog.popup()


func _on_Close_Log_pressed():
	hide()

func set_text(logged_text: String):
	$Log.text = logged_text


func _on_ExportDialog_file_selected(path):
	var log_file = File.new()
	log_file.open(path,File.WRITE)
	log_file.store_string($Log.text)
	log_file.close()
