extends Area2D
## The exit beacon at the end of the level. `position` is the top-left corner.

const SIZE: Vector2 = Vector2(40.0, 120.0)

var reached: bool = false
var t: float = 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	cs.shape = rect
	cs.position = SIZE / 2.0
	add_child(cs)
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	t += delta
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if reached:
		return
	if body is Player:
		reached = true
		SignalBus.goal_reached.emit()


func _draw() -> void:
	var glow: float = 0.15 + 0.1 * sin(t * 4.0)
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.2, 1.0, 0.6, glow))
	draw_rect(Rect2(18, 0, 4, 120), Color("#d8fff0"))
	draw_colored_polygon(PackedVector2Array([Vector2(22, 4), Vector2(40, 16), Vector2(22, 28)]), Color("#37ffa8"))
