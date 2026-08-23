extends Area2D

@export var target_scene: String = "res://levels/level_2.tscn"
@export var requires_key: bool = false
@export var requires_guard_defeat: bool = false
@export var guard_group: String = "executioner"

@onready var prompt: Label = $Prompt

var player_near := false
var transitioning := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_near = true
		prompt.text = _prompt_text(body)
		var tween = create_tween()
		tween.tween_property(prompt, "modulate:a", 1.0, 0.2)

func _process(_delta: float) -> void:
	if player_near and not transitioning and requires_guard_defeat:
		var player = get_tree().current_scene.get_node("Player")
		prompt.text = _prompt_text(player)

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_near = false
		var tween = create_tween()
		tween.tween_property(prompt, "modulate:a", 0.0, 0.2)

func _is_unlocked(player: Node) -> bool:
	if requires_key and not player.has_key:
		return false
	if requires_guard_defeat and not get_tree().get_nodes_in_group(guard_group).is_empty():
		return false
	return true

func _prompt_text(player: Node) -> String:
	if _is_unlocked(player):
		return "Press E"
	if requires_guard_defeat and not get_tree().get_nodes_in_group(guard_group).is_empty():
		return "Locked - defeat the executioner"
	return "Locked - find the key"

func _unhandled_input(event: InputEvent) -> void:
	if player_near and not transitioning and Input.is_action_just_pressed("interact"):
		var player = get_tree().current_scene.get_node("Player")
		if _is_unlocked(player):
			_transition()

func _transition() -> void:
	transitioning = true
	var fade = get_tree().current_scene.get_node("DeathScreen/Fade")
	fade.visible = true
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 1.0)
	await tween.finished
	get_tree().change_scene_to_file(target_scene)
