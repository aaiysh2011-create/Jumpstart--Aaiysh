extends Area2D
## Ground patrol enemy. Walks back and forth. Stomp it from above to defeat it;
## touching it any other way hurts. `position` is its centre.

const SPEED: float = 70.0
const SIZE: Vector2 = Vector2(34.0, 28.0)

var patrol_distance: float = 120.0
var origin_x: float = 0.0
var dir: float = 1.0
var defeated: bool = false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	origin_x = position.x
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	cs.shape = rect
	add_child(cs)


func _physics_process(delta: float) -> void:
	if defeated:
		return

	position.x += dir * SPEED * delta
	if position.x > origin_x + patrol_distance:
		position.x = origin_x + patrol_distance
		dir = -1.0
		queue_redraw()
	elif position.x < origin_x - patrol_distance:
		position.x = origin_x - patrol_distance
		dir = 1.0
		queue_redraw()

	for body in get_overlapping_bodies():
		var p := body as Player
		if p != null and not p.dead:
			_hit_player(p)
			if defeated:
				return


func _hit_player(p: Player) -> void:
	var feet_y: float = p.global_position.y + Player.BODY_SIZE.y / 2.0
	var stomping: bool = p.velocity.y > 0.0 and feet_y <= global_position.y
	if stomping:
		p.bounce()
		_defeat()
	else:
		p.take_damage(1, global_position.x)


func _defeat() -> void:
	defeated = true
	set_deferred("monitoring", false)
	ScoreManager.add_points(25)
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	tw.tween_callback(queue_free)


func _draw() -> void:
	draw_rect(Rect2(-17, -14, 34, 28), Color("#ff5d73"))
	draw_rect(Rect2(-17, 8, 34, 6), Color("#a3263c"))
	draw_rect(Rect2(-9, -6, 7, 7), Color.WHITE)
	draw_rect(Rect2(3, -6, 7, 7), Color.WHITE)
	draw_rect(Rect2(-7 + dir * 2.0, -4, 3, 4), Color.BLACK)
	draw_rect(Rect2(5 + dir * 2.0, -4, 3, 4), Color.BLACK)
