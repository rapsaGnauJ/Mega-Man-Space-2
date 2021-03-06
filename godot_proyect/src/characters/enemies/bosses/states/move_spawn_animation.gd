extends EnemyState

var move_speed: float = 260

var path: Array
var init_pos: Vector2
var mid_pos: Vector2
var end_pos: Vector2

var path_index := 0

var timer: Timer = Timer.new()


func _ready() -> void:
	yield(owner, "ready")
	timer.wait_time = 1.15
	add_child(timer)

func _on_timer_timeout() -> void:
	next_point()


func enter(msg: Dictionary = {}) -> void:
	_parent._parent.max_speed = move_speed
	# Calculate init position and path to follow.
	
	var megaship_dir := Vector2(sin(megaship.global_rotation), -cos(megaship.global_rotation)).normalized()
	
	init_pos = megaship.global_position + megaship_dir.rotated(PI) * 320
	mid_pos = megaship.global_position + megaship_dir.rotated(PI/2) * 220
	end_pos = megaship.global_position + megaship_dir * 20
	
	path = [init_pos, mid_pos, end_pos]
	path_index = 0
	character.global_position = init_pos
	
	timer.connect("timeout", self, "_on_timer_timeout")
	
	next_point()


func physics_process(delta: float) -> void:
	_parent.physics_process(delta)
	character.apply_propulsion_effects(_parent.dir * move_speed * acceleration_ratio)


func exit() -> void:
	_parent._parent.max_speed = max_speed
	_parent._parent.velocity = Vector2.ZERO
	look_at_megaship()
	timer.stop()
	timer.disconnect("timeout", self, "_on_timer_timeout")
	character.apply_propulsion_effects(Vector2.ZERO)


func next_point() -> void:
	path_index += 1
	if path_index < len(path):
		_parent.to_follow = path[path_index]
		timer.start()
	else:
		_state_machine.transition_to("EndSpawnAnimation")
	
