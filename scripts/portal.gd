extends Area2D

@export var damage: int = 1
@export var telegraph_time: float = 0.8
@export var active_time: float = 0.3

var has_hit: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	animated_sprite_2d.play()

	await get_tree().create_timer(telegraph_time).timeout

	# enable the hitbox
	collision_shape_2d.set_deferred("disabled", false)

	# catch anyone already standing inside — body_entered won't fire for them
	await get_tree().physics_frame
	for body in get_overlapping_bodies():
		_on_body_entered(body)

	await get_tree().create_timer(active_time).timeout
	collision_shape_2d.set_deferred("disabled", true)

	# free on a fixed timer, not animation_finished — the animation may already
	# have ended during the waits above, and the signal would never fire again
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_body_entered(body: Node) -> void:
	if has_hit:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
		has_hit = true
