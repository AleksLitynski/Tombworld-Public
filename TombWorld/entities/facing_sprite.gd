extends AnimatedSprite3D
class_name FacingSprite

var directions = []
var show_debug_lines = false
var paused_facing = false

var initial_pixel_size
func _ready():
	initial_pixel_size = pixel_size
	billboard = SpatialMaterial.BILLBOARD_FIXED_Y

func _process(delta):
	if paused_facing: return
	var camera_trans = G.camera().global_transform
	
	# Get the angle from the sprite to the active camera
	var direction_to_camera = (G.swizzle("xz", camera_trans.origin) - G.swizzle("xz", global_transform.origin)).normalized()
	var current_direction = G.swizzle("xz", global_transform.basis.z.normalized())
	var angle_to_camera = current_direction.angle_to(direction_to_camera)
	
	# 1. Get the angle from the sprite to the camera
	# 2. Get the 'quadrant size' (divide 2PI by the number of sprites to know how big each slice of the pie is)
	# 3. Add half a quadrant size to the angle to the camera, basically, rotate the quadrants by half a quadrant so the first slide of the pie straddles 0 degrees
	# 4. Divide that angel by the number of quadrants. That'll give you something like 3.38, which means you're in the third quadrant
	# 5. The last quadrant and the zeroith quadrants are the same, so use fmod to make it wrap around
	# 6. Take the floor so 3.999 becomes 3
	if len(directions) > 0:
		var quad_size = TAU / len(directions)
		var current_quad = floor(fmod((angle_to_camera + (quad_size / 2)) / quad_size, len(directions)))

		# load up the sprite
		var current_anim = directions[current_quad]
		animation = current_anim.name
		if current_anim.has("flip"):
			flip_h = current_anim.flip
		else:
			flip_h = false
		
		if current_anim.has("pixel_size"):
			pixel_size = current_anim.pixel_size
		else:
			pixel_size = initial_pixel_size

		# diagnostic stuff
		if show_debug_lines:
			var s = 0
			var idx = -1
			for q in directions:
				idx += 1
				s += quad_size
				G.debug.show_line_relative(
					q.name + "_" + str(idx), global_transform.origin,
					Vector3(0, 0, 1).rotated(Vector3(0, 1, 0), s).rotated(Vector3(0, 1, 0), quad_size / 2))
		
