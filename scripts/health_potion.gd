extends Area2D

@export var heal_amount: int = 2
@export var bob_amount: float = 2.0
@export var bob_speed: float = 3.0

@onready var sprite: Sprite2D = $Sprite2D

var start_sprite_y: float = 0.0


func _ready() -> void:
	start_sprite_y = sprite.position.y
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0
	sprite.position.y = start_sprite_y + sin(time * bob_speed) * bob_amount


func _on_body_entered(body: Node) -> void:
	if body.has_method("heal"):
		body.heal(heal_amount)
	queue_free()
