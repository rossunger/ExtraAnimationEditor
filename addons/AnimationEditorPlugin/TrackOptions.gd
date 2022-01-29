tool
extends PopupDialog
var id 
var previewScene:PackedScene
var objectListBox: ItemList
var propertyListBox: ItemList
var track = null
var trackMeta = null
var trackTitleBox
var objectPathBox
var trackTypeBox 
var propertyPathBox

func _exit_tree():
	if not track:
		return
	updateTrackOptions( track, trackTitleBox.text,objectPathBox.text, propertyPathBox.text, trackTypeBox.selected)

func updateTrackOptions(track, title, object, property, type):		
	track.name = title
	track.object = object
	track.property = property
	track.type = type
	trackMeta.track = track.owner.get_path_to(track)
	trackMeta._enter_tree()

func _ready():		
	if not track:
		return
	trackTitleBox = find_node("TrackName")
	objectPathBox = find_node("ObjectName")
	propertyPathBox	= find_node("PropertyName")
	trackTypeBox	= find_node("TrackType")
		
	trackTitleBox.text = track.name
	trackTypeBox.selected = track.type
	if track.object:
		objectPathBox.text = track.object
	if track.property:
		propertyPathBox.text = track.property
	
	objectListBox = find_node("ObjectList")		
	propertyListBox = find_node("PropertyList")	
	
	if TimelineEditor.animation.defaultPreviewScene:
		previewScene = load(TimelineEditor.animation.defaultPreviewScene)		
		objectListBox.clear()	
		for i in previewScene.get_state().get_node_count():						
			objectListBox.add_item(previewScene.get_state().get_node_path(i))	
	else:
		print("no default scene. Animation: ", TimelineEditor.animation.defaultPreviewScene)
		objectListBox.queue_free()
		propertyListBox.queue_free()
			
func _on_Dimmer_pressed():	
	queue_free()

func _on_ObjectList_item_selected(index):	
	objectPathBox.text = objectListBox.get_item_text(index)
		
	propertyListBox.clear()			
	var obj = ClassDB.instance(previewScene.get_state().get_node_type(index))
	for i in obj.get_property_list(): 
		if i.name.left(1) == i.name.left(1).to_upper():
			continue
		propertyListBox.add_item(i.name)	
	obj.queue_free()	
	propertyListBox.sort_items_by_text()
	
func _on_PropertyList_item_selected(index):
	propertyPathBox.text = propertyListBox.get_item_text(index)
