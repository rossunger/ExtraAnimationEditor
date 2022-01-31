tool
extends Control


func _enter_tree():
	if not Engine.editor_hint:
		queue_free()
	get_tree().call_group("AnimationEditorPlugin", "initDebug", self)	
