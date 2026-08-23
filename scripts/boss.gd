extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var hurtbox: Area2D = $Hurtbox
@onready var attack_sound: AudioStreamPlayer = $AttackSound
@onready var spell_sound: AudioStreamPlayer = $SpellSound

@export var speed: float = 70.0
@export var stop_distance: float = 50.0
@export var attack_offset: float = 70.0
@export var max_health: int = 20
@export var melee_cooldown: float = 1.2
@export var cast_cooldown: float = 3.0
@export var portal_scene: PackedScene
@export var portal_height_offset: float = -60.0
@export var portal_cast_delay: float = 0.4

var current_health: int
var player = null
var spawn_position: Vector2
var chasing = false
var can_melee = true
var can_cast = true
var is_attacking = false
var player_in_attack_area = false
var facing_right = true
var is_dead = false

func _ready() -> void:
	add_to_group("enemy")
	current_health = max_health
	spawn_position = global_position
	detection_area.body_entered.connect(_on_detection_entered)
	detection_area.body_exited.connect(_on_detection_exited)
	attack_area.body_entered.connect(_on_attack_entered)
	attack_area.body_exited.connect(_on_attack_exited)
	hurtbox.area_entered.connect(_on_hurtbox_entered)
	animated_sprite_2d.play("idle")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	attack_area.position.x = attack_offset if facing_right else -attack_offset

	if is_attacking:
		return

	if chasing and player:
		if player_in_attack_area and can_melee:
			choose_attack()
			return
		if not player_in_attack_area and can_cast:
			choose_attack()
			return

		var distance = global_position.distance_to(player.global_position)
		if distance > stop_distance:
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * speed
			_face(direction.x)
			_play_movement_animation("walk")
		else:
			velocity.x = 0
			_play_movement_animation("idle")
	else:
		if global_position.distance_to(spawn_position) > 5:
			var direction = (spawn_position - global_position).normalized()
			velocity.x = direction.x * speed
			_face(direction.x)
			_play_movement_animation("walk")
		else:
			velocity.x = 0
			_play_movement_animation("idle")

	move_and_slide()

func _play_movement_animation(anim_name: String) -> void:
	if animated_sprite_2d.animation != anim_name:
		animated_sprite_2d.play(anim_name)

func _face(direction_x: float) -> void:
	# The source art faces left by default, so flip_h is inverted relative
	# to the usual (faces-right) convention used elsewhere in this project.
	if direction_x < 0:
		animated_sprite_2d.flip_h = false
		facing_right = false
	else:
		animated_sprite_2d.flip_h = true
		facing_right = true

func choose_attack() -> void:
	if player_in_attack_area:
		melee_attack()
	else:
		cast_spell()

func melee_attack() -> void:
	is_attacking = true
	can_melee = false
	velocity = Vector2.ZERO
	attack_sound.play()
	animated_sprite_2d.play("attack")
	await animated_sprite_2d.animation_finished
	if player_in_attack_area and is_instance_valid(player) and not is_dead:
		player.take_damage(1)
	is_attacking = false
	await get_tree().create_timer(melee_cooldown).timeout
	can_melee = true

func cast_spell() -> void:
	is_attacking = true
	can_cast = false
	velocity = Vector2.ZERO
	if player:
		_face(player.global_position.x - global_position.x)
	if spell_sound.stream:
		spell_sound.play()
	animated_sprite_2d.play("cast")

	await get_tree().create_timer(portal_cast_delay).timeout
	if portal_scene and is_instance_valid(player) and not is_dead:
		var portal = portal_scene.instantiate()
		get_parent().add_child(portal)
		portal.global_position = player.global_position + Vector2(0, portal_height_offset)

	await animated_sprite_2d.animation_finished
	is_attacking = false
	await get_tree().create_timer(cast_cooldown).timeout
	can_cast = true

func _on_hurtbox_entered(area: Area2D) -> void:
	if area.name == "AttackArea":
		take_damage(1)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	current_health -= amount
	print("Boss HP: ", current_health, "/", max_health)
	_flash_hurt()
	if current_health <= 0:
		die()

func _flash_hurt() -> void:
	var tween = create_tween()
	tween.tween_property(animated_sprite_2d, "modulate", Color(1, 0.3, 0.3), 0.075)
	tween.tween_property(animated_sprite_2d, "modulate", Color(1, 1, 1), 0.075)

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite_2d.play("death")
	await animated_sprite_2d.animation_finished
	if is_instance_valid(player):
		player.is_dead = true
		player.velocity = Vector2.ZERO
	await get_tree().create_timer(2.0).timeout

	var fade_layer := CanvasLayer.new()
	fade_layer.layer = 100
	var fade := ColorRect.new()
	fade.color = Color(0, 0, 0, 1)
	fade.modulate.a = 0.0
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_layer.add_child(fade)
	get_tree().current_scene.add_child(fade_layer)

	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 1.0)
	await tween.finished

	get_tree().change_scene_to_file("res://scenes/ending.tscn")

func _on_detection_entered(body: Node) -> void:
	if body.name == "Player":
		player = body
		chasing = true

func _on_detection_exited(body: Node) -> void:
	if body.name == "Player":
		chasing = false

func _on_attack_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_attack_area = true

func _on_attack_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_attack_area = false
