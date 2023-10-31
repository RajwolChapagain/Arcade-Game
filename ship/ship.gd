extends CharacterBody2D

@export var TOP_SPEED = 1500
@export var ACCELERATION = 1000 #Per second. Multiply by delta
@export var DECELERATION = 800 #Per second. Multiply by delta
@export var ROTATION_SPEED = 270 #Degrees per second. Multiply by delta
@export var SHIP_SPRITE : Texture2D = preload("res://ship/ship_sprite.png")
@export var hp = 100
@export var THRUST_STRING = "p1_thrust"
@export var ROTATE_CLOCKWISE_STRING = "p1_rotate_clockwise"
@export var ROTATE_ANTICLOCKWISE_STRING = "p1_rotate_anticlockwise"
@export var FIRE_STRING = "p1_fire"
@export var SUPER_STRING = "p1_super"
@export var BULLET_LAYER = 2
@export var SPEED_DECREASE_ON_FIRE = 250
@export var SUPER_DURATION = 1
@export var super_percentage = 0:
	get:
		return super_percentage
	set(value):
		super_percentage = value
		super_percentage_changed.emit(super_percentage)
		
@export var TIME_TO_FILL_SUPER = 5

var current_speed = 0
var thrust_direction = transform.x
var frozen = false

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
	
func _physics_process(delta):
	get_input(delta)
	velocity = thrust_direction * current_speed
	move_and_slide()

func _input(event):
	if frozen:
		return
		
	if event.is_action_pressed(FIRE_STRING):
		bullet_fired.emit(BULLET_SCENE, transform.x, global_position, BULLET_LAYER)
		current_speed -= SPEED_DECREASE_ON_FIRE
	
	if event.is_action_pressed(SUPER_STRING) and super_percentage == 100:
		super_percentage = 0
		var super_instance = SUPER_SCENE.instantiate()
		add_child(super_instance)
		super_instance.collision_layer = BULLET_LAYER
		super_instance.collision_mask = BULLET_LAYER
		$SuperTimer.start()
		freeze()
	
func get_input(delta):

	#-----------Thrust-------------------
	if Input.is_action_pressed(THRUST_STRING) and not frozen:
		current_speed += ACCELERATION * delta
		thrust_direction = transform.x
	else:
		current_speed -= DECELERATION * delta
		super_percentage += 100 * delta / TIME_TO_FILL_SUPER #Where 100 is max percentage
		super_percentage = clamp(super_percentage, 0, 100)
		
	current_speed = clamp(current_speed, 0, TOP_SPEED)
	
	#------------Rotation-----------------
	if not frozen:
		var rotation_direction = Input.get_axis(ROTATE_ANTICLOCKWISE_STRING, ROTATE_CLOCKWISE_STRING)
		rotation_degrees += rotation_direction * ROTATION_SPEED * delta
	
func on_hit(damage):
	hp -= damage
	hit.emit(damage)
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
	player_exited_screen.emit()


func _on_visibility_notifier_screen_entered():
	player_entered_screen.emit()
