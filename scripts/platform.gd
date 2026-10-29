extends StaticBody2D
## A solid rectangular platform. `position` is its top-left corner.

var extent: Vector2 = Vector2(200, 32)


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = extent
	cs.shape = rect
	cs.position = extent / 2.0
	add_child(cs)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, extent), Color("#141c2e"))
	var x: float = 24.0
	while x < extent.x:
		draw_line(Vector2(x, 10), Vector2(x, minf(extent.y, 80.0)), Color("#1f2c47"), 1.0)
		x += 24.0
	draw_rect(Rect2(Vector2.ZERO, extent), Color("#2b3c63"), false, 2.0)
	draw_rect(Rect2(0, 0, extent.x, 4), Color("#37e6c3"))
