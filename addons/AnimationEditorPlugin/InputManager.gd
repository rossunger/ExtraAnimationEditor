tool
extends Node

#Clear input map
func _exit_tree():
	if !InputMap.has_action("Undo"):
		InputMap.erase_action("Undo")
	if !InputMap.has_action("Redo"):
		InputMap.erase_action("Redo")
	if !InputMap.has_action("Save"):
		InputMap.erase_action("Save")	
	if !InputMap.has_action("SaveAs"):
		InputMap.erase_action("SaveAs")
	if !InputMap.has_action("Load"):
		InputMap.erase_action("Load")
	if !InputMap.has_action("LoadFrom"):
		InputMap.erase_action("LoadFrom")
	if !InputMap.has_action("Delete"):
		InputMap.erase_action("Delete")	
	if !InputMap.has_action("Copy"):
		InputMap.erase_action("Copy")	
	if !InputMap.has_action("Cut"):
		InputMap.erase_action("Cut")	
	if !InputMap.has_action("Paste"):
		InputMap.erase_action("Paste")	
	if !InputMap.has_action("Click"):		
		InputMap.erase_action("Click")	
	if !InputMap.has_action("RightClick"):		
		InputMap.erase_action("RightClick")	
	if !InputMap.has_action("NudgeLeft"):
		InputMap.erase_action("NudgeLeft")	
	if !InputMap.has_action("NudgeRight"):
		InputMap.erase_action("NudgeRight")	
	if !InputMap.has_action("FrameAll"):
		InputMap.erase_action("FrameAll")
#Build input map	
func _enter_tree():
	if !InputMap.has_action("Undo"):
		InputMap.add_action("Undo")
		var event = InputEventKey.new()
		event.control = true		
		event.scancode = OS.find_scancode_from_string("z")
		InputMap.action_add_event("Undo", event )
		
	if !InputMap.has_action("Redo"):
		InputMap.add_action("Redo")
		var event = InputEventKey.new()
		event.control = true
		event.shift = true
		event.scancode = OS.find_scancode_from_string("z")
		InputMap.action_add_event("Redo", event )
		
	if !InputMap.has_action("Save"):
		InputMap.add_action("Save")
		var event = InputEventKey.new()
		event.control = true		
		event.scancode = OS.find_scancode_from_string("s")
		InputMap.action_add_event("Save", event )
		
	
	if !InputMap.has_action("SaveAs"):
		InputMap.add_action("SaveAs")
		var event = InputEventKey.new()
		event.control = true
		event.shift = true
		event.scancode = OS.find_scancode_from_string("s")
		InputMap.action_add_event("SaveAs", event )
		
	
	if !InputMap.has_action("Load"):
		InputMap.add_action("Load")
		var event = InputEventKey.new()
		event.control = true		
		event.scancode = OS.find_scancode_from_string("o")
		InputMap.action_add_event("Load", event )
		
	
	if !InputMap.has_action("LoadFrom"):
		InputMap.add_action("LoadFrom")
		var event = InputEventKey.new()
		event.control = true
		event.shift = true
		event.scancode = OS.find_scancode_from_string("o")
		InputMap.action_add_event("LoadFrom", event )
	
	
	if !InputMap.has_action("Delete"):
		InputMap.add_action("Delete")
		var event = InputEventKey.new()				
		event.scancode = OS.find_scancode_from_string("delete")
		InputMap.action_add_event("Delete", event )	
		
	if !InputMap.has_action("Copy"):		
		InputMap.add_action("Copy")
		var event = InputEventKey.new()
		#event.control = true		
		event.scancode = OS.find_scancode_from_string("c")
		InputMap.action_add_event("Copy", event )	

	if !InputMap.has_action("Cut"):		
		InputMap.add_action("Cut")
		var event = InputEventKey.new()
		if OS.get_name() == "OSX":	
			event.command = true		
		else:
			event.control = true		
		event.scancode = OS.find_scancode_from_string("x")
		InputMap.action_add_event("Cut", event )	
		
	if !InputMap.has_action("Paste"):		
		InputMap.add_action("Paste")
		var event = InputEventKey.new()
		if OS.get_name() == "OSX":	
			event.command = true		
		else:
			event.control = true		
		event.scancode = OS.find_scancode_from_string("v")
		InputMap.action_add_event("Paste", event )		
		
	if !InputMap.has_action("Click"):		
		InputMap.add_action("Click")
		var event = InputEventMouseButton.new()				
		event.button_index = BUTTON_LEFT
		InputMap.action_add_event("Paste", event )		
	
	if !InputMap.has_action("RightClick"):		
		InputMap.add_action("RightClick")
		var event = InputEventMouseButton.new()				
		event.button_index = BUTTON_RIGHT
		InputMap.action_add_event("RightClick", event)		

	if !InputMap.has_action("NudgeLeft"):		
		InputMap.add_action("NudgeLeft")
		var event = InputEventKey.new()
		if OS.get_name() == "OSX":	
			event.command = true		
		else:
			event.control = true	
		event.scancode = OS.find_scancode_from_string("left")			
		InputMap.action_add_event("NudgeLeft", event)		
		
	if !InputMap.has_action("NudgeRight"):		
		InputMap.add_action("NudgeRight")
		var event = InputEventKey.new()
		if OS.get_name() == "OSX":	
			event.command = true		
		else:
			event.control = true	
		event.scancode = OS.find_scancode_from_string("right")			
		InputMap.action_add_event("NudgeRight", event)	
	
	if !InputMap.has_action("FrameAll"):		
		InputMap.add_action("FrameAll")
		var event = InputEventKey.new()		
		event.scancode = OS.find_scancode_from_string("f")			
		InputMap.action_add_event("FrameAll", event)			


