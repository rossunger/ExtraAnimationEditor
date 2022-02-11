tool
extends Reference
class_name TYPES

const Bool = 0
const Float = 1
const Res = 2
const Str = 3
const Vec2 = 4
const Vec3 = 5
const Vec4 = 6
const Var = 7

static func getTypes():
	return ["Bool", "Float", "Res", "Str", "Vec2", "Vec3", "Vec4", "Var"]

static func GodotTypesToRossTypes(type):
	if type == TYPE_COLOR:
		return Vec4
	elif type == TYPE_VECTOR3:
		return Vec3
	elif type == TYPE_VECTOR2:
		return Vec2
	elif type == TYPE_STRING:
		return Str
	elif type == TYPE_INT or type == TYPE_REAL :
		return Float
	elif type == TYPE_BOOL:
		return Bool
	else:
		return Res
	
