tool
extends EditorPlugin

const root = "res://addons/ExtraGui/"

func _enter_tree():
	add_autoload_singleton("egs", root + "extraGuiSingleton.gd")
	
#clean up
func _exit_tree():
	remove_autoload_singleton("egs")
