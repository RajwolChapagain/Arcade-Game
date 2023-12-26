extends CharacterBody2D

var linear_velocity = Vector2.ZERO
var angular_velocity = 0
var hp = 100:
	get:
		return hp
	set(value):
		hp = value
		hp = clamp(hp, 0, 100)
		$HealthBar.value = hp
	
var bullet_scene = preload("res://bullet/bullet.tscn")

signal bullet_fired(bullet_scene, bullet_position, bullet_direction)

func _ready():
	velocity = linear_velocity
	
func _physics_process(delta):
	move_and_slide()
	rotation_degrees += angular_velocity * delta

func on_hit(damage):
	hp -= damage
	if hp <= 0:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_fire_timer_timeout():	
	for i in range(5):
		for child in get_children():
			if child.is_class("Marker2D"):
				bullet_fired.emit(bullet_scene, child.global_position, global_position.direction_to(child.global_position).normalized())
				if get_tree() != null:#☣️FIX ME: Crashes saying Cannot call method create_timer on a null value when game tries to restart as it fires
					await get_tree().create_timer(0.01).timeout 
		
	
