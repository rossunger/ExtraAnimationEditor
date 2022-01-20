tool
extends Node
class_name ExtraAnimationPlayer
var playing = false
var speed = 1
var position = 0
export (String, FILE, "*.json") var animationFile setget changeAnimation

func _ready():
	changeAnimation(animationFile)

func play(anim, playSpeed=1, start=0):
	playing = true
	position = start
	speed = playSpeed
	
func _physics_process(delta):
	if !playing: return

	

func play_backwards(anim):
	play(anim, -1, 1)

func changeAnimation(path):
	animationFile = path
	var file =File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()   
	var data = JSON.parse(content).result
	print(data)
	
