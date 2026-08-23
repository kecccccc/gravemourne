extends CharacterBody2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape = $AttackArea/CollisionShape2D
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound
@onready var run_sound: AudioStreamPlayer = $RunSound
@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var land_sound: AudioStreamPlayer = $LandSound
var was_on_floor: bool = true
var attack_offset_x : float
var already_hit = []
const ATTACK_OFFSET = 40.0
var is_invincible: bool = false
var facing_right = true
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var max_health: int = 10
var health: int
var is_dead = false
var has_key: bool = false
const SPEED = 200.0
const JUMP_VELOCITY = -400.0
var jump_count: int = 0
const MAX_JUMPS: int = 2

var is_attacking = false





func _physics_process(delta: float) -> void:
	if is_dead:
		return
	# Gravitacija
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Skok
	if is_on_floor():
		if not was_on_floor:
			land_sound.play()
		jump_count = 0
	
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		velocity.y = JUMP_VELOCITY
		jump_count += 1
		jump_sound.play()
	
	was_on_floor = is_on_floor()

	# Napad
	if Input.is_action_just_pressed("attack") and !is_attacking:
		attack()

	# Kretanje levo/desno
	var direction = Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * SPEED

		# Okretanje sprite-a
		if direction < 0:
			animated_sprite_2d.flip_h = true
			facing_right = false

		elif direction > 0:
			animated_sprite_2d.flip_h = false
			facing_right = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if facing_right:
		attack_shape.position.x = attack_offset_x
	else:
		attack_shape.position.x = -attack_offset_x
	move_and_slide()

	_check_enemy_contact()

	player_animations(direction)

func _ready():
	attack_offset_x = attack_shape.position.x
	health = max_health
	
	
	
	
func player_animations(direction):
	if is_attacking or is_invincible:
		return
	if not is_on_floor():
		run_sound.stop()
		if animated_sprite_2d.animation != "jump":
			animated_sprite_2d.play("jump")
	elif direction != 0:
		if animated_sprite_2d.animation != "run":
			animated_sprite_2d.play("run")
		if not run_sound.playing:
			run_sound.play()
	else:
		run_sound.stop()
		if animated_sprite_2d.animation != "idle":
			animated_sprite_2d.play("idle")


var contact_damage_on_cooldown: bool = false
const CONTACT_DAMAGE_COOLDOWN: float = 1.0

func _check_enemy_contact() -> void:
	if is_dead or is_invincible or contact_damage_on_cooldown:
		return
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider and collider.is_in_group("contact_damage") and not collider.is_dead:
			contact_damage_on_cooldown = true
			take_damage(1)
			await get_tree().create_timer(CONTACT_DAMAGE_COOLDOWN).timeout
			contact_damage_on_cooldown = false
			return


func attack():
	if is_attacking:
		return
	is_attacking = true
	attack_sound.play()
	animated_sprite_2d.play("attack")
	await get_tree().create_timer(0.1).timeout
	for area in attack_area.get_overlapping_areas():
		var enemy = area.get_parent()
		if enemy.is_in_group("enemy"):
			enemy.take_damage(1)
	await animated_sprite_2d.animation_finished
	is_attacking = false
	
	
func take_damage(amount):
	if is_dead:
		return
	if is_invincible:
		return
	health -= amount
	print("Player HP:", health)
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_health(health, max_health)
	if health <= 0:
		die()
	else:
		play_damage_animation()


func heal(amount: int) -> void:
	if is_dead:
		return
	health = min(health + amount, max_health)
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_health(health, max_health)


func collect_key() -> void:
	has_key = true


func play_damage_animation() -> void:
	is_invincible = true
	is_attacking = false
	animated_sprite_2d.play("damage")
	await animated_sprite_2d.animation_finished
	is_invincible = false
	
	
func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite_2d.play("death")
	await animated_sprite_2d.animation_finished
	print("Death animation done, looking for DeathScreen...")
	var death_screen = get_tree().current_scene.get_node("DeathScreen")
	print("DeathScreen found: ", death_screen)
	var fade = death_screen.get_node("Fade")
	var you_died = death_screen.get_node("YouDied")
	print("Fade found: ", fade)
	print("YouDied found: ", you_died)

	death_screen.visible = true

	# fade to black
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 1.5)
	await tween.finished
	
	# show YOU DIED
	var tween2 = create_tween()
	tween2.tween_property(you_died, "modulate:a", 1.0, 1.0)
	await tween2.finished
	
	# pause then reload
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
