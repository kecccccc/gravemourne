extends Node2D

@onready var fade: ColorRect = $CanvasLayer/Fade
@onready var text_bg: ColorRect = $CanvasLayer/TextBg
@onready var end_text: Label = $CanvasLayer/EndText

const END_TEXT := "The last of them falls.\n\nGravemourne is silent now — not the silence of the grave, but of a town that may yet wake.\n\nThe hunter walks out through the gate as light breaks over the stones."

var text_fully_visible := false
var skipped := false

func _ready() -> void:
	var vp := get_viewport_rect().size

	var almendra = load("res://assets/fonts/Almendra-Regular.ttf")
	end_text.add_theme_font_override("font", almendra)
	end_text.add_theme_font_size_override("font_size", 20)
	end_text.add_theme_color_override("font_color", Color("#c8a96e"))
	end_text.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	end_text.add_theme_constant_override("outline_size", 6)
	end_text.autowrap_mode = TextServer.AUTOWRAP_WORD
	end_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	end_text.size = Vector2(380, 200)
	end_text.position = (vp - end_text.size) / 2.0
	end_text.text = END_TEXT

	text_bg.color = Color(0, 0, 0, 0.6)
	text_bg.size = end_text.size + Vector2(40, 40)
	text_bg.position = (vp - text_bg.size) / 2.0

	fade.color = Color(0, 0, 0, 1)
	fade.modulate.a = 1.0
	end_text.modulate.a = 0.0
	text_bg.modulate.a = 0.0

	var fade_tween = create_tween()
	fade_tween.tween_property(fade, "modulate:a", 0.0, 2.0)
	await fade_tween.finished

	var text_tween = create_tween()
	text_tween.set_parallel(true)
	text_tween.tween_property(end_text, "modulate:a", 1.0, 2.0)
	text_tween.tween_property(text_bg, "modulate:a", 1.0, 2.0)
	await text_tween.finished

	text_fully_visible = true

	await get_tree().create_timer(6.0).timeout
	if not skipped:
		_finish()

func _unhandled_input(event: InputEvent) -> void:
	if text_fully_visible and not skipped and (event is InputEventKey or event is InputEventMouseButton) and event.pressed:
		_finish()

func _finish() -> void:
	if skipped:
		return
	skipped = true
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 1.0)
	await tween.finished
	get_tree().change_scene_to_file("res://main_menu.tscn")
