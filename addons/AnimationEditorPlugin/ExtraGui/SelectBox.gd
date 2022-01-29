tool
extends Control
class_name SelectBox,"select_icon.png"

# This class is instanced automatically by SelectionController as eeded. DO NOT USE MANUALLY

var start
var end
var color =  Color.cornflower #the color of the selectBox outline
var sb

func _input(event):
	if event is InputEventMouseMotion:
		end += event.relative
		update()
	
	#On mouse up do the selection, deselcting-all first if neededl, and then delete this selectbox
	if event is InputEventMouseButton && event.button_index==1 && !event.pressed:		
		if !Input.is_key_pressed(KEY_SHIFT):
			get_tree().call_group("SelectionController", "selectBoxFinished", make_rect())			
		queue_free()
		
		
func _draw():
	if !sb:
		sb = StyleBoxFlat.new()
		sb.border_color =  color
		sb.border_width_left = 2
		sb.border_width_right = 2
		sb.border_width_top = 2
		sb.border_width_bottom = 2
		sb.draw_center = false
	draw_style_box(sb, make_rect())
	
func make_rect():
	var position = Vector2( min(start.x, end.x), min(start.y, end.y))
	var size = Vector2( abs(start.x - end.x) + 1, abs(start.y-end.y) +1)
	return Rect2(position, size).clip(get_parent().parent.get_global_rect())
