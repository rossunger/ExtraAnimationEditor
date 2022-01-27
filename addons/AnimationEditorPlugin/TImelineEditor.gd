tool
extends Control

#onready var timeValueLabel = $HBoxContainer/TimeValue
#onready var ValueValueLabel = $HBoxContainer/ValueValue

signal zoomChanged

var grid = true		
var zoom = Vector2(100,1)
var offset = Vector2(-12,-12)
var showTimeline = false
var timeline = null
var trackContainer = null
var animation

func _enter_tree():
	get_tree().call_group("AnimationEditorPlugin", "initTimeline", self)
	_on_toggleTimelineButton_pressed()
	
func handleSelection(obj):	
	if obj is ExtraAnimation: 		
		return true	
	
func newAnimation(editedSceneRoot):
	var newAnimation = preload("res://addons/AnimationEditorPlugin/AnimationTemplate.tscn").instance()			
	newAnimation.name = "NewAnimation"
	var packedScene = PackedScene.new()
	packedScene.pack(newAnimation) 
	
	var path = "res://Animations/" + newAnimation.name + ".tscn"
	var file2Check = File.new()
	var i = 0
	if file2Check.file_exists(path):
		while file2Check.file_exists("res://Animations/" + newAnimation.name + "_" + str(i) + ".tscn"):		
			i += 1
		path = "res://Animations/" + newAnimation.name + "_" + str(i) + ".tscn"	
	ResourceSaver.save(path, packedScene)
	newAnimation.filename = path
	editedSceneRoot.add_child(newAnimation)		
	newAnimation.owner = editedSceneRoot
	
func setAnimation(obj= animation):
	if !obj:
		return
	if is_instance_valid(animation):
		if obj.name==animation.name:
			return
	clearAnimation()	
	animation = load(obj.filename).instance()
	animation.filename = obj.filename
	$VBoxContainer.add_child(animation)
	trackContainer = get_node("VBoxContainer/" + animation.name + "/TrackMeta")		
	timeline = get_node("VBoxContainer/" + animation.name + "/Timeline")		
	animation.connect("frameChanged", self, "frameChanged")
	
func clearAnimation():			
	if is_instance_valid(animation):
		animation.queue_free()			

func _on_toggleTimelineButton_pressed():
	showTimeline = !showTimeline
	if showTimeline:		
		for child in get_children():
			if child is ExtraAnimation:				
				child.show()
		rect_min_size.y = 250
	else:
		for child in get_children():
			if child is ExtraAnimation:				
				child.hide()		
		rect_min_size.y = 45
		rect_size.y = 0

func _on_ChangeContextButton_pressed():
	get_tree().call_group("AnimationEditorPlugin", "changeContext")			


func _on_SaveButton_pressed():
	if !animation:
		return	
	get_tree().call_group("AnimationEditorPlugin", "saveChanges", animation)			


func _on_NewAnimationButton_pressed():
	get_tree().call_group("AnimationEditorPlugin", "newAnimation")

func _on_PlayButton_pressed():
	animation.togglePlay()	
	


func _on_ZoomInButton_pressed():
	zoom.x *= 1.05
	$VBoxContainer/StatusBarBackground/ZoomLabel.text = str(floor(zoom.x)) + "%"
	emit_signal("zoomChanged")

func _on_ZoomOutButton_pressed():
	zoom.x /= 1.05
	$VBoxContainer/StatusBarBackground/ZoomLabel.text = str(floor(zoom.x)) + "%"
	emit_signal("zoomChanged")	
	
func frameChanged():
	$VBoxContainer/StatusBarBackground/HBoxContainer/TimeValue.text = str(stepify(animation.position, 0.1))
	var selectedKeys = get_tree().get_nodes_in_group("selected")
	if selectedKeys.size() > 0:
		$VBoxContainer/StatusBarBackground/HBoxContainer/ValueValue.text = str( selectedKeys.back().value )
	else:
		$VBoxContainer/StatusBarBackground/HBoxContainer/ValueValue.text = "--"

