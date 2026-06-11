extends CharacterBody2D
const SPEED = 250.0
const JUMP_VELOCITY = -250.0
var was_on_floor = false
var is_jump_held = false
var jump_hold_timer = 0.0
const MAX_JUMP_HOLD_TIME = 0.25
const JUMP_HOLD_FORCE = 1000.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed_multiplier = 1
var air_jumps = 1
var current_air_jumps = 0
var coyote_timer = 0.0
const COYOTE_TIME_THRESHOLD = 0.1
var jump_buffer_timer = 0.0
const JUMP_BUFFER_TIMER_THRESHOLD = 0.1
var dash_buffer_timer = 0.0

func _physics_process(delta):
	var on_floor = is_on_floor()
	if not on_floor:
		velocity.y += gravity * delta
	else:
		current_air_jumps = air_jumps
		coyote_timer = COYOTE_TIME_THRESHOLD
	if coyote_timer > 0:
		coyote_timer -= delta
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	if dash_buffer_timer > 0:
		dash_buffer_timer -= delta
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIMER_THRESHOLD
	if Input.is_action_just_pressed("down"):
		if not is_on_floor():
			velocity.y += 800
	if jump_buffer_timer > 0:
		if is_on_floor() or coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0
			coyote_timer = 0
			is_jump_held = true
			jump_hold_timer = 0.0
		elif current_air_jumps > 0:
			velocity.y = JUMP_VELOCITY * 0.8
			current_air_jumps -= 1
			jump_buffer_timer = 0
			is_jump_held = true
			jump_hold_timer = 0.0
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		var accel = SPEED * 10.0 if is_on_floor() else SPEED * 4.0
		velocity.x = move_toward(velocity.x, direction * SPEED, accel * delta * speed_multiplier)
		if speed_multiplier > 1:
			speed_multiplier -= 2
		if speed_multiplier <= 1:
			speed_multiplier = 1
		if $AnimatedSprite2D:
			$AnimatedSprite2D.flip_h = (direction < 0)
	else:
		var decel = SPEED * 14.0 if is_on_floor() else SPEED * 3.0
		velocity.x = move_toward(velocity.x, 0, decel * delta)
	if is_jump_held:
		if Input.is_action_pressed("jump") and jump_hold_timer < MAX_JUMP_HOLD_TIME and velocity.y < 0:
			velocity.y -= JUMP_HOLD_FORCE * delta
			jump_hold_timer += delta
		else:
			is_jump_held = false
			
	if Input.is_action_just_pressed("use_grapple"):
		if dash_buffer_timer <= 0:
			if $ProgressBar.value >= 30 if direction != 0 else $ProgressBar.value >= 100:
				$ProgressBar.value -= 30
				$DashParticles.emitting = true
				dash_buffer_timer = 1
				if direction == -1:
					velocity += Vector2(-2, 0) * 500
				elif direction == 1:
					velocity += Vector2(2, 0) * 500
				else:
					$ProgressBar.value -= 100
					dash_buffer_timer = 10
					velocity += Vector2(0, -2) * 500
	else:
		$DashParticles.emitting = false
		
	if $ProgressBar.value == 100:
		$ProgressBar.indeterminate = true
	else:
		$ProgressBar.indeterminate = false
	
	move_and_slide()
	update_animations(on_floor, was_on_floor)
	$ProgressBar.value += 0.1
	was_on_floor = on_floor

func update_animations(on_floor: bool, prev_on_floor: bool):
	if not $AnimatedSprite2D: return
	if not on_floor:
		if prev_on_floor or velocity.y < 0 and $AnimatedSprite2D.animation != "jump":
			$AnimatedSprite2D.play("jump")
			$JumpParticles.emitting = true
		elif velocity.y > 0 and not $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.play("fall")
			$JumpParticles.emitting = false
	else:
		if abs(velocity.x) > 5:
			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("idle")
