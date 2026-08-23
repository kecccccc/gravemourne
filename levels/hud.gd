extends CanvasLayer

@onready var health_bar: TextureProgressBar = $HealthBar
var target_health: float = 0.0

func _ready() -> void:
	add_to_group("hud")
	var player = get_tree().current_scene.get_node("Player")
	var max_hp = player.max_health
	health_bar.max_value = max_hp
	health_bar.value = max_hp
	target_health = float(max_hp)
	print("HUD loaded, healthbar value: ", health_bar.value)

func _process(delta: float) -> void:
	health_bar.value = lerp(health_bar.value, target_health, delta * 200.0)

func update_health(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	target_health = float(current)
	print("Bar updated - target: ", target_health, " current bar value: ", health_bar.value)
