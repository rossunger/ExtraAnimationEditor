extends OptionButton
class_name EnumDropdown, "list_icon.png"

# This control lets you use an Enum to fill a drop-down box (aka option button)
# Use the .selected property to get the enum value that was chosen

export var enum_name = "test_enum"
export var singleton_name = "egs"

func _enter_tree():
	if enum_name:	
		var o = get_tree().get_root().get_node(singleton_name)
		var e = o.get(enum_name)
		for k in e.keys():					
			add_item(k.replace("_", " "))  # replace underscores in the enum with a space
	
