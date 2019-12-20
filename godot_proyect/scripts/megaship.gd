extends KinematicBody2D

# Resources.
const LEMON = preload("res://scenes/lemon.tscn")
const MASK = preload("res://assets/sprites/megaship/megaship_mask.png")
# Bars.
const PROGRESS_BAR = preload("res://scenes/progress_bar.tscn")
# Health Bar.
const HP_CELL = preload("res://assets/sprites/gui/hp_cell_yellowwhite.png")
const HP_BAR_POS = Vector2(16, 24)
var hp_bar
# Ammo Bar.
var ammo_cell = preload("res://assets/sprites/gui/hp_cell_yellowwhite.png")
const AMMO_BAR_POS = Vector2(23, 24)
var ammo_bar

const POWERS = global.powers

# Moving speed.
const MOVE_SPEED_ACCEL = 30 # In pixels/second^2.
const MOVE_SPEED_DEACCEL = 20 # In pixels/second^2.
const MOVE_SPEED_MAX = 260 # In pixels/second.
# Cannons positions.
const CANNON_CENTRE_POS = Vector2(15, -.5)
const CANNON_LEFT_POS = Vector2(7, 4)
const CANNON_RIGHT_POS = Vector2(7, -5)

# Auto fire cooldown. Maybe do this a variable so
# you can get upgrades to improve it.
const AUTO_FIRE_INTERVAL = .05 # In seconds/bullet.

const JOYSTICK_DEADZONE = .1

var gamepad = false
var mouse_pos
var mouse_last_pos

# Upgrades and atributes.
# Speed.
const SPEED_MULTIPLIER_MAX = 1.8 # Max speed multiplier.
var speed_multiplier = 1 # This applies to max speed and accelerations.
const SPEED_MULTIPLIER_MIN = .6 # Min speed multiplier.
# HP.
const HP_MAX_MAX = 38 # Max max HP.
var hp_max = 28 # Max HP.
const HP_MAX_MIN = 18 # Min max HP.
# Ammo.
const AMMO_MAX_MAX = 38 # Max max ammo.
var ammo_max = 28 # Max ammo.
const AMMO_MAX_MIN = 18 # Min max ammo.
# Cannons.
const N_CANNONS_MAX = 3 # Max number of active cannons.
var n_cannons = 1 # Number of active cannons.
const N_CANNONS_MIN = 1 # Min number of active cannons.
# Bullets.
const BULLET_MAX_MAX = 10 # Max max bullets per cannon on screen.
var bullet_max = 3 # Max bullets per cannon on screen.
const BULLET_MAX_MIN = 1 # Min max bullets per cannon on screen.

# Unlocked powers.
var unlocked_powers = {
	POWERS.MEGA : true,
	POWERS.BUBBLE : true,
	POWERS.AIR : true,
	POWERS.QUICK : true,
	POWERS.HEAT : true,
	POWERS.WOOD : true,
	POWERS.METAL : true,
	POWERS.FLASH : true,
	POWERS.CRASH : true,
}

export(SpriteFrames) var palettes = null

var hp = hp_max # Current HP.

var ammo = {
	POWERS.MEGA : ammo_max,
	POWERS.BUBBLE : ammo_max,
	POWERS.AIR : ammo_max,
	POWERS.QUICK : ammo_max,
	POWERS.HEAT : ammo_max,
	POWERS.WOOD : ammo_max,
	POWERS.METAL : ammo_max,
	POWERS.FLASH : ammo_max,
	POWERS.CRASH : ammo_max,
}
var active_power = POWERS.MEGA # Current active power.

var auto_fire = 0 # Seconds since last fire.

# Motion variables.
var speed = 0 # Speed at this frame.
var motion_dir = Vector2()

func _ready():
	global.MEGASHIP = self
	# Start HP bar.
	hp_bar = PROGRESS_BAR.instance()
	hp_bar.init(HP_CELL, HP_BAR_POS, hp_max)
	$"../GUILayer".add_child(hp_bar)
	# Start Ammo bar.
	ammo_bar = PROGRESS_BAR.instance()
	ammo_bar.init(ammo_cell, AMMO_BAR_POS, ammo_max)
	ammo_bar.visible = false
	$"../GUILayer".add_child(ammo_bar)
	
	$ShipSprite.material.set_shader_param("mask", MASK)
	$ShipSprite.material.set_shader_param("palette", palettes.get_frame("default", 0))

func _physics_process(delta):
	# Movement.
	var input = get_directional_input()
	var motion = get_motion(input)
	set_fire_sprite()
	move_and_slide(motion)

func _process(delta):
	
	# Get new values of this frame.
	mouse_pos = get_viewport().get_mouse_position()
	
	# Calculate rotation.
	rotation = get_rotation()
	
	# Check if we are firing.
	auto_fire += delta
	if Input.is_action_pressed("shoot") and auto_fire >= AUTO_FIRE_INTERVAL:
		fire(n_cannons)
		auto_fire = 0
	
	# Check mouse mode.
	if gamepad:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	########## TEST
	if Input.is_action_just_pressed("ui_down"):
		previous_power()
	if Input.is_action_just_pressed("ui_up"):
		next_power()
	
	# Update values for next frame.
	mouse_last_pos = mouse_pos

#########################
## Auxiliar functions. ##
#########################

func set_hp_relative(relative_hp):
	hp += relative_hp
	update_bar(hp_bar, hp, hp_max)
	
func set_ammo_relative(relative_ammo):
	ammo[active_power] += relative_ammo
	update_bar(ammo_bar, ammo[active_power], ammo_max)
	
