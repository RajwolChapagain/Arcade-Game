extends CharacterBody2D
 
@export var stats : ShipStats
@onready var max_hp = stats.toughness
@onready var bullet_damage = stats.damage
@onready var TIME_TO_FILL_SUPER = 100.0 / stats.recharge_rate
@onready var MAX_VELOCITY_MAGNITUDE = stats.top_speed #3000
@onready var THRUST_FORCE = stats.acceleration #Takes 3 seconds to reach max velocity w/ MAX_VELOCITY_MAGNITUDE = 3000

@export var RETARDING_FORCE = 750 #Takes 4 seconds to reach min from a MAX_VELOCITY_MAGNITUDE of 3000
@onready var hp = max_hp:
	get:
		return hp
	set(value):
		hp = value
		hp = clamp(hp, 0, max_hp)
		hp_changed.emit(hp)
		
@export var LEFT_STRING = "p1_left"
@export var RIGHT_STRING = "p1_right"
@export var UP_STRING = "p1_up"
@export var DOWN_STRING = "p1_down"
@export var FIRE_STRING = "p1_fire"
@export var SUPER_STRING = "p1_super"
@export var SHIELD_STRING = "p1_shield"
@export var SPEED_DECREASE_ON_FIRE = 250
@export var BULLET_LAYER_MASK = 2
@export var SUPER_DURATION = 1
@export var SHIELD_DURATION = 2
@export var super_percentage = 0:
	get:
		return super_percentage
	set(value):
		if value >= 100 and super_percentage < 100:
			$SuperFullSound.play()
		super_percentage = value
		super_percentage = clamp(super_percentage, 0, 100)
		super_percentage_changed.emit(super_percentage)
@export var expolosion_particles = load("res://misc_objects/explosion_particles.tscn")
@export var hit_particles = load("res://ship/scenes/hit_particles.tscn")

@export var fire_sound_players : Array[AudioStreamPlayer]
@export var bullet_origins : Array[Marker2D]

const ONLY_SHIP1_BULLET_LAYER = 4
const ONLY_SHIP2_BULLET_LAYER = 5
const SHARED_BULLET_LAYER = 3
const SHIP_COLLISION_DAMAGE = 20

var fire_button_is_pressed = false
var shield_is_active = false
var dash_time = 0.1
var dash_distance = 400
var dash_speed = dash_distance /  dash_time
var is_dashing = false
var is_bullet_ring_active = false
var current_bullet_ring
var owner_player = 1

var BULLET_SCENE = preload("res://bullet/bullet.tscn")
var BULLET_RING_SCENE = preload("res://bullet/bullet_ring.tscn")
var SUPER_SCENE = preload("res://ship/super.tscn")

signal bullet_fired(bullet, bullet_damage, direction, location)
signal hit(damage, hit_particles, global_position)
signal super_percentage_changed(new_super_percentage)
signal hp_changed(new_hp)
signal player_died(expolosion_particles, global_position)
signal super_fired(super_duration)

#Playtesting signals
signal shield_activated(owner_player)
signal bullet_ring_activated(owner_player)
signal alternative_super_fired(owner_player)

func _ready():
	$SuperTimer.wait_time = SUPER_DURATION
	$ShieldTimer.wait_time = SHIELD_DURATION
	
func _process(delta):
	get_input(delta)
	move_and_slide()	
	refill_super(delta)
	
	if is_bullet_ring_active:
		make_bullet_ring_follow_ship()
		
func _input(event):		
	if is_dashing:
		return
		
	if event.is_action_pressed(FIRE_STRING):
		for bullet_origin in bullet_origins:
			bullet_fired.emit(BULLET_SCENE, bullet_damage, transform.x, bullet_origin.global_position, owner_player)
		fire_sound_players.pick_random().play()
	
	if event.is_action_pressed(SUPER_STRING):
		if super_percentage == 100:
			if fire_button_is_pressed:
				fire_stream_of_bullets()
			else:
				for bullet_origin in bullet_origins:
					fire_super(bullet_origin.position)
			super_percentage = 0
			
	if event.is_action_pressed(SHIELD_STRING):
		if super_percentage == 100:
			if fire_button_is_pressed and not is_bullet_ring_active:
				instantiate_bullet_ring()
			else:
				activate_shield()
			super_percentage = 0
			$ShieldOnSound.play()
			
