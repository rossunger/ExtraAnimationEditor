extends Button

var dialog: FileDialog
var canvas
	
func file_selected(path):
	aes.emit_signal("contextChanged", load(path))	
	canvas.remove_child(dialog)
	remove_child(canvas)

func _on_ChangeContextButton_pressed():
	if !canvas:
		canvas = CanvasLayer.new()
		canvas.layer = 10
	add_child(canvas)

	dialog = FileDialog.new()
	dialog.mode = FileDialog.MODE_OPEN_FILE
	dialog.invalidate()
	canvas.add_child(dialog)
	dialog.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	dialog.add_filter("*.tscn ; PackedScene")
	dialog.connect("file_selected", self, "file_selected")
	dialog.popup()
