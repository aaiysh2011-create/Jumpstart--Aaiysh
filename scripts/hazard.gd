extends Area2D
## Spikes. Touching them is instant death. `position` is the top-left corner.

var extent: Vector2 = Vector2(72, 24)


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(extent.x - 8.0, extent.y - 8.0)
	cs.shape = rect
	cs.position = Vector2(extent.x / 2.0, extent.y / 2.0 + 4.0)
	add_child(cs)


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		var p := body as Player
		if p != null:
			p.instakill()


func _draw() -> void:
	var count: int = maxi(int(extent.x / 18.0), 1)
	var w: float = extent.x / float(count)
	for i in count:
		var pts := PackedVector2Array([
			Vector2(i * w, extent.y),
			Vector2(i * w + w / 2.0, 0.0),
			Vector2((i + 1) * w, extent.y),
		])
		draw_colored_polygon(pts, Color("#ff4d6d"))
