extends Button

var stopIcon = preload("res://icons/icon_stop.svg")
var playIcon = preload("res://icons/icon_play.svg")
func _on_PlayStopButton_pressed():
	if pressed:
		aes.emit_signal("play")
		icon = stopIcon
	else:
		aes.emit_signal("stop")
		icon = playIcon
