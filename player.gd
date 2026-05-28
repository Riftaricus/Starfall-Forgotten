extends Area2D

@export var speed = 16000
var screen_size
const GRAVITY = 1
var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		velocity.x -= 5
	if Input.is_action_pressed("move_right"):
		velocity.x += 5
	if Input.is_action_pressed("jump"):
		velocity.y -= 5
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		position += velocity * delta
		position = position.clamp(Vector2.ZERO, screen_size)
		
	velocity.y -= gravity
	if velocity.x > 0:
		velocity.x -= 0.5
	elif velocity.x < 0:
		velocity.x += 0.5
