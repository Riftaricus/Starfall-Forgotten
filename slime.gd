extends CharacterBody2D

var vel_multiplier = 5
var player
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	player = get_node("/root/Game/Player")
	$AnimatedSprite2D.play("walk")

func _physics_process(delta: float) -> void:
	var on_floor = is_on_floor()
	if not on_floor:
		velocity.y += gravity * delta

	if player:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * 3
		move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