func update_bar(bar, new_value, new_max_value):
	bar.update_values(new_value, new_max_value)
	
func update_bars():
	update_bar(hp_bar, hp, hp_max)
	update_bar(ammo_bar, ammo[active_power], ammo_max)

func set_fire_sprite():
	if speed == 0:
		pass
		$FireSprite.visible = false
	else:
		$FireSprite.visible = true
		if speed == MOVE_SPEED_MAX * speed_multiplier:
			$FireSprite.play("max")
		else:
			$FireSprite.play("accelerate")
			$FireSprite.frame = float(speed) / (MOVE_SPEED_MAX * speed_multiplier) * $FireSprite.frames.get_frame_count("accelerate")
			

func get_directional_input():
	
	var input = Vector2()
	var empty = Vector2()
	
	# Keyboard input.
	if Input.is_action_pressed("keyboard_move_up"):
		input += Vector2(0, -1)
	if Input.is_action_pressed("keyboard_move_down"):
		input += Vector2(0, 1)
	if Input.is_action_pressed("keyboard_move_left"):
		input += Vector2(-1, 0)
	if Input.is_action_pressed("keyboard_move_right"):
		input += Vector2(1, 0)
		
	if input != Vector2():
		gamepad = false
		
	var prev_input = input
	# Gamepad input.
	if Input.is_action_pressed("gamepad_move_up"):
		input += Vector2(0, -1)
	if Input.is_action_pressed("gamepad_move_down"):
		input += Vector2(0, 1)
	if Input.is_action_pressed("gamepad_move_left"):
		input += Vector2(-1, 0)
	if Input.is_action_pressed("gamepad_move_right"):
		input += Vector2(1, 0)
		
	if input != prev_input:
		gamepad = true
		
	if input == empty:
		# Joystick input.
		input = get_joystick_axis(0, JOY_AXIS_0)
	
	return input

func get_rotation():
	var rot
	var input = get_joystick_axis(0, JOY_AXIS_3)
	
	if input != Vector2():
		gamepad = true
		rot = input.angle()
	else:
		rot = rotation
		if mouse_pos != mouse_last_pos:
			gamepad = false
	
	if !gamepad:
		if position.distance_to(mouse_pos) > 3:
			rot = mouse_pos.angle_to_point(get_global_transform_with_canvas().origin)
		else:
			rot = rotation
	
	return rot

func get_joystick_axis(device, joystick):
	var input = Vector2(Input.get_joy_axis(device, joystick), Input.get_joy_axis(device, joystick + 1))
	if input.length() < JOYSTICK_DEADZONE:
		input = Vector2()
	else:
		gamepad = true
	return input

func get_motion(input):
	if input != Vector2():
		# Accelerate.
		speed = clamp(speed + MOVE_SPEED_ACCEL, 0, MOVE_SPEED_MAX)
		motion_dir = input
	else:
		# Deaccelerate.
		speed = clamp(speed - MOVE_SPEED_DEACCEL, 0, MOVE_SPEED_MAX)
	var motion = motion_dir.normalized() * speed * speed_multiplier
	return motion

func fire(ammount):
	var shooted = false
	if ammount % 2 == 1:
		shooted = shoot_projectile(LEMON, "BULLETS_CENTRE", CANNON_CENTRE_POS) or shooted
	if ammount >= 2:
		shooted = shoot_projectile(LEMON, "BULLETS_LEFT", CANNON_LEFT_POS) or shooted
		shooted = shoot_projectile(LEMON, "BULLETS_RIGHT", CANNON_RIGHT_POS) or shooted
		
	if shooted:
		# Play sound only once.
		library.play_audio_random_pitch($SndShoot, Vector2(.98, 1.02))

func shoot_projectile(projectile, group, pos):
	var shooted = get_tree().get_nodes_in_group(group).size() < bullet_max
	# Check if there are too many projectiles.
	if shooted:
		# Fire projectile.
		var inst = projectile.instance()
		inst.init(global_position + pos.rotated(rotation), rotation, group)
		get_parent().add_child(inst)
		
	return shooted
	
func upgrade(type, ammount):
	var value = get(type)
	var value_max = get(type.to_upper() + "_MAX")
	var value_min = get(type.to_upper() + "_MIN")
	if value ==  value_max:
		# TODO: Add some points or something. Play points sound.
		pass
	else:
		# TODO: Play upgrade sound.
		set(type, min(value_max, max(value + ammount, value_min)))
		if type == "hp_max":
			set_hp_relative(ammount)
			ammo_max = min(value_max, max(value + ammount, value_min))
			set_ammo_relative(value)
			
func set_power(power) -> bool:
	if unlocked_powers[power]:
		# TODO: Play sound, set ammo bar palette, change bullets, etc.
		active_power = power
		# Set color palette.
		$ShipSprite.material.set_shader_param("palette", palettes.get_frame("default", power))
		# Show ammo.
		ammo_bar.set_palette(power)
		ammo_bar.visible = power != 0
		# Set ammo value under max.
		ammo[active_power] = min(ammo[active_power], ammo_max)
		return true
	return false
		

func next_power():
	# WARNING: This only works as wexpected if at least one power
	# is unlocked. Mega is unlocked by default and at all time.
	var power = max((active_power + 1) % POWERS.SIZE, 0)
	while !set_power(power):
		pass

func previous_power():
	# WARNING: This only works as wexpected if at least one power
	# is unlocked. Mega is unlocked by default and at all time.
	var power = (active_power - 1) % POWERS.SIZE
	if power < 0: 
		power = POWERS.SIZE - 1
	while !set_power(power):
		pass