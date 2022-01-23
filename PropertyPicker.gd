extends WindowDialog

var context: Node
var selectedProperty
var container
var i =0
onready var searchBox = $SearchBox
func _ready():
	container = find_node("ScollContainer")
	for prop in context.get_property_list():		
		var button = Button.new()
		button.name = prop.name
		button.text = prop.name
		button.align = Button.ALIGN_LEFT	
		button.connect("pressed", self, "selectProperty", [prop.name])	
		container.add_child(button)
		button.rect_position = Vector2(0, i*30)
		i+=1				
	searchBox.allItems = container.get_children()
	searchBox.connect("search", self, "search")

func cancel():
	queue_free()

func selectProperty(path):
	selectedProperty = path
	get_parent().remove_child(self)
	queue_free()

func search(results):	
	for prop in searchBox.allItems:
		if prop.is_inside_tree() && !results.has(prop):
			container.remove_child(prop)
		else:
			container.add_child(prop)
