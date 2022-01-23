extends LineEdit
class_name SearchBox

signal search

var allItems

func _ready():
	connect("text_changed", self, "search")
	connect("focus_entered", self, "clear")

func search(t):
	var searchResult =[]
	for i in allItems:
		if i is String:
			if i.find(text) != -1:
				searchResult.push_back(i)
		else:
			if i.name.find(text) != -1:
				searchResult.push_back(i)
	emit_signal("search", searchResult)		

func clear():
	text = ""
