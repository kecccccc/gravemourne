extends CharacterBody2D

const KEY_ITEM_SCENE: PackedScene = preload("res://scenes/key_item.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var hurtbox: Area2D = $Hurtbox
@onready var attack_sound: AudioStreamPlayer = $AttackSound

@export var speed: float = 110.0
@export var stop_distance: float = 5.0
@export var attack_offset: float = 20.0
@export var max_health: int = 10
@export var attack_cooldown: float = 0.6
@export var double_attack_chance: float = 0.3
@export var lunge_chance: float = 0.4
@export var lunge_range: float = 160.0
@export var lunge_speed_mult: float = 2.5
@export var lunge_duration: float = 0.3
@export var lunge_cooldown: float = 2.0
@export var enrage_health_threshold: float = 0.5
@export var enrage_speed_mult: float = 1.3
@export var enrage_cooldown_mult: float = 0.65

var current_health: int
var player = null
var spawn_position: Vector2
var chasing = false
var can_attack = true
var is_attacking = false
var is_hurt = false
var player_in_attack_range = false
var facing_right = true
var is_dead = false
var is_lunging = false
var can_lunge = true
var is_enraged = false


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

	if facing_right:
		attack_area.position.x = attack_offset
	else:
		attack_area.position.x = -attack_offset

	if is_attacking:
		return

	if player_in_attack_range and can_attack and player:
		attack(player)
		return

	if is_lunging:
		move_and_slide()
		return

	if chasing and player:
		var distance = global_position.distance_to(player.global_position)
		if not player_in_attack_range and can_lunge and distance <= lunge_range and distance > stop_distance and randf() < lunge_chance:
			_lunge(player)
			return
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
	if is_hurt:
		return
	if animated_sprite_2d.animation != anim_name:
		animated_sprite_2d.play(anim_name)


func _face(direction_x: float) -> void:
	if direction_x < 0:
		animated_sprite_2d.flip_h = true
		facing_right = false
	else:
		animated_sprite_2d.flip_h = false
		facing_right = true


func _on_hurtbox_entered(area: Area2D) -> void:
	if area.name == "AttackArea":
		take_damage(1)


func take_damage(amount: int) -> void:
	if is_dead:
		return
	current_health -= amount
	print("bigSkelly HP: ", current_health, "/", max_health)
	if current_health <= 0:
		die()
		return
	if not is_enraged and current_health <= max_health * enrage_health_threshold:
		_enrage()
	_play_hurt()


func _enrage() -> void:
	is_enraged = true
	speed *= enrage_speed_mult
	attack_cooldown *= enrage_cooldown_mult
	lunge_chance = min(lunge_chance * 1.5, 1.0)
	var tween = create_tween()
	tween.tween_property(animated_sprite_2d, "modulate", Color(1, 0.4, 0.4), 0.15)
	tween.tween_property(animated_sprite_2d, "modulate", Color(1, 1, 1), 0.15)


func _play_hurt() -> void:
	is_hurt = true
	animated_sprite_2d.play("hurt")
	await animated_sprite_2d.animation_finished
	is_hurt = false


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite_2d.play("death")
	await animated_sprite_2d.animation_finished
	_drop_key()
	queue_free()


func _drop_key() -> void:
	var key = KEY_ITEM_SCENE.instantiate()
	key.global_position = global_position
	get_parent().add_child(key)


func _on_detection_entered(body: Node) -> void:
	if body.name == "Player":
		player = body
		chasing = true


func _on_detection_exited(body: Node) -> void:
	if body.name == "Player":
		chasing = false


func _on_attack_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_attack_range = true


func _on_attack_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_attack_range = false


func attack(target) -> void:
	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO
	attack_sound.play()
	animated_sprite_2d.play("attack")
	await animated_sprite_2d.animation_finished
	if player_in_attack_range and is_instance_valid(target) and not is_dead:
		target.take_damage(1)
	is_attacking = false

	if player_in_attack_range and is_instance_valid(target) and not is_dead and randf() < double_attack_chance:
		await get_tree().create_timer(0.15).timeout
		if player_in_attack_range and is_instance_valid(target) and not is_dead:
			attack(target)
			return

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func _lunge(target) -> void:
	is_lunging = true
	can_lunge = false
	var direction = (target.global_position - global_position).normalized()
	_face(direction.x)
	velocity.x = direction.x * speed * lunge_speed_mult
	_play_movement_animation("walk")
	await get_tree().create_timer(lunge_duration).timeout
	is_lunging = false
	await get_tree().create_timer(lunge_cooldown).timeout
	can_lunge = true
