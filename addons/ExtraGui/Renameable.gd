extends Node
class_name Renameable, "edit_icon.png"

#this component allows you to rename it's parent (and change a corresponding label's text). 
#on right-click, it creates a popup asking for text input

export (NodePath) var who #the label whose text will be changed
var popupScene = preload("renamePopup.tscn")
var popup

var parent #the control to be renamed

func _ready():
	parent = get_parent()
	who = get_node(who)
	who.connect("gui_input", self, "gui_input") #adding code for the Label's Gui_event
	who.text = parent.name
	parent.add_user_signal("doneRenaming")

# called from Draggable via by get_tree().call_group()
func start_renaming():	
	popup = popupScene.instance()
	add_child(popup)
	popup.popup()
	var lineEdit = popup.get_node("NewName")	
	lineEdit.connect("text_entered", self, "done_renaming")
	lineEdit.connect("focus_exited", self, "done_renaming_focus_lost", [lineEdit])
	lineEdit.text = who.text
	lineEdit.grab_focus()
	popup.get_node("TextEdit").connect("focus_entered", lineEdit, "grab_focus")

func done_renaming(newName):
	if parent.name != newName:	
		# You can add a "validate_name" function to the parent if you wish to make sure 
		# the name doesn't exist yet, or use some special criterea for validation
		if !parent.has_method("validate_name") || parent.validate_name(newName):
			parent.emit_signal("doneRenaming", who, parent.name)
			parent.name = newName	
			who.text = newName
		else:
			popup.get_node("error").visible = true
			return
			
	if is_instance_valid(popup):
		popup.queue_free()

func done_renaming_focus_lost(lineEdit):
	done_renaming(lineEdit.text)	

func gui_input(event):
	#on right-click. Change this if you want a different action to trigger renaming
	if event is InputEventMouseButton && event.button_index == 2:
		start_renaming()
