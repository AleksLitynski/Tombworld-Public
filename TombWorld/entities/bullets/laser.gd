extends KinematicBody

func _ready():
	$sprite.directions = [
		{ name = "headon" },
		{ name = "angle" },
		{ name = "side" },
		{ name = "angle", flip = true },
		{ name = "headon", flip = true },
		{ name = "angle", flip = true },
		{ name = "side", flip=true },
		{ name = "angle" },
	]
	$Particles.emitting = false

var state = "move" # or explode

var source
var speed = 10
func _physics_process(delta):
	match state:
		"move": move(delta)
		"explode": explode(delta)
	
func move(delta):
	var hit = move_and_collide(-global_transform.basis.z * delta * speed)
	if hit:
		if hit.collider == G.player():
			G.player().take_damage(source)
		begin_explode()

func begin_explode():
	state = "explode"
	$CollisionShape.disabled = true
	$Particles.emitting = true

var explode_time = 0
func explode(delta):
	explode_time += delta
	if $sprite.opacity > 0:
		$sprite.opacity -= delta * 3
	else:
		$sprite.opacity = 0
	if explode_time > 0.5:
		$Particles.emitting = false
	if explode_time > 1:
		queue_free()
		
func prep_cache():
	G.main.add_child(self)
	# put it 100 behind the camera
	self.global_transform.origin = G.camera().global_transform.origin - G.camera().global_transform.basis.z * 100
	$CollisionShape.disabled = true
	$sprite.visible = false
	$Particles.amount = 1
	begin_explode()
