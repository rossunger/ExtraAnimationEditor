extends Control
class_name Undoable, "undo_icon.png"

export var resize = true
export var move = true
export var rename = true
export var create = true
export var remove = true
export var drop = true

var parent
var undoList:Array
var redoList:Array
var removed = false

func _ready():	
	parent = get_parent()	
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	call_deferred("connect_signals")
	
	add_to_group("undoable")
	
func connect_signals():
	if parent.has_node("Draggable") && (move or resize):
		parent.connect("startMoveResize", self, "moved_or_resized")
	if rename && parent.has_node("Renameable"):
		parent.connect("doneRenaming", self, "doneRenaming")
	if parent.has_node("ChildAdder"):
		parent.connect("created", self, "created")		
	if parent.has_signal("doRemove"):
		parent.connect("doRemove", self, "doRemove")
		
	connect("tree_exited", self, "onExitingTree" )

func onExitingTree():	
	# For the undo system, when you remove a node from the tree, it has to go somewhere, so we temporarily attach it to the ExtraGuiSingleton
	if !removed:
		egs.add_child(parent)
		removed =true
	else:
		removed = false	
		

func doneRenaming(label, oldName):	
	addUndo({"Type": "Rename", "Who": parent, "Label": label, "OldName": oldName, "time": OS.get_ticks_msec()})

func moved_or_resized(oldRect):		
	addUndo({"Type": "MoveResize", "Who": parent,"OldRect": oldRect, "time": OS.get_ticks_msec()})	

func created(child):	
	addUndo({"Type": "Create", "Parent": parent,"Child": child, "time": OS.get_ticks_msec()})

func doRemove():	
	addUndo({"Type": "Remove", "Parent": parent.get_parent(),"Child": parent, "time": OS.get_ticks_msec ()})

func addUndo(what):
	undoList.push_back(what)
	egs.addUndo(what.time)
	redoList.clear()	

func doUndo(time):	
	# Every undoable action is timestamped
	if !is_visible_in_tree() or undoList.size() == 0 or abs(undoList.back().time - time) >16:
		return
		 
	var u = undoList.pop_back()

	if u.Type == "MoveResize":
		var newRect = u.Who.get_rect()			
		u.Who.rect_position = u.OldRect.position
		u.Who.rect_size = u.OldRect.size		
		u.OldRect = newRect
		redoList.append(u)
	elif u.Type == "Create":
		u.Parent.call_deferred("remove_child",u.Child)
		redoList.append(u)		
	elif u.Type == "Rename":
		var newname = u.Who.name
		u.Who.name = u.OldName
		u.Label.text = u.OldName
		u.oldName = newname
		redoList.append(u)
	elif u.Type == "Drop":
		pass
	elif u.Type == "Remove":
		u.Child.get_parent().remove_child(u.Child)
		u.Parent.add_child(u.Child)
		redoList.append(u)
	
	

func doRedo(time):	
	if !is_visible_in_tree() or redoList.size() == 0 or abs(redoList.back().time - time) >16:
		return
		 
	var u = redoList.pop_back()	
	
	if u.Type == "MoveResize":
		var newRect = u.Who.get_rect()			
		u.Who.rect_position = u.OldRect.position
		u.Who.rect_size = u.OldRect.size		
		u.OldRect = newRect
		undoList.append(u)
		
	elif u.Type == "Create":
		u.Child.get_parent().remove_child(u.Child)
		u.Parent.add_child(u.Child)
		undoList.append(u)
		
	elif u.Type == "Remove":
		u.Parent.call_deferred("remove_child",u.Child)
		undoList.append(u)	
		
	elif u.Type == "Rename":
		var newname = u.Who.name
		u.Who.name = u.OldName
		u.Label.text = u.OldName
		u.oldName = newname
		undoList.append(u)
		
	elif u.Type == "Drop":
		pass

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:        
		for c in undoList:
			if c.has("Child") && is_instance_valid(c.Child):
				get_tree().get_root().add_child(c.Child)
		for c in redoList:
			if c.has("Child") && is_instance_valid(c.Child):
				get_tree().get_root().add_child(c.Child)
