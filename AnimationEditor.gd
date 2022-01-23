# NAIMATION EDITOR
#
# Must have:
# - Timeline editing, with curves and keyframes
# - Live preview without affecting the original
# - Relative value keyframes
# - Easily change who each track is animating (parameterised
# - undo/redo 
# - Modifiable playrate (play backwards, play speed modifier
# - Preview in different contexts
# - Drag keyframes onto different tracks
# - Emit signals / call functions?
# - Can accept keyframes that are pointers to other objects (IK style) 
# - nested animations
extends Node


var zoom: float = 100 #percent
var zoomY: float = 100 #percent
var scrollX: float = 0 #seconds
var scrollY: float = 0 #tracks

var tracks:Array


var animationPlayer

var defaultAnimationContext = preload("res://DefaultAnimationContext.tscn")

func _ready():
	animationPlayer = find_node("Animation")
	aes.connect("play", animationPlayer, "play")
	aes.connect("stop", animationPlayer, "stop")
	aes.connect("contextChanged", self, "changeContext")	
	aes.connect("animationChanged", animationPlayer, "updateAnimation")
	animationPlayer.connect("frameChanged", aes, "frameChanged")
	changeContext(defaultAnimationContext)	
	
func changeContext(newScene):
	if aes.previewContext == newScene: return
	var context = find_node("PreviewContext")
	for oldScene in context.get_children():
		oldScene.queue_free()
	var s = newScene.instance()
	context.add_child(s)
	aes.previewContext = newScene