func _input(event): # handleInput(event, timelineEditor):
	var timelineEditor = TimelineEditor
	if not timelineEditor.has_focus():
		return	

	if timelineEditor.draggingKeys:
		if event is InputEventMouseMotion:					
		#	get_viewport().warp_mouse(timelineEditor.clickedKey.rect_global_position)
			for key in get_tree().get_nodes_in_group("selected"):				
				if key.time == 0:									
					var newkey = key.get_parent().addKeyframe(timelineEditor.snap, key.value, key.relative, key.curve)							
					key.call_deferred("deselect")
					newkey.doSelect()							
					newkey.setXFromTime()		
					newkey.trackOffset = key.trackOffset							
				else:							
					key.accumulatedDelta += event.relative.x
					if abs(key.accumulatedDelta/timelineEditor.zoom.x) > timelineEditor.snap:
						key.time = max(0.1, key.time + key.accumulatedDelta/timelineEditor.zoom.x)
						key.accumulatedDelta = 0																
					
					if is_instance_valid( timelineEditor.focusedTrack): # and timelineEditor.focusedTrack != key.get_parent():						
						var newParentId = timelineEditor.focusedTrack.get_index() - key.trackOffset
						newParentId = max(0, min(newParentId, timelineEditor.focusedTrack.get_parent().get_child_count()-1))
						var newParent = timelineEditor.focusedTrack.get_parent().get_child(newParentId)
						key.reparent(newParent)
						timelineEditor.keyframeValue.setValue(key)
						
		if event is InputEventMouseButton and event.button_index == 1 and !event.is_pressed():					
			for key in get_tree().get_nodes_in_group("selected"):
				#check if this track has a keyframe at the same time, if so, move over.
				if is_instance_valid(key.get_parent().getKeyframeAtTime(key.time, key)):
					key.rect_position.x += 0.1						
	else:
		if event is InputEventMouseMotion and timelineEditor.scrolling:						
			TimelineEditor.scroll.x = max(0, TimelineEditor.scroll.x - event.relative.x * 50 /  TimelineEditor.zoom.x)
			TimelineEditor.emit_signal("zoomChanged")							
	
	if event is InputEventMouseButton and timelineEditor.get_global_rect().has_point(event.global_position):
		if event.button_index == 1 and !event.is_pressed():					
			timelineEditor.clickedKey = null		
			timelineEditor.draggingKeys = false	
			get_tree().call_group("Tracks", "validateKeyframeOrder")
		if event.button_index == BUTTON_WHEEL_UP:
			timelineEditor._on_ZoomInButton_pressed()
			#TODO: fix scroll to mouse position
			#timelineEditor.scroll.x = timelineEditor.scroll.x + (event.position.x - timelineEditor.rect_global_position.x) #* 100 / timelineEditor.zoom.x
		if event.button_index == BUTTON_WHEEL_DOWN:
			#TODO: fix scroll to mouse position
			timelineEditor._on_ZoomOutButton_pressed()
			#timelineEditor.scroll.x = timelineEditor.scroll.x + (event.position.x - timelineEditor.rect_global_position.x) #* 100 / timelineEditor.zoom.x

	
	#debounce keypresses
	var t = OS.get_system_time_msecs()
	if abs(timelineEditor.lastKeyCommandTime - t) < 500:
		return	
		
	if not event is InputEventKey:
		return
	elif Input.is_key_pressed(KEY_SPACE):	
		timelineEditor.animation.togglePlay()
		timelineEditor.lastKeyCommandTime = OS.get_system_time_msecs()		
	elif timelineEditor.get_global_rect().has_point(timelineEditor.get_global_mouse_position()):	
		if Input.is_action_pressed("Delete"):					
			timelineEditor.accept_event()
			for key in get_tree().get_nodes_in_group("selected"):
				if key.time != 0:
					key.queue_free()
				else:
					key.deselect()
			timelineEditor.lastKeyCommandTime = OS.get_system_time_msecs()
			
		elif Input.is_action_just_pressed("Copy"):				
			timelineEditor.accept_event()
			print("COPYING")
			if timelineEditor.clipboard.size() > 0:
				timelineEditor.clipboard.clear()
						
			var keys = get_tree().get_nodes_in_group("selected")
			for key in keys:
				timelineEditor.clipboard.push_back({
					track = key.get_parent().get_index(),
					time = key.time,
					value = key.value,
					relative = key.relative,
					curve = key.curve
				})					
			timelineEditor.lastKeyCommandTime = OS.get_system_time_msecs()
			
		elif Input.is_action_just_pressed("Cut"):		
			timelineEditor.accept_event()		
			timelineEditor.clipboard.clear()
						
			var keys = get_tree().get_nodes_in_group("selected")
			for key in keys:				
				timelineEditor.clipboard.push_back({
					track = key.get_parent().get_index(),
					time = key.time,
					value = key.value,
					relative = key.relative,
					curve = key.curve
				})
				key.queue_free()
			timelineEditor.lastKeyCommandTime = OS.get_system_time_msecs()
			
		elif Input.is_action_just_pressed("Paste"):		
			timelineEditor.accept_event()		
			var earliestKeyTime
			var earliestTrack
			for k in timelineEditor.clipboard:
				if not earliestKeyTime or k.time < earliestKeyTime:
					earliestKeyTime = k.time	
				if not earliestTrack or k.track < earliestTrack:
					earliestTrack = k.track	
			
			var delta = timelineEditor.animation.position - earliestKeyTime
			var trackOffset = timelineEditor.focusedTrack.get_index() - earliestTrack
			for k in timelineEditor.clipboard:
				var parent
				if k.track == earliestTrack:
					parent = timelineEditor.focusedTrack
				else:
					parent = timelineEditor.focusedTrack.get_parent().get_child(timelineEditor.focusedTrack.get_index() + earliestTrack)
				parent.addKeyframe(k.time+delta, k.value, k.relative, k.curve)
					
				
			timelineEditor.lastKeyCommandTime = OS.get_system_time_msecs()	
			get_tree().call_group("Tracks", "validateKeyframeOrder")		
		#ToDo: Add nudge left/right keyboard actions...
		elif Input.is_action_just_pressed("NudgeLeft"):
			for key in get_tree().get_nodes_in_group("selected"):
				key.time -= 10/timelineEditor.zoom.x	
		
		elif Input.is_action_just_pressed("NudgeRight"):
			for key in get_tree().get_nodes_in_group("selected"):
				key.time += 10/timelineEditor.zoom.x	
			
		elif Input.is_action_just_pressed("FrameAll"):
			timelineEditor.scroll.x = 0
			timelineEditor.setZoom(100 / timelineEditor.animation.duration * 15) #20 = 100  40 = 50	
			
		elif Input.is_action_just_pressed("Undo"):
			timelineEditor.doUndo()
			timelineEditor.accept_event()
			
		elif Input.is_action_just_pressed("Redo"):
			timelineEditor.doUndo(false)			
			timelineEditor.accept_event()
