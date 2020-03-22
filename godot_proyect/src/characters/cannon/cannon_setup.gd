class_name CannonSetup
extends Node2D

onready var snd_shoot = $SndShoot
onready var snd_charge = $SndCharge


func fire(power: int = 0) -> bool:
	# Called when there is an attempt to shoot. This method checks that a
	# shoot is viable and if so creates the projectiles via shoot_projectile().
	var shooted = false
	# TODO: Check ammo.
	for child in get_children():
		if child is Cannon:
			shooted = child.fire(power) or shooted # If any cannon shooted, return true and act as so.
	if shooted:
		# TODO: Consume ammo
		global.play_audio_random_pitch(snd_shoot, Vector2(.98, 1.02)) # Play sound.
	return shooted


# Setters act on all childs.
func set_cooldown(value: float) -> void:
	for child in get_children():
		if child is Cannon:
			child.set_cooldown(value)


func set_projectile(value: PackedScene) -> void:
	for child in get_children():
		if child is Cannon:
			child.set_projectile(value)


func set_max_projectiles(value: int) -> void:
	for child in get_children():
		if child is Cannon:
			child.set_max_projectiles(value)
