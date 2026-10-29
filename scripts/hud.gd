extends CanvasLayer
## Health bar, score, controls hint and centre-screen messages.

const BAR_WIDTH: float = 200.0
const SCREEN_W: float = 1152.0
const SCREEN_H: float = 648.0

var health_fill: ColorRect
var score_label: Label
var message_label: Label
var hint_label: Label


func _ready() -> void:
	layer = 10

	var hp_title := _make_label("HEALTH", 18)
	hp_title.position = Vector2(24, 14)
	add_child(hp_title)

	var bar_bg := ColorRect.new()
	bar_bg.color = Color("#1a2238")
	bar_bg.position = Vector2(24, 42)
	bar_bg.size = Vector2(BAR_WIDTH + 4.0, 22)
	add_child(bar_bg)

	health_fill = ColorRect.new()
	health_fill.color = Color("#37e6a0")
	health_fill.position = Vector2(26, 44)
	health_fill.size = Vector2(BAR_WIDTH, 18)
	add_child(health_fill)

	score_label = _make_label("SCORE 0", 26)
	score_label.position = Vector2(SCREEN_W - 24.0 - 300.0, 14)
	score_label.size = Vector2(300, 36)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(score_label)

	message_label = _make_label("", 44)
	message_label.position = Vector2.ZERO
	message_label.size = Vector2(SCREEN_W, SCREEN_H)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(message_label)

	hint_label = _make_label("A / D or Arrows: move     Space / W: jump (press again in mid-air to double jump)     Stomp enemies, avoid spikes!", 16)
	hint_label.position = Vector2(0, SCREEN_H - 40.0)
	hint_label.size = Vector2(SCREEN_W, 30)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(hint_label)
	var tw := create_tween()
	tw.tween_interval(7.0)
	tw.tween_property(hint_label, "modulate:a", 0.0, 1.5)

	SignalBus.score_changed.connect(_on_score_changed)
	SignalBus.health_changed.connect(_on_health_changed)
	_on_score_changed(ScoreManager.score)


func show_message(text: String) -> void:
	message_label.text = text


func _make_label(text: String, font_size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 6)
	return l


func _on_score_changed(new_score: int) -> void:
	score_label.text = "SCORE  %d" % new_score


func _on_health_changed(current: int, maximum: int) -> void:
	var ratio: float = float(current) / float(maxi(maximum, 1))
	health_fill.size.x = BAR_WIDTH * ratio
	if ratio > 0.6:
		health_fill.color = Color("#37e6a0")
	elif ratio > 0.3:
		health_fill.color = Color("#ffd24d")
	else:
		health_fill.color = Color("#ff4d6d")
