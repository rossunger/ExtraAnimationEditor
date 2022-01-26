tool
extends Button

func _on_NewAnimationButton_pressed():	
	get_tree().call_group("AnimationEditorPlugin", "newAnimation")
