extends Saveable

func _ready():
	return
	
func processLoadData(data:Dictionary):	
	parent.parent.time = data.time
	parent.parent.absolute = data.absolute
	parent.parent.type = data.type
	parent.parent.curve = data.time
	
	
func getDataToSave() -> Dictionary:
	var r: Dictionary = {}
	r["time"] = parent.parent.time
	r["absolute"] = parent.parent.absolute	
	r["type"] = parent.parent.type	
	r["curve"] = curveToJson(parent.parent.curve)
	return r

func curveToJson(c:Curve) -> Dictionary:
	var result:Dictionary = {}
	result.bake_resolution = c.bake_resolution
	result.max_value = c.max_value
	result.min_value = c.min_value
	result.point_count = c.get_point_count()
	for i in c.get_point_count():	
		var p = {}
		p.lm = c.get_point_left_mode (i) 
		p.lt = c.get_point_left_tangent (i) 
		p.pp = c.get_point_position (i) 
		p.rm = c.get_point_right_mode (i)
		p.rt = c.get_point_right_tangent (i)
		result[str(i)] = p
	return result

func jsonToCurve(data: Dictionary) -> Curve:		
	var result: Curve = Curve.new()
	result.bake_resolution = data.bake_resolution
	result.max_value = data.max_value
	result.min_value = data.min_value
	for i in data.point_count:	
		var d = data[str(i)]
		result.add_point(d.pp, d.lt, d.rt, d.lm, d.rm)		
	return result