func get_input(delta):
	if is_dashing:
		return
		
	fire_button_is_pressed = Input.is_action_pressed(FIRE_STRING)
	
	var input_direction = Input.get_vector(LEFT_STRING, RIGHT_STRING, UP_STRING, DOWN_STRING)
	
	#---------------Rotation---------------
	if input_direction.length() != 0:
		var tween = get_tree().create_tween()
		
		var rotation_angle = transform.x.angle_to(input_direction)
		tween.tween_property(self, "rotation", rotation + rotation_angle, 0.5)
	
	#-------------Acceleration and Deceleration-------------
	if input_direction.length() != 0:
		velocity += input_direction * THRUST_FORCE * delta
	else:
		velocity += -velocity.normalized() * RETARDING_FORCE * delta
			
	velocity = clamp(velocity, Vector2.ZERO, velocity.limit_length(MAX_VELOCITY_MAGNITUDE))	
		
	#--------------Set velocity to 0 if it is very small-----------
	if velocity.length() < 10 and input_direction.length() == 0:
		velocity = Vector2.ZERO
	
func on_hit(damage):
	super_percentage += damage
	
	if shield_is_active:
		return	
		
	hp -= damage
	hit.emit(damage, hit_particles, global_position)
	if hp <= 0:
		die()
	$HitSound.play()
		
func die():
	player_died.emit(expolosion_particles, global_position)
	visible = false
	$CollisionShape2D.set_deferred("disabled", true) 
	is_dashing = true;
	await get_tree().create_timer(2).timeout
	queue_free()

func _on_super_timer_timeout():
	for child in get_children():
		if child.is_in_group("super"):
			remove_child(child)

func _on_visibility_notifier_screen_exited():
	var inset = 10
	if position.x < 0:
		position.x = get_viewport_rect().size.x - inset
	elif position.x > get_viewport_rect().size.x:
		position.x = inset
	
	if position.y < 0:
		position.y = get_viewport_rect().size.y - inset
	elif position.y > get_viewport_rect().size.y:
		position.y = inset
	
func activate_shield():
	$ShieldTimer.start()	
	$Shield.visible = true
	shield_is_active = true
	shield_activated.emit(owner_player)

func deactivate_shield():
	$Shield.visible = false
	shield_is_active = false
	
func _on_shield_timer_timeout():
	deactivate_shield()

func dash():
	velocity = transform.x * dash_speed
	is_dashing = true
	await get_tree().create_timer(dash_time).timeout
	is_dashing = false
	velocity = Vector2.ZERO

func fire_stream_of_bullets():
	for i in range(10):
		for bullet_origin in bullet_origins:		
			bullet_fired.emit(BULLET_SCENE, bullet_damage, transform.x, bullet_origin.global_position, owner_player)
		fire_sound_players.pick_random().play()
		await get_tree().create_timer(0.05).timeout
	
	alternative_super_fired.emit(owner_player)

func on_bullet_ring_destroyed():
	is_bullet_ring_active = false

func fire_super(pos):
	$SuperTimer.start()
	super_fired.emit(SUPER_DURATION)
	var super_instance = SUPER_SCENE.instantiate()
	super_instance.position = pos
	super_instance.super_did_damage.connect(on_super_did_damage)
	super_instance.owner_player = owner_player
	add_child(super_instance)
	$SuperSound.play()

func refill_super(delta):
	if velocity.length() < MAX_VELOCITY_MAGNITUDE - 5: #Subtracting by 5 because length is not always exactly equal to 1500
		super_percentage += delta * 100 / TIME_TO_FILL_SUPER

func make_bullet_ring_follow_ship():	
	if !is_queued_for_deletion():
		current_bullet_ring.global_position = global_position

func instantiate_bullet_ring():
	current_bullet_ring = BULLET_RING_SCENE.instantiate()
	current_bullet_ring.destroyed.connect(on_bullet_ring_destroyed)
	current_bullet_ring.global_position = global_position
	current_bullet_ring.owner_player = owner_player
	add_sibling(current_bullet_ring)
	is_bullet_ring_active = true
	bullet_ring_activated.emit(owner_player)

func on_super_did_damage(damage):
	super_percentage += damage / 2
