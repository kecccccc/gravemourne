extends Node2D

@onready var background = $BackgroundImage
@onready var title = $CanvasLayer/Title
@onready var vbox = $CanvasLayer/VBoxContainer
@onready var play_btn = $CanvasLayer/VBoxContainer/NewGame
@onready var controls_btn = $CanvasLayer/VBoxContainer/Controls
@onready var options_btn = $CanvasLayer/VBoxContainer/Options
@onready var quit_btn = $CanvasLayer/VBoxContainer/Quit
@onready var story_screen = $CanvasLayer/StoryScreen
@onready var story_text = $CanvasLayer/StoryScreen/StoryText
@onready var options_menu = $CanvasLayer/OptionsMenu
@onready var controls_menu = $CanvasLayer/ControlsMenu
@onready var music_slider = $CanvasLayer/OptionsMenu/MusicSlider
@onready var sfx_slider = $CanvasLayer/OptionsMenu/SFXSlider
@onready var fade_overlay = $CanvasLayer/FadeOverlay
var waiting_for_key := false

const STORY_TEXT = "Once a thriving town, Gravemourne fell silent when darkness crept from beneath the earth. The dead rose. The living fled. Only ruins and rot remain.\n\nYou are a hunter, drawn here by whispers of something ancient, something wrong. No map, no allies. Just your blade and the will to see this through.\n\nFind the source. End it.\n\nOr join the graves."
func _unhandled_input(event):
	if waiting_for_key and (event is InputEventKey or event is InputEventMouseButton) and event.pressed:
		waiting_for_key = false
		_start_game()
