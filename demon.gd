extends CharacterBody2D

@export var speed: float = 80.0
@export var wait_time: float = 0.5
@export var health: int = 3
@export var start_point_index: int = 0
@export var bob_amount: float = 0.0
@export var bob_speed: float = 4.0

@export var attack_cooldown: float = 2.0
@export var projectile_scene: PackedScene

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var point_1: Node2D = $PatrolPoints/Point1
@onready var point_2: Node2D = $PatrolPoints/Point2
@onready var detection_area: Area2D = $DetectionArea

var patrol_points: Array[Vector2] = []
var current_point_index: int = 0
var is_waiting: bool = false
var is_dead: bool = false
var start_sprite_y: float = 0.0
var bob_offset: float = 0.0

var can_attack: bool = true
var is_attacking: bool = false
var player_in_range: Node2D = null


func _ready() -> void:
	add_to_group("enemy")
	patrol_points = [
		point_1.global_position,
		point_2.global_position
	]

	current_point_index = start_point_index
	start_sprite_y = animated_sprite_2d.position.y
	bob_offset = randf() * 10.0

	animated_sprite_2d.play("idle")

	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	apply_bobbing()

	if player_in_range and can_attack and not is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		attack(player_in_range)
		return

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if is_waiting:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	patrol_movement()
	move_and_slide()
	update_animation()


func patrol_movement() -> void:
	var target_position = patrol_points[current_point_index]
	var direction = global_position.direction_to(target_position)

	velocity = direction * speed

	# Ovo je obrnuto jer je tvoj sprite originalno okrenut na drugu stranu.
	if direction.x < 0:
		animated_sprite_2d.flip_h = false
	elif direction.x > 0:
		animated_sprite_2d.flip_h = true

	if global_position.distance_to(target_position) < 5.0:
		global_position = target_position
		velocity = Vector2.ZERO
		start_waiting()


func start_waiting() -> void:
	is_waiting = true
	animated_sprite_2d.play("idle")

	current_point_index += 1

	if current_point_index >= patrol_points.size():
		current_point_index = 0

	await get_tree().create_timer(wait_time).timeout
	is_waiting = false


func apply_bobbing() -> void:
	if bob_amount > 0:
		var time = Time.get_ticks_msec() / 1000.0
		animated_sprite_2d.position.y = start_sprite_y + sin(time * bob_speed + bob_offset) * bob_amount


func update_animation() -> void:
	if is_waiting:
		if animated_sprite_2d.animation != "idle":
			animated_sprite_2d.play("idle")
	else:
		if animated_sprite_2d.animation != "flying":
			animated_sprite_2d.play("flying")


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null


func attack(player: Node2D) -> void:
	if is_dead:
		return
	is_attacking = true
	can_attack = false

	# Same flip_h convention as patrol_movement: true faces right.
	animated_sprite_2d.flip_h = player.global_position.x > global_position.x
	animated_sprite_2d.play("attack")

	await get_tree().create_timer(0.3).timeout
	if not is_dead and projectile_scene:
		spawn_projectile(player)

	await animated_sprite_2d.animation_finished
	is_attacking = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func spawn_projectile(player: Node2D) -> void:
	var proj = projectile_scene.instantiate()
	proj.direction = (player.global_position - global_position).normalized()
	proj.global_position = global_position
	get_parent().add_child(proj)


func take_damage(amount: int) -> void:
	if is_dead:
		return
	health -= amount
	print("Demon HP:", health)

	if health <= 0:
		die()


func die() -> void:
	is_dead = true
	is_attacking = false
	can_attack = false
	player_in_range = null
	velocity = Vector2.ZERO
	animated_sprite_2d.play("death")
	await animated_sprite_2d.animation_finished
	queue_free()
