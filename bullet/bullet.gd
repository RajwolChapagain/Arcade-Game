extends Area2D

@export var SPEED = 4000
@export var DAMAGE = 10

var direction = transform.x
var is_in_ring = false
var owner_player = 1

signal bullet_did_damage(owner_player)

func _physics_process(delta):
	position += direction * SPEED * delta

func set_direction(new_direction):
	direction = new_direction

func _on_visible_on_screen_notifier_2d_screen_exited():
	if is_in_ring:
		return
	queue_free()

func on_hit(_damage): #Useful when super destroys bullet
	queue_free()


func _on_body_entered(body):
	if body.is_in_group("ship") and body.owner_player == owner_player: #If it is the player that fired the bullet
		return
		
	if body.is_in_group("ufo") or body.is_in_group("ship"):
		bullet_did_damage.emit(owner_player, DAMAGE)
		
	if body.has_method("on_hit"):
		body.on_hit(DAMAGE)
		
	queue_free()

func _on_area_entered(area): #For collision with powerups and other bullets
	if area.is_in_group("bullet") and area.owner_player == owner_player:
		return
		
	if is_in_ring and area.is_in_group("super") and area.owner_player == owner_player:
		return
	queue_free()
