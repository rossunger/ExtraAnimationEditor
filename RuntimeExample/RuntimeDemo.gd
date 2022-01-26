extends Control

var animationController
func _ready():
	animationController = $AnimationController


func _on_Button_pressed():
	animationController.play("ExtraAnimation")	
