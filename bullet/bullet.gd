extends Area2D

@export var SPEED = 4000
@export var DAMAGE = 10

var direction = transform.x
var is_in_ring = false
var owner_player = 1

signal bullet_did_damage(owner_player)
signal bullet_exited_screen(owner_player)

func _physics_process(delta):
	check_object_in_path()
	position += direction * SPEED * delta

func set_direction(new_direction):
	direction = new_direction
	rotation = new_direction.angle()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if is_in_ring:
		return
	queue_free()
	bullet_exited_screen.emit(owner_player)
	
func on_hit(_damage): #Useful when super destroys bullet
	queue_free()


func _on_body_entered(body):
	if body.is_in_group("ship") and body.owner_player == owner_player: #If it is the player that fired the bullet
		return
		
	if body.is_in_group("ufo") or body.is_in_group("ship"):
		bullet_did_damage.emit(owner_player, DAMAGE)
		
	if body.has_method("on_hit"):
		body.on_hit(DAMAGE)
	
	if body.is_in_group("debris"):
		body.on_bullet_hit()
		
	queue_free()

func _on_area_entered(area): #For collision with powerups and other bullets
	if area.is_in_group("bullet") and area.owner_player == owner_player:
		return
		
	if is_in_ring and area.is_in_group("super") and area.owner_player == owner_player:
		return
	queue_free()

func check_object_in_path():
	var upper_collider = $UpperRay.get_collider()
	if upper_collider != null:
		if upper_collider.is_in_group("bullet") and upper_collider.owner_player != owner_player:
			_on_area_entered(upper_collider)
			upper_collider.queue_free()
		if upper_collider.is_in_group("debris"):
			upper_collider.on_bullet_hit()
			queue_free()
	
	var lower_collider = $LowerRay.get_collider()
	if lower_collider != null:
		if lower_collider.is_in_group("bullet") and lower_collider.owner_player != owner_player:
			_on_area_entered(lower_collider)
			lower_collider.queue_free()
		if lower_collider.is_in_group("debris"):
			lower_collider.on_bullet_hit()
			queue_free()
