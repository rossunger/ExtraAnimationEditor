extends Node
class_name ExtraAnimationPlayer


var playing = false
var speed = 1
var position = 0
var duration = 10
var root
var tracks = {}
var keyframes = []
var animationFile = "res://animation1.json"

func _ready():
	aes.connect("animationChanged", self, "updateAnimation")
	loadAnimation(animationFile)

func play(anim=animationFile, playSpeed=speed, start=position):
	if anim != animationFile:
		loadAnimation(animationFile)
	playing = true
	position = start
	speed = playSpeed

func stop():
	playing = false
	
func _physics_process(delta):
	if playing:
		position = min(position+ delta * speed, duration)
		aes.emit_signal("frameChanged", position)

	

func play_backwards(anim):
	play(anim, -1, 1)

#This is where we parse the json file for data, but not for nodes
func loadAnimation(path):
	keyframes = []
	tracks.clear()
	root = null
	if !path:
		return
		
	var file =File.new()
	file.open(path, File.READ)
	var data = JSON.parse( file.get_as_text() ).result
	file.close()   
	for d in data:		
		if d.what == "animation":
			root = d			
		elif d.what == "track":
			tracks[d.path_to_parent + "/" + d.name] = d
			tracks[d.path_to_parent + "/" + d.name].keyframes = []
		elif d.what == "keyframe":
			keyframes.push_back(d)
	for k in keyframes:
		tracks[k.path_to_parent].keyframes.push_back(k)

func updateAnimation():			
	loadAnimation(animationFile)
	
