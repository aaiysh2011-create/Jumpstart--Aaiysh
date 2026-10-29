extends Area2D
## Flying chaser. Drifts toward the player when close, returns home when the
## player is far away. It can't be stomped, so dodge it. `position` is its home.

const SPEED: float = 95.0
const DETECT_RANGE: float = 420.0
const BOB_AMPLITUDE: float = 8.0

var home: Vector2 = Vector2.ZERO
var t: float = 0.0
var target: Player = null


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	home = global_position
	t = randf() * TAU
	var cs := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 13.0
	cs.shape = circle
	add_child(cs)


func _physics_process(delta: float) -> void:
	t += delta
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Player

	var goal: Vector2 = home
	if target != null and not target.dead:
		if global_position.distance_to(target.global_position) < DETECT_RANGE:
			goal = target.global_position

	var to_goal: Vector2 = goal - global_position
	if to_goal.length() > 4.0:
		global_position += to_goal.normalized() * SPEED * delta

	for body in get_overlapping_bodies():
		var p := body as Player
		if p != null and not p.dead:
			p.take_damage(1, global_position.x)

	queue_redraw()


func _draw() -> void:
	var bob: float = sin(t * 6.0) * BOB_AMPLITUDE
	var flap: float = sin(t * 20.0) * 7.0
	var c := Vector2(0.0, bob * 0.5)
	# wings
	draw_colored_polygon(PackedVector2Array([c + Vector2(-6, 0), c + Vector2(-26, -8 + flap), c + Vector2(-20, 6)]), Color("#7a3fd1"))
	draw_colored_polygon(PackedVector2Array([c + Vector2(6, 0), c + Vector2(26, -8 + flap), c + Vector2(20, 6)]), Color("#7a3fd1"))
	# body (diamond)
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -14), c + Vector2(13, 0), c + Vector2(0, 14), c + Vector2(-13, 0)]), Color("#b46bff"))
	draw_circle(c, 5.0, Color("#ff4d6d"))
	draw_circle(c, 2.0, Color.WHITE)
