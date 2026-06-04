extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var air_jumps = 1
var current_air_jumps = 0

var coyote_timer = 0.0
const COYOTE_TIME_THRESHOLD = 0.1

var jump_buffer_timer = 0.0
const JUMP_BUFFER_TIMER_THRESHOLD = 0.1

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity*delta
	else:
		current_air_jumps = air_jumps
		coyote_timer = COYOTE_TIME_THRESHOLD
	
	if coyote_timer > 0:
		coyote_timer -= delta
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
		
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIMER_THRESHOLD
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y += 0.5
	if jump_buffer_timer > 0:
		if is_on_floor() or coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0
			coyote_timer = 0
		elif current_air_jumps > 0:
			velocity.y	 = JUMP_VELOCITY * 0.8
			current_air_jumps -= 1
			jump_buffer_timer = 0
	
	var direction = Input.get_axis("move_left", "move_right") # "move_left" & "move_right" from InputMap
			
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * 2.0 * delta)
		
		if $Sprite2D:
			$Sprite2D.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 2.0 * delta)
	move_and_slide()

		
func update_animations():
	pass
		
