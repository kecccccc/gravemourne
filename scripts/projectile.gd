extends Area2D

@export var speed: float = 150.0
@export var damage: int = 1
@export var lifetime: float = 4.0

var direction: Vector2 = Vector2.RIGHT

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	sprite.flip_h = direction.x < 0


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
