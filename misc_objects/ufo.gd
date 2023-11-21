extends CharacterBody2D

var linear_velocity = 0
var angular_velocity = 0
var hp = 100:
	get:
		return hp
	set(value):
		hp = value
		hp = clamp(hp, 0, 100)
		#hp_changed.emit(hp)

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
	pass #Fire stream of bullets from all markers
