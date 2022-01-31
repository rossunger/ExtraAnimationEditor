tool
extends OptionButton

func _ready():	
	for i in TYPES.getTypes():				
		add_item(i)
