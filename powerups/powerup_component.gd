extends Area2D

@export var emitted_values = []
var linear_velocity = Vector2.ZERO
var angular_velocity = 0

signal collected(player, emitted_values)

func _physics_process(delta):
	position += linear_velocity * delta
	rotation_degrees += angular_velocity * delta

func _on_body_entered(body):
	if body.is_in_group("ship"):
		if body.owner_player == 1:
			collected.emit(1, emitted_values)
		elif body.owner_player == 2:
			collected.emit(2, emitted_values)
		else:
			pass #collected by ufo
		die()
	elif body.is_in_group("ufo"):
		die()


func _on_visible_on_screen_notifier_2d_screen_exited():
	if not $HitSound.playing:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("bullet") or area.is_in_group("super"):
		if area.owner_player == 1:
			collected.emit(1, emitted_values)
		elif area.owner_player == 2:
			collected.emit(2, emitted_values)
		else:
			pass #collected by ufo
		die()

func die():
	$HitSound.play()
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(1).timeout
	queue_free()
