extends Spatial

var button_1
var button_2
var target_pos
var elevator
var target_button
export(bool) var y_only = true
export(float) var speed = 40
export(float) var slow_speed = 4
export(float) var accel = 4
export(float) var decel = 15
export(float) var decel_dist = 20
var current_speed = 0
var target_brightness = 0

func _ready():
	# find our two children which are call buttons
	for child in get_children():
		if child.is_in_group("elevator"):
			elevator = child
		if child.name == "__elevator_button_1":
			button_1 = child.get_node("button")
		if child.name == "__elevator_button_2":
			button_2 = child.get_node("button")
		if button_1 and button_2 and elevator:
			break
	
	elevator.get_node("on_elevator").connect("body_entered", self, "_body_entered")
	elevator.get_node("on_elevator").connect("body_exited", self, "_body_exited")

	elevator.get_node("walk_on_trigger").connect("body_entered", self, "_body_entered_trigger")

	elevator.get_node("bonk_zone").connect("body_entered", self, "_bonked")
	elevator.get_node("bonk_zone").connect("body_exited", self, "_unbonked")
	
	button_1.get_parent().get_node("SpotLight").light_energy = 0
	button_2.get_parent().get_node("SpotLight").light_energy = 0
	
	elevator.visible = true
	
	if not G.game_state.elevators.has(str(get_path())):
		G.game_state.elevators[str(get_path())] = { target_button = "button_1" }
	set_target_button(G.game_state.elevators[str(get_path())].target_button)
	elevator.global_transform.origin = get_target()
	

var player_on_elevator = false
func _body_entered(body):
	if body == G.player():
		player_on_elevator = true

func _body_exited(body):
	if body == G.player():
		player_on_elevator = false

func _body_entered_trigger(body):
	if body == G.player() and not move_triggered_by_standing:
		set_target_button("button_1" if target_button == "button_2" else "button_2")
		move_triggered_by_standing = true

var bonking = false
func _bonked(body):
	if body == G.player():
		bonking = true

func _unbonked(body):
	if body == G.player():
		bonking = false

func _input(ev):
	if G.is_collider_pressed(button_1):
		set_target_button("button_1")
		target_brightness = 2
	elif G.is_collider_pressed(button_2):
		set_target_button("button_2")
		target_brightness = 2

func get_button_target(button):
	var t_pos = null
	for child in button.get_parent().get_children():
		if child.name == "__elevator_target":
			t_pos = child.global_transform.origin
			break
	return t_pos

func get_target():
	var b1 = get_button_target(button_1)
	if target_button == "button_1": return b1
	var b2 = get_button_target(button_2)
	return b2 if not y_only else G.at_height(b1, b2.y)

var in_motion = false
func move_to_target(delta):
	var pos = elevator.global_transform.origin
	var t_pos = get_target()
	if t_pos == pos:
		zero_position(t_pos)
		return

	if pos.distance_to(t_pos) < decel_dist and current_speed > slow_speed:
		current_speed -= delta * decel
	elif current_speed < speed:
		current_speed += delta * accel

	var velo = (t_pos - pos).normalized() * delta * current_speed
	if (t_pos - pos).length() < velo.length():
		zero_position(t_pos)
		return
	
	if not bonking:
		elevator.constant_linear_velocity = velo
		elevator.global_transform.origin += velo
	
	if player_on_elevator:
		G.player().global_transform.origin += velo
	
	in_motion = true

func zero_position(t_pos):
	elevator.global_transform.origin = t_pos
	elevator.constant_linear_velocity = Vector3.ZERO
	in_motion = false
	current_speed = 0
	target_brightness = 0
	

var move_triggered_by_standing = false
func _process(delta):
	move_to_target(delta)

	var c_brightness = button_1.get_parent().get_node("SpotLight").light_energy
	if abs(target_brightness - c_brightness) < 0.1:
		button_1.get_parent().get_node("SpotLight").light_energy = target_brightness
		button_2.get_parent().get_node("SpotLight").light_energy = target_brightness
	elif target_brightness > c_brightness:
		button_1.get_parent().get_node("SpotLight").light_energy += delta * 30
		button_2.get_parent().get_node("SpotLight").light_energy += delta * 30
	else:
		button_1.get_parent().get_node("SpotLight").light_energy -= delta * 30
		button_2.get_parent().get_node("SpotLight").light_energy -= delta * 30

	if not in_motion and not player_on_elevator:
		move_triggered_by_standing = false


func set_target_button(button):
	G.game_state.elevators[str(get_path())].target_button = button
	target_button = button
	if target_button == "button_1":
		button_1.get_parent().get_node("text_3d").visible = false
		button_2.get_parent().get_node("text_3d").visible = true
	elif target_button == "button_2":
		button_1.get_parent().get_node("text_3d").visible = true
		button_2.get_parent().get_node("text_3d").visible = false
