extends CharacterBody2D

const HEALTH_POTION_SCENE: PackedScene = preload("res://scenes/health_potion.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea
@onready var attack_sound: AudioStreamPlayer = $AttackSound
@onready var hurtbox = $Hurtbox

@export var speed = 100.0
@export var stop_distance = 5.0
@export var attack_offset: float = 20.0
@export var max_health: int = 10
var current_health: int

var player = null
var spawn_position: Vector2
var chasing = false
var can_attack = true
var player_in_attack_range = false
var facing_right = true
var is_dead = false

func _ready():
	add_to_group("enemy")
	add_to_group("executioner")
	current_health = max_health
	spawn_position = global_position
	detection_area.body_entered.connect(_on_detection_entered)
	detection_area.body_exited.connect(_on_detection_exited)
	attack_area.body_entered.connect(_on_attack_entered)
	attack_area.body_exited.connect(_on_attack_exited)
	hurtbox.area_entered.connect(_on_hurtbox_entered)
	animated_sprite_2d.play("idle")

func _physics_process(delta):
	if is_dead:
		return

	if facing_right:
		attack_area.position.x = abs(attack_offset)
	else:
		attack_area.position.x = -abs(attack_offset)

	if player_in_attack_range and can_attack and player:
		attack(player)
		return

	if chasing and player:
		var distance = global_position.distance_to(player.global_position)
		if distance > stop_distance:
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * speed
			if direction.x < 0:
				animated_sprite_2d.flip_h = true
				facing_right = false
			else:
				animated_sprite_2d.flip_h = false
				facing_right = true
		else:
			velocity.x = 0
	else:
		if global_position.distance_to(spawn_position) > 5:
			var direction = (spawn_position - global_position).normalized()
			velocity.x = direction.x * speed
			if direction.x < 0:
				animated_sprite_2d.flip_h = true
				facing_right = false
			else:
				animated_sprite_2d.flip_h = false
				facing_right = true
		else:
			velocity.x = 0
			if animated_sprite_2d.animation != "idle":
				animated_sprite_2d.play("idle")

	move_and_slide()

func _on_hurtbox_entered(area):
	if area.name == "AttackArea":
		take_damage(1)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	current_health -= amount
	print("Executioner HP: ", current_health, "/", max_health)
	if current_health <= 0:
		die()

func die() -> void:
	is_dead = true
	remove_from_group("executioner")
	velocity = Vector2.ZERO
	animated_sprite_2d.play("death")
	await animated_sprite_2d.animation_finished
	_drop_health_potion()
	queue_free()

func _drop_health_potion() -> void:
	var potion = HEALTH_POTION_SCENE.instantiate()
	potion.global_position = global_position
	get_parent().add_child(potion)

func _on_detection_entered(body):
	if body.name == "Player":
		player = body
		chasing = true

func _on_detection_exited(body):
	if body.name == "Player":
		chasing = false

func _on_attack_entered(body):
	if body.name == "Player":
		player_in_attack_range = true

func _on_attack_exited(body):
	if body.name == "Player":
		player_in_attack_range = false

func attack(target):
	can_attack = false
	velocity.x = 0
	attack_sound.play()
	animated_sprite_2d.play("attack")

	# First slash hit-check
	await get_tree().create_timer(0.3).timeout
	if player_in_attack_range and is_instance_valid(target) and not is_dead:
		target.take_damage(1)

	# Second slash sound at its original visual timing
	await get_tree().create_timer(0.7).timeout
	attack_sound.play()

	# Second slash hit-check — delayed a bit further behind the sound so it
	# lands past the player's 1s post-hit invincibility window and isn't
	# swallowed by the first hit.
	await get_tree().create_timer(0.35).timeout
	if player_in_attack_range and is_instance_valid(target) and not is_dead:
		target.take_damage(1)
	if player_in_attack_range and is_instance_valid(target) and not is_dead:
		target.take_damage(1)

	await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("idle")
	await get_tree().create_timer(1.0).timeout
	can_attack = true
