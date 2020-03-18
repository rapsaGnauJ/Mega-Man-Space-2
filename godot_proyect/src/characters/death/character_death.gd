# Default death animation for characters.
# A simple explosion particle.
extends Particles2D

func _ready() -> void:
	emitting = true
	pass

func _process(delta: float) -> void:
	if !emitting and !$SndDeath.playing:
		queue_free()
