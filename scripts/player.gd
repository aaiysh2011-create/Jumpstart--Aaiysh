class_name Player
extends CharacterBody2D
## The robot. Acceleration-based movement, coyote time, jump buffering,
## variable jump height, double jump, health, knockback, i-frames, death.

const MAX_SPEED: float = 330.0
const GROUND_ACCEL: float = 2800.0
const GROUND_FRICTION: float = 3200.0
const AIR_ACCEL: float = 1900.0
const AIR_FRICTION: float = 900.0
const JUMP_VELOCITY: float = -780.0
const GRAVITY: float = 2300.0
const FALL_GRAVITY_MULT: float = 1.4
const MAX_FALL_SPEED: float = 1200.0
const JUMP_CUT: float = 0.45
const COYOTE_TIME: float = 0.1
const JUMP_BUFFER_TIME: float = 0.12
const MAX_JUMPS: int = 2
const MAX_HEALTH: int = 5
const INVINCIBLE_TIME: float = 1.3
const KNOCKBACK: Vector2 = Vector2(360.0, -430.0)
const KNOCKBACK_TIME: float = 0.18
const FALL_DEATH_Y: float = 820.0
const BODY_SIZE: Vector2 = Vector2(28.0, 40.0)

var level_width: float = 4200.0
var level_bottom: float = 720.0

var health: int = MAX_HEALTH
var dead: bool = false
var input_enabled: bool = true
var facing: float = 1.0

var jumps_left: int = MAX_JUMPS
var coyote_timer: float = 0.0
var buffer_timer: float = 0.0
var invincible_timer: float = 0.0
var knock_timer: float = 0.0

var body_shape: CollisionShape2D


func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1

	body_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = BODY_SIZE
	body_shape.shape = rect
	add_child(body_shape)

	var cam := Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 7.0
	cam.limit_left = 0
	cam.limit_right = int(level_width)
	cam.limit_top = 0
	cam.limit_bottom = int(level_bottom)
	add_child(cam)
	cam.make_current()

	SignalBus.health_changed.emit(health, MAX_HEALTH)


func _physics_process(delta: float) -> void:
	if dead:
		return

	invincible_timer = maxf(invincible_timer - delta, 0.0)
	knock_timer = maxf(knock_timer - delta, 0.0)

	var on_floor: bool = is_on_floor()
	if on_floor:
		coyote_timer = COYOTE_TIME
		jumps_left = MAX_JUMPS
	else:
		coyote_timer -= delta
		# Walked off a ledge without jumping: the "ground jump" is gone,
		# so only the air jump remains.
		if coyote_timer <= 0.0 and jumps_left > MAX_JUMPS - 1:
			jumps_left = MAX_JUMPS - 1

	# --- Gravity (heavier on the way down for a snappier feel) ---
	if not on_floor:
		var g: float = GRAVITY
		if velocity.y > 0.0:
			g *= FALL_GRAVITY_MULT
		velocity.y = minf(velocity.y + g * delta, MAX_FALL_SPEED)

	# --- Horizontal movement ---
	if knock_timer <= 0.0:
		var dir: float = 0.0
		if input_enabled:
			dir = Input.get_axis("left", "right")
		if dir != 0.0:
			var new_facing: float = signf(dir)
			if new_facing != facing:
				facing = new_facing
				queue_redraw()
			var accel: float = GROUND_ACCEL if on_floor else AIR_ACCEL
			velocity.x = move_toward(velocity.x, dir * MAX_SPEED, accel * delta)
		else:
			var friction: float = GROUND_FRICTION if on_floor else AIR_FRICTION
			velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	# --- Jumping (buffer + coyote + double jump) ---
	var jump_pressed: bool = input_enabled and Input.is_action_just_pressed("jump")
	var jump_released: bool = input_enabled and Input.is_action_just_released("jump")

	if jump_pressed:
		buffer_timer = JUMP_BUFFER_TIME
	else:
		buffer_timer -= delta

	if buffer_timer > 0.0:
		if coyote_timer > 0.0:
			velocity.y = JUMP_VELOCITY
			jumps_left = MAX_JUMPS - 1
			coyote_timer = 0.0
			buffer_timer = 0.0
		elif jumps_left > 0:
			velocity.y = JUMP_VELOCITY
			jumps_left -= 1
			buffer_timer = 0.0

	# Release early = short hop
	if jump_released and velocity.y < 0.0:
		velocity.y *= JUMP_CUT

	move_and_slide()

	# --- Fell into a pit ---
	if global_position.y > FALL_DEATH_Y:
		instakill()


func _process(_delta: float) -> void:
	if dead:
		visible = false
		return
	visible = true
	if invincible_timer > 0.0:
		# Blink while invincible
		visible = int(Time.get_ticks_msec() * 0.0125) % 2 == 0


## Called by enemies. Knocks the player away from `from_x`.
func take_damage(amount: int, from_x: float) -> void:
	if dead or invincible_timer > 0.0:
		return
	health = maxi(health - amount, 0)
	SignalBus.health_changed.emit(health, MAX_HEALTH)
	if health <= 0:
		_die()
		return
	invincible_timer = INVINCIBLE_TIME
	var dir: float = 1.0 if global_position.x >= from_x else -1.0
	velocity = Vector2(KNOCKBACK.x * dir, KNOCKBACK.y)
	knock_timer = KNOCKBACK_TIME


## Spikes and pits: no health bar can save you.
func instakill() -> void:
	if dead:
		return
	health = 0
	SignalBus.health_changed.emit(health, MAX_HEALTH)
	_die()


## Called after stomping an enemy.
func bounce() -> void:
	velocity.y = JUMP_VELOCITY * 0.8
	jumps_left = MAX_JUMPS - 1
	coyote_timer = 0.0


func _die() -> void:
	dead = true
	velocity = Vector2.ZERO
	visible = false
	body_shape.set_deferred("disabled", true)
	SignalBus.player_died.emit()


func _draw() -> void:
	var body_col := Color("#4fd1ff")
	var dark := Color("#12303f")
	# legs
	draw_rect(Rect2(-10, 12, 8, 8), dark)
	draw_rect(Rect2(2, 12, 8, 8), dark)
	# torso
	draw_rect(Rect2(-14, -2, 28, 14), body_col)
	draw_rect(Rect2(-4, 2, 8, 6), Color("#ffe14d"))
	# head
	draw_rect(Rect2(-12, -20, 24, 18), body_col)
	draw_rect(Rect2(-9, -16, 18, 9), dark)
	draw_rect(Rect2(-3 + facing * 4.0, -14, 6, 5), Color("#ffe14d"))
	# antenna
	draw_line(Vector2(0, -20), Vector2(0, -27), Color.WHITE, 2.0)
	draw_circle(Vector2(0, -28), 3.0, Color("#ff4d6d"))
