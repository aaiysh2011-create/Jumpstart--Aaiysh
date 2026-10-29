extends Area2D
## A data fragment. +10 score. `position` is its centre.

var base_y: float = 0.0
var t: float = 0.0
var collected: bool = false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	base_y = position.y
	t = randf() * TAU
	var cs := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	cs.shape = circle
	add_child(cs)
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	t += delta
	position.y = base_y + sin(t * 3.0) * 4.0
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if collected:
		return
	if body is Player:
		collected = true
		ScoreManager.add_fragment()
		queue_free()


func _draw() -> void:
	var squash: float = 0.4 + 0.6 * absf(cos(t * 2.0))
	draw_circle(Vector2.ZERO, 15.0, Color(0.2, 0.9, 1.0, 0.15))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -11), Vector2(8 * squash, 0), Vector2(0, 11), Vector2(-8 * squash, 0)
	]), Color("#37e6ff"))
	draw_circle(Vector2.ZERO, 2.5, Color.WHITE)
