class_name MenuPanel
extends Control

const PALETTES : SpriteFrames = preload("res://resources/gui/menu_palettes.tres")

var tween = Tween.new()
var flickering_timer = Timer.new()
export var _selected_flickering_interval: float = 8.0/60.0
export var opening_time: = .3
export var hide_when_animating: NodePath = "Contents"
export var animate_opening: bool = true
export var animate_closing: bool = true
export var background: NodePath = "Background"
export var palette: int = 0 setget set_palette

export var active:= true setget set_active
export(Array, NodePath) var entries
var entry: Node
export var entry_index: int = 0
var n_entries: int = 0

export var snd_open: NodePath = "SndOpen"
export var snd_close: NodePath = "SndClose"
export var snd_ui_up: NodePath = "SndUIMove"
export var snd_ui_down: NodePath = "SndUIMove"
export var snd_ui_left: NodePath = "SndUIMove"
export var snd_ui_right: NodePath = "SndUIMove"
export var snd_ui_accept: NodePath = "SndUIAccept"
export var snd_ui_cancel: NodePath = "SndUICancel"

signal opened
signal closed
signal animation_ended



func _ready() -> void:
	_init_children()
	
	# Connect global pause.
	global.connect("user_paused", self, "_on_global_user_pause")
	
	# Animate opening.
	if animate_opening:
		opening_animation()
	# Update current entires.
	call_deferred("update_entries")


func _input(event: InputEvent) -> void:
	if active:
		if event.is_action_pressed("ui_down"):
			accept_event()
			_on_action_pressed_ui_down()
		elif event.is_action_pressed("ui_up"):
			accept_event()
			_on_action_pressed_ui_up()
		elif event.is_action_pressed("ui_left"):
			accept_event()
			_on_action_pressed_ui_left()
		elif event.is_action_pressed("ui_right"):
			accept_event()
			_on_action_pressed_ui_right()
		elif event.is_action_pressed("ui_accept"):
			accept_event()
			_on_action_pressed_ui_accept()
		elif event.is_action_pressed("ui_cancel"):
			accept_event()
			_on_action_pressed_ui_accept()

func _on_action_pressed_ui_down():
	play_sound(snd_ui_down)
	next_entry()
	
func _on_action_pressed_ui_up():
	play_sound(snd_ui_up)
	previous_entry()

func _on_action_pressed_ui_left():
	pass

func _on_action_pressed_ui_right():
	pass
	
func _on_action_pressed_ui_accept():
	pass

func _on_action_pressed_ui_cancel():
	pass


func _on_FlickeringTimer_timeout() -> void:
	if entry != null: entry.modulate.a = 0 if entry.modulate.a == 1 else 1


func _on_global_user_pause(value : bool) -> void:
	if !value:
		close_menu()


func _on_child_menu_closed() -> void:
	set_active(true)


func _init_children():
	# Setup tween.
	add_child(tween)
	# Setup flickering timer.
	add_child(flickering_timer)
	flickering_timer.wait_time = _selected_flickering_interval
	flickering_timer.connect("timeout", self, "_on_FlickeringTimer_timeout")
	flickering_timer.start()


func play_sound(snd: NodePath) -> void:
	if has_node(snd):
		var node = get_node(snd)
		if node != null and node.has_method("play"):
			 get_node(snd).play()


func growing_animation(start_size: Vector2, final_size: Vector2, time: float = opening_time, hide:= get_node(hide_when_animating) if has_node(hide_when_animating) else null):
	if hide != null: hide.visible = false
	# Start opening animation.
	tween.interpolate_property(self, "rect_size", start_size, final_size, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "rect_position", rect_position + final_size / 2, rect_position + start_size / 2, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed") # Wait until the animation is over.
	# Animation is over.
	if hide != null: hide.visible = true
	emit_signal("animation_ended")


func opening_animation(time = opening_time):
	var previous_active = active
	set_active(false)
	play_sound(snd_open)
	growing_animation(Vector2.ZERO, rect_size, time)
	yield(self, "animation_ended")
	emit_signal("opened")
	set_active(previous_active)


func closing_animation(time = opening_time):
	set_active(false)
	growing_animation(rect_size, Vector2.ZERO, time)
	yield(self, "animation_ended")
	emit_signal("closed")


func close_menu():
	play_sound(snd_close)
	if animate_closing:
		closing_animation()
		yield(self, "closed")
	queue_free()


func open_child_menu(menu: PackedScene) -> Control:
	var inst = menu.instance()
	inst.palette = palette
	inst.connect("closed", self, "_on_child_menu_closed")
	get_parent().add_child(inst)
	set_active(false)
	return inst

func set_entry(value : int) -> bool:
# warning-ignore:narrowing_conversion
	value = clamp(value, 0, n_entries)
	if value < entries.size():
		if entry != null:
			entry.modulate.a = 1
		entry_index = value
		entry = get_node(entries[entry_index]) if entries[entry_index] is NodePath else entries[entry_index]
		return true
	return false


func set_active(value: bool) -> void:
	if value == active:
		return
	active = value
	if active:
		flickering_timer.start()
	else:
		flickering_timer.stop()
		if entry != null: entry.modulate.a = 1


func next_entry() -> void:
	if n_entries != 0:
		var new_entry = (entry_index + 1) % n_entries
		while entries[new_entry] == null:
			new_entry = (new_entry + 1) % n_entries
		set_entry(new_entry)


func previous_entry() -> void:
	if n_entries != 0:
		var new_entry = (entry_index - 1) % n_entries if entry_index > 0 else n_entries - 1
		while entries[new_entry] == null:
			new_entry = (new_entry - 1) % n_entries if new_entry > 0 else n_entries - 1
		set_entry(new_entry)


func update_entries() -> void:
	n_entries = len(entries)
# warning-ignore:narrowing_conversion
	entry_index = clamp(entry_index, 0, n_entries - 1)
	if entry_index >= 0:
		entry = get_node(entries[entry_index])


func set_palette(value : int) -> void:
	if value < PALETTES.get_frame_count("default"):
		palette = value
		get_node(background).material.set_shader_param("palette", PALETTES.get_frame("default", value))
