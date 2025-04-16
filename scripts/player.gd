extends CharacterBody2D

const X_SPEED_RUN = 300.0
const X_SPEED_FLY = 400.0
const X_SPEED_FALL = 150.0
const FLY_VERTICAL_ACCELERATION = -30.0

var direction = 1
var fuel = 100.0
var fuel_change = 0.05

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var game_manager: Node = %"Game Manager"
@onready var timer: Timer = $Timer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var last_space_time := 0.0
var double_tap_threshold := 0.3
var space_pressed := false  # Zmienna śledząca, czy spacja jest wciśnięta

func _input(event):
	if event is InputEventKey or event is InputEventScreenTouch:  # Obsługuje klawisze
		if event.pressed:  # Naciśnięcie spacji
			if not space_pressed:  # Jeżeli spacja jeszcze nie była przytrzymana
				var now = Time.get_ticks_msec() / 1000.0
				if now - last_space_time <= double_tap_threshold:
					direction = -direction
					if direction == 1:
						animated_sprite.flip_h = false
					else:
						animated_sprite.flip_h = true
				last_space_time = now
				space_pressed = true  # Oznaczamy, że spacja jest przytrzymana
		else:  # Zwolnienie spacji
			space_pressed = false  # Oznaczamy, że spacja jest zwolniona

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite.play("fly")
	else:
		animated_sprite.play("run")

	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
		
	if space_pressed: 
			velocity.x = direction * X_SPEED_FLY
			fuel -= fuel_change
			if fuel <= 0:
				fuel = 0
				kill()
			game_manager.change_fuel(fuel)
	else:
		if is_on_floor():
			velocity.x = direction * X_SPEED_RUN
		else:
			velocity.x = direction * X_SPEED_FALL
			
	if space_pressed and not is_on_ceiling():  # Dodaliśmy również obsługę Y przy lataniu
		velocity.y += FLY_VERTICAL_ACCELERATION
	
	move_and_slide()

func kill():
	Engine.time_scale = 0.5
	collision_shape_2d.disabled = true
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
	
