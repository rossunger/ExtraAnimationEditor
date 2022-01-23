extends Control
class_name SplashAndFade
export var duration = 2
var tween = Tween.new()
func _ready():
	tween.interpolate_property(self, "modulate", Color(1,1,1,2), Color(1,1,1,0), duration, Tween.TRANS_QUAD)
	add_child(tween)
	tween.start()
	rect_position = get_viewport().get_visible_rect().size / 2 + Vector2(margin_left, margin_top)
	tween.connect("tween_all_completed", self, "endSplash")

func endSplash():
	get_parent().remove_child(self)
	queue_free()
