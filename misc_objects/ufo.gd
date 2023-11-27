extends CharacterBody2D

var linear_velocity = Vector2.ZERO
var angular_velocity = 0
var hp = 100:
	get:
		return hp
	set(value):
		hp = value
		hp = clamp(hp, 0, 100)
	
var bullet_scene = preload("res://bullet/bullet.tscn")
var bullet_layers = [1, 2] 
var bullet_layer_masks = [1, 2]

signal bullet_fired(bullet_scene, bullet_position, bullet_direction, bullet_layers : Array, bullet_layer_masks : Array)

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
				bullet_fired.emit(bullet_scene, child.global_position, child.position.normalized(), bullet_layers, bullet_layer_masks)
				await get_tree().create_timer(0.01).timeout
		
	
