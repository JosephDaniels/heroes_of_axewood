extends CharacterBody2D

const SPEED = 200

# Combo window (frames 5–8 at 10fps = 0.5–0.8s)
const COMBO_WINDOW_START = 0.5
const COMBO_WINDOW_END = 0.8

const HEAVY_ATTACK_HOLD_TIME = 0.6  # Hold this long to trigger heavy

@onready var sprite = $BodySprite

var is_attacking = false
var attack_timer = 0.0
var facing_left = false
var combo_triggered = false
var combo_window_open = false
var current_attack_anim = ""

# New for heavy attack
var attack_button_held = false
var attack_hold_timer = 0.0
var heavy_attack_queued = false

func _physics_process(delta):
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var y_input = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if abs(x_input) > 0:
		y_input = 0
	elif abs(y_input) > 0:
		x_input = 0

	var input_vector = Vector2(x_input, y_input).normalized()
	velocity = input_vector * SPEED
	move_and_slide()

	if not is_attacking:
		if x_input < 0:
			sprite.flip_h = true
			facing_left = true
		elif x_input > 0:
			sprite.flip_h = false
			facing_left = false

	if is_attacking and velocity.length() > 0:
		reset_attack()
		sprite.play("walk")
		return

	# Combo window
	if is_attacking and sprite.animation == "attack":
		attack_timer += delta
		combo_window_open = attack_timer >= COMBO_WINDOW_START and attack_timer <= COMBO_WINDOW_END

	if is_attacking and attack_timer > COMBO_WINDOW_END:
		combo_window_open = false

	# Track hold duration for heavy attack
	if attack_button_held and not is_attacking:
		attack_hold_timer += delta
		if attack_hold_timer >= HEAVY_ATTACK_HOLD_TIME and not heavy_attack_queued:
			print("💢 Heavy attack queued!")
			heavy_attack_queued = true

	# ATTACK INPUT HANDLING
	if Input.is_action_just_pressed("attack"):
		attack_button_held = true
		attack_hold_timer = 0.0
		heavy_attack_queued = false

	elif Input.is_action_just_released("attack"):
		attack_button_held = false

		if not is_attacking:
			if heavy_attack_queued:
				print("💥 Heavy attack triggered!")
				is_attacking = true
				sprite.play("heavy_attack")
				sprite.frame = 0
				current_attack_anim = "heavy_attack"
			else:
				print("🔪 Starting normal attack")
				is_attacking = true
				attack_timer = 0.0
				combo_triggered = false
				combo_window_open = false
				sprite.play("attack")
				sprite.frame = 0
				sprite.flip_h = facing_left
				current_attack_anim = "attack"

		elif is_attacking and sprite.animation == "attack" and combo_window_open and not combo_triggered:
			print("🎯 Combo input SUCCESSFUL: playing second_attack")
			sprite.play("second_attack")
			sprite.frame = 0
			combo_triggered = true
			attack_timer = 0.0
			combo_window_open = false
			current_attack_anim = "second_attack"

	elif not is_attacking:
		if velocity.length() > 0:
			sprite.play("walk")
		else:
			sprite.play("idle")

func _on_body_sprite_animation_finished():
	print("✅ Animation finished:", sprite.animation)
	if sprite.animation in ["attack", "second_attack", "heavy_attack"]:
		reset_attack()
		if velocity.length() > 0:
			sprite.play("walk")
		else:
			sprite.play("idle")

func reset_attack():
	print("🧹 Resetting attack state")
	is_attacking = false
	combo_triggered = false
	combo_window_open = false
	attack_timer = 0.0
	current_attack_anim = ""
	attack_hold_timer = 0.0
	heavy_attack_queued = false
