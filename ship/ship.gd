extends CharacterBody2D
 
@export var THRUST_FORCE = 1000 #Takes 3 seconds to reach max velocity w/ MAX_VELOCITY_MAGNITUDE = 3000
@export var MAX_VELOCITY_MAGNITUDE = 3000
@export var RETARDING_FORCE = 750 #Takes 4 seconds to reach min from a MAX_VELOCITY_MAGNITUDE of 3000
@export var SHIP_SPRITE : Texture2D = preload("res://ship/ship_sprite.png")
@export var hp = 100
@export var LEFT_STRING = "p1_left"
@export var RIGHT_STRING = "p1_right"
@export var UP_STRING = "p1_up"
@export var DOWN_STRING = "p1_down"
@export var FIRE_STRING = "p1_fire"
@export var SUPER_STRING = "p1_super"
@export var SHIELD_STRING = "p1_shield"
@export var BULLET_LAYER = 2
@export var SPEED_DECREASE_ON_FIRE = 250
@export var SUPER_DURATION = 1
@export var SHIELD_DURATION = 2
@export var super_percentage = 0:
	get:
		return super_percentage
	set(value):
		super_percentage = value
		super_percentage = clamp(super_percentage, 0, 100)
		super_percentage_changed.emit(super_percentage)
@export var TIME_TO_FILL_SUPER = 10

var frozen = false#might be obsolete
var shield_button_is_pressed = false
var shield_is_active = false

var BULLET_SCENE = preload("res://bullet/bullet.tscn")
var SUPER_SCENE = preload("res://ship/super.tscn")

signal bullet_fired(bullet, direction, location, bullet_layer)
signal hit(damage)
signal super_percentage_changed(new_super_percentage)
signal player_died
signal player_exited_screen
signal player_entered_screen

func _ready():
	$Sprite2D.texture = SHIP_SPRITE
	$SuperTimer.wait_time = SUPER_DURATION
	$ShieldTimer.wait_time = SHIELD_DURATION
	
func _process(delta):
	super_percentage += delta * 100 / TIME_TO_FILL_SUPER
	get_input(delta)
	move_and_slide()

func _input(event):
	if frozen:
		return
		
	if event.is_action_pressed(FIRE_STRING):
		bullet_fired.emit(BULLET_SCENE, transform.x, global_position, BULLET_LAYER)
	
	if event.is_action_pressed(SUPER_STRING) and super_percentage == 100:
		super_percentage = 0
		if shield_button_is_pressed:
			$ShieldTimer.start()
			activate_shield()
		else:
			$SuperTimer.start()
			var super_instance = SUPER_SCENE.instantiate()
			add_child(super_instance)
			super_instance.collision_layer = BULLET_LAYER
			super_instance.collision_mask = BULLET_LAYER
			freeze()
	
func get_input(delta):
	shield_button_is_pressed = Input.is_action_pressed(SHIELD_STRING)
	var input_direction = Input.get_vector(LEFT_STRING, RIGHT_STRING, UP_STRING, DOWN_STRING)

	if input_direction.length() != 0:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "rotation", input_direction.angle(), 0.5)
		
	if input_direction.length() != 0:
		velocity += input_direction * THRUST_FORCE * delta
	else:
		velocity += -velocity.normalized() * RETARDING_FORCE * delta
			
	velocity = clamp(velocity, Vector2.ZERO, velocity.limit_length(MAX_VELOCITY_MAGNITUDE))	
	
	
	if velocity.length() < 10 and input_direction.length() == 0:
		velocity = Vector2.ZERO
	
	print(velocity)

func on_hit(damage):
	if shield_is_active:
		return
	hp -= damage
	hit.emit(damage)
	super_percentage += damage
	if hp <= 0:
		die()
		
func die():
	player_died.emit()
	queue_free()

func _on_super_timer_timeout():
	remove_child($Super)
	unfreeze()
	
func freeze():
	frozen = true

func unfreeze():
	frozen = false

func _on_visibility_notifier_screen_exited():
	#player_exited_screen.emit()
	position = -position
	
func _on_visibility_notifier_screen_entered():
	#player_entered_screen.emit()
	pass
	
func activate_shield():
	$Shield.visible = true
	shield_is_active = true

func deactivate_shield():
	$Shield.visible = false
	shield_is_active = false
	

func _on_shield_timer_timeout():
	deactivate_shield()
