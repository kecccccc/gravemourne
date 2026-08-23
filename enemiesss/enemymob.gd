extends CharacterBody2D

@export var speed: float = 80.0
@export var wait_time: float = 0.5
@export var health: int = 3
@export var start_point_index: int = 0
@export var bob_amount: float = 0.0
@export var bob_speed: float = 4.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var point_1: Node2D = $PatrolPoints/Point1
@onready var point_2: Node2D = $PatrolPoints/Point2

var patrol_points: Array[Vector2] = []
var current_point_index: int = 0
var is_waiting: bool = false
var is_dead: bool = false
var start_sprite_y: float = 0.0
var bob_offset: float = 0.0


func _ready() -> void:
	add_to_group("enemy")
	add_to_group("contact_damage")
	patrol_points = [
		point_1.global_position,
		point_2.global_position
	]

	current_point_index = start_point_index
	start_sprite_y = animated_sprite_2d.position.y
	bob_offset = randf() * 10.0

	animated_sprite_2d.play("idle")


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	apply_bobbing()

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

	# Okretanje sprite-a levo/desno
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


func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy HP:", health)

	if health <= 0:
		die()


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	queue_free()
