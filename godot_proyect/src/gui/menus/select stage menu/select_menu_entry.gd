extends Control

const LEVEL_SCENE = "res://src/rooms/level/level.tscn"

export var column: int = 0
export var row: int = 0

export var texture: Texture = null setget set_texture
export var entry_data: Resource

var selected: bool = false setget set_selected

onready var frame = $FrameContainer/MenuEntryFrame


func _ready() -> void:
	set_texture(texture)


func set_texture(value : Texture) -> void:
	texture = value
	frame.set_texture(value)


func set_selected(value : bool) -> void:
	selected = value
	frame.set_selected(value)
