extends WindowDialog

var context: PackedScene
var selectedObject
var container
var i =0

func _ready():
	container = find_node("ScollContainer")
	var scene = context.instance()	
	buildTreeRecursive(scene, scene, 0)	
	
func buildTreeRecursive(scene, root, treeDepth):		
	for node in root.get_children():
		if node is FileDialog: continue
		var button = Button.new()
		button.name = node.name
		button.text = node.name
		button.align = Button.ALIGN_LEFT	
		button.connect("pressed", self, "selectObject", [scene.get_path_to(node)])	
		container.add_child(button)
		button.rect_position = Vector2(treeDepth * 50, i*30)
		i+=1
		buildTreeRecursive(scene, node, treeDepth+1)
			

func cancel():
	queue_free()

func selectObject(path):
	selectedObject = path
	get_parent().remove_child(self)
	queue_free()
