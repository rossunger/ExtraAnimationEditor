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

signal keyframeChanged
signal previewContextChanged

var zoom: float = 100 #percent
var zoomY: float = 100 #percent
var scrollX: float = 0 #seconds
var scrollY: float = 0 #tracks

var tracks:Array
export var previewContext: PackedScene setget changeContext
var playrate

func _ready():
	aes.AnimationEditor = self
	
func changeContext(newScene):
	if previewContext == newScene: return
	var context = get_node("PreviewContext")
	for oldScene in context.get_children():
		oldScene.queue_free()
	var s = newScene.instance()
	context.add_child(s)
	previewContext = newScene
