extends Control
class_name RemoteHide, "eye_icon.png"

export (NodePath) var who
func _ready():
	who = get_node(who)
	connect("visibility_changed", self, "visibilityChanged")
	connect("tree_entered", self, "doShow")

func visibilityChanged():
	if who:
		who.visible = is_visible_in_tree()
