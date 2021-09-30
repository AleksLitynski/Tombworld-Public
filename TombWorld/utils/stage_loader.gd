
var SHOULD_LOAD_RESIZE = Mutex.new()
var should_load = {}

func _load_stage(stage_name):
	var res = load("res://stages/%s.tscn" % stage_name)
	if should_load.has(stage_name):
		var instance = res.instance()
		if should_load.has(stage_name):
			# at this point, we're locked in. Even if the user tries to cancel the load, its too late
			var cb = should_load[stage_name]
			instance.global_transform.origin.y = -1000000
			instance.visible = false
			G.add_stage(stage_name, instance, cb)
	cancel_load(stage_name)

func request_load(stage_name, on_loaded):
	var already_loading = should_load.has(stage_name)

	SHOULD_LOAD_RESIZE.lock()
	should_load[stage_name] = on_loaded
	SHOULD_LOAD_RESIZE.unlock()

	# load in the foreground thread. Avoids godot threading bugs
	_load_stage(stage_name)
#	if not already_loading:
#		Thread.new().start(self, "_load_stage", stage_name)

func cancel_load(stage_name):
	SHOULD_LOAD_RESIZE.lock()
	should_load.erase(stage_name)
	SHOULD_LOAD_RESIZE.unlock()

