class_name MoveableState
extends State


var moveable

func _ready() -> void:
	yield(owner,"ready")
	moveable = owner
	assert(moveable.has_method("move"))