func _ready():
	var vp := get_viewport_rect().size

	# style back buttons
	var cinzel = load("res://assets/fonts/Cinzel-VariableFont_wght.ttf")
	var back_opts = $CanvasLayer/OptionsMenu/Back
	var back_ctrl = $CanvasLayer/ControlsMenu/Back
	for btn in [back_opts, back_ctrl]:
		btn.text = "Back"
		btn.flat = false
		btn.add_theme_font_override("font", cinzel)
		btn.add_theme_font_size_override("font_size", 18)
		btn.add_theme_color_override("font_color", Color("#c8a96e"))
	back_opts.position = Vector2(vp.x / 2 - 40, vp.y - 100)
	back_ctrl.position = Vector2(vp.x / 2 - 40, vp.y - 100)

	print("Button count: ", vbox.get_child_count())
	# hide overlays
	story_screen.visible = false
	options_menu.visible = false
	controls_menu.visible = false
	fade_overlay.visible = false
	story_screen.modulate.a = 0
	options_menu.modulate.a = 0
	controls_menu.modulate.a = 0
	fade_overlay.modulate.a = 0
	# make overlays solid dark background
	story_screen.color = Color("#0d0a0e")
	options_menu.color = Color("#0d0a0e")
	controls_menu.color = Color("#0d0a0e")
	fade_overlay.color = Color("#000000")

	# set controls text
	$CanvasLayer/ControlsMenu/ControlsList.text = "MOVE        A / D   or   ← →\nJUMP        SPACE\nATTACK    K   or   LEFT CLICK"

	# fonts
	var cinzel_decorative = load("res://assets/fonts/CinzelDecorative-Regular.ttf")

	var almendra = load("res://assets/fonts/Almendra-Regular.ttf")

	
	story_text.add_theme_font_override("font", almendra)
	story_text.add_theme_font_size_override("font_size", 16)
	story_text.add_theme_color_override("font_color", Color("#c8a96e"))
	story_text.autowrap_mode = TextServer.AUTOWRAP_WORD
	story_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	story_text.position = Vector2((vp.x - 520) / 2, 60)
	story_text.size = Vector2(520, 240)
	story_text.text = STORY_TEXT

	# title
	title.text = "Gravemourne"
	title.add_theme_font_override("font", cinzel_decorative)
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color("#c8a96e"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(vp.x, 40)
	title.position = Vector2(0, 40)
	
	# buttons
	for btn in vbox.get_children():
		btn.add_theme_font_override("font", cinzel)
		btn.add_theme_font_size_override("font_size", 20)
		btn.add_theme_color_override("font_color", Color("#c8a96e"))
		btn.add_theme_color_override("font_hover_color", Color("#ffffff"))
		btn.flat = true
		btn.custom_minimum_size = Vector2(120, 20)
	
	vbox.position = Vector2(vp.x / 2 - 60, 110)
	vbox.add_theme_constant_override("separation", 8)

	play_btn.text = "Play"

	# sliders
	music_slider.min_value = 0
	music_slider.max_value = 1
	music_slider.step = 0.01
	music_slider.value = 1.0
	music_slider.position = Vector2(vp.x / 2 - 100, 110)
	music_slider.size = Vector2(200, 20)
	sfx_slider.size = Vector2(200, 20)
	sfx_slider.min_value = 0
	sfx_slider.max_value = 1
	sfx_slider.step = 0.01
	sfx_slider.value = 1.0
	sfx_slider.position = Vector2(vp.x / 2 - 100, 150)
	
	
	# options labels
	var music_label = Label.new()
	music_label.text = "Music Volume"
	music_label.position = Vector2(vp.x / 2 - 100, 80)
	music_label.add_theme_color_override("font_color", Color("#c8a96e"))
	options_menu.add_child(music_label)

	var sfx_label = Label.new()
	sfx_label.text = "SFX Volume"
	sfx_label.position = Vector2(vp.x / 2 - 100, 120)
	sfx_label.add_theme_color_override("font_color", Color("#c8a96e"))
	options_menu.add_child(sfx_label)
	
	
	# connect buttons
	play_btn.pressed.connect(_on_play_pressed)
	controls_btn.pressed.connect(_on_controls)
	options_btn.pressed.connect(_on_options)
	quit_btn.pressed.connect(_on_quit)
	$CanvasLayer/OptionsMenu/Back.pressed.connect(_on_options_back)
	$CanvasLayer/ControlsMenu/Back.pressed.connect(_on_controls_back)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	
	# fade in menu
	# force visible for testing
	title.modulate.a = 1.0
	vbox.modulate.a = 1.0
	vbox.visible = true
	for btn in vbox.get_children():
		btn.visible = true
		btn.modulate.a = 1.0
		
		
func _on_play_pressed():
	var tween = create_tween()
	tween.tween_property(vbox, "modulate:a", 0.0, 0.5)
	tween.tween_property(title, "modulate:a", 0.0, 0.5)
	await tween.finished
	vbox.visible = false

	story_screen.visible = true
	var tween2 = create_tween()
	tween2.tween_property(story_screen, "modulate:a", 1.0, 1.0)
	await tween2.finished

	story_text.text = STORY_TEXT + "\n\n[Press any key to continue]"
	await get_tree().create_timer(0.5).timeout
	waiting_for_key = true


func _start_game():
	GameManager.create_save()
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.5)
	await tween.finished
	get_tree().change_scene_to_file("res://levels/level_1.tscn")

func _on_options():
	options_menu.visible = true
	var tween = create_tween()
	tween.tween_property(options_menu, "modulate:a", 1.0, 0.3)

func _on_options_back():
	var tween = create_tween()
	tween.tween_property(options_menu, "modulate:a", 0.0, 0.3)
	await tween.finished
	options_menu.visible = false

func _on_controls():
	controls_menu.visible = true
	var controls_list = $CanvasLayer/ControlsMenu/ControlsList
	controls_list.add_theme_font_size_override("font_size", 18)
	controls_list.add_theme_color_override("font_color", Color("#c8a96e"))
	var vp := get_viewport_rect().size
	controls_list.position = Vector2(vp.x / 2 - 150, 100)
	var tween = create_tween()
	tween.tween_property(controls_menu, "modulate:a", 1.0, 0.3)

func _on_controls_back():
	var tween = create_tween()
	tween.tween_property(controls_menu, "modulate:a", 0.0, 0.3)
	await tween.finished
	controls_menu.visible = false

func _on_quit():
	get_tree().quit()

func _on_music_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_sfx_changed(value: float):
	pass
