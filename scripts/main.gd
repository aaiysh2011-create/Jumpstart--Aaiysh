extends Node2D
## Builds the level, spawns everything, and handles win / death / restart.

const LEVEL_WIDTH: float = 4200.0
const FLOOR_Y: float = 560.0

const PlatformScript = preload("res://scripts/platform.gd")
const HazardScript = preload("res://scripts/hazard.gd")
const MobScript = preload("res://scripts/hostile_mob.gd")
const FlyerScript = preload("res://scripts/flying_enemy.gd")
const CollectibleScript = preload("res://scripts/collectible.gd")
const GoalScript = preload("res://scripts/goal.gd")
const HudScript = preload("res://scripts/hud.gd")

var hud
var player: Player
var can_restart: bool = false


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("#080b14"))

	hud = HudScript.new()
	add_child(hud)
	ScoreManager.reset()

	SignalBus.player_died.connect(_on_player_died)
	SignalBus.goal_reached.connect(_on_goal_reached)

	_build_walls()
	_build_platforms()
	_build_hazards()
	_build_fragments()
	_build_enemies()

	var goal = GoalScript.new()
	goal.position = Vector2(4090, FLOOR_Y - 120.0)
	add_child(goal)

	# Player goes in last so it draws on top of everything.
	player = Player.new()
	player.position = Vector2(90, 500)
	player.level_width = LEVEL_WIDTH
	add_child(player)


func _process(_delta: float) -> void:
	if can_restart and Input.is_action_just_pressed("jump"):
		get_tree().reload_current_scene()


# ----------------------------------------------------------------- level

func _add_platform(x: float, y: float, w: float, h: float) -> void:
	var p = PlatformScript.new()
	p.position = Vector2(x, y)
	p.extent = Vector2(w, h)
	add_child(p)


func _add_wall(x: float) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = Vector2(x, 0)
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(40, 3000)
	cs.shape = rect
	body.add_child(cs)
	add_child(body)


func _build_walls() -> void:
	_add_wall(-20.0)
	_add_wall(LEVEL_WIDTH + 20.0)


func _build_platforms() -> void:
	# Ground segments (with pits between them)
	_add_platform(0, FLOOR_Y, 900, 100)
	_add_platform(1050, FLOOR_Y, 600, 100)
	_add_platform(1800, FLOOR_Y, 500, 100)
	_add_platform(2450, FLOOR_Y, 700, 100)
	_add_platform(3300, FLOOR_Y, 900, 100)
	# Floating platforms
	_add_platform(500, 440, 160, 24)
	_add_platform(720, 340, 160, 24)
	_add_platform(1250, 440, 140, 24)
	_add_platform(1480, 350, 140, 24)
	_add_platform(1950, 430, 160, 24)
	_add_platform(2150, 330, 160, 24)
	_add_platform(2650, 430, 140, 24)
	_add_platform(2860, 340, 140, 24)
	_add_platform(3500, 440, 160, 24)


func _build_hazards() -> void:
	var spots: Array = [
		[1500.0, 72.0],
		[2200.0, 60.0],
		[3050.0, 72.0],
		[3950.0, 72.0],
	]
	for s in spots:
		var h = HazardScript.new()
		h.position = Vector2(s[0], FLOOR_Y - 24.0)
		h.extent = Vector2(s[1], 24.0)
		add_child(h)


func _build_fragments() -> void:
	var spots: Array = [
		Vector2(300, 520), Vector2(380, 520), Vector2(460, 520),
		Vector2(580, 400), Vector2(800, 300),
		Vector2(1000, 500), Vector2(1320, 400), Vector2(1550, 310),
		Vector2(1750, 500), Vector2(2030, 390), Vector2(2230, 290),
		Vector2(2550, 520), Vector2(2720, 390), Vector2(2930, 300),
		Vector2(3200, 500), Vector2(3580, 400), Vector2(3700, 520),
		Vector2(3800, 520), Vector2(3900, 480), Vector2(4150, 500),
	]
	for pos in spots:
		var c = CollectibleScript.new()
		c.position = pos
		add_child(c)


func _build_enemies() -> void:
	# [x, patrol distance]
	var mobs: Array = [
		[600.0, 120.0],
		[1250.0, 100.0],
		[2000.0, 150.0],
		[2800.0, 200.0],
		[3600.0, 200.0],
	]
	for m in mobs:
		var mob = MobScript.new()
		mob.position = Vector2(m[0], FLOOR_Y - 14.0)
		mob.patrol_distance = m[1]
		add_child(mob)

	var flyers: Array = [
		Vector2(1500, 240), Vector2(2400, 280),
		Vector2(3000, 230), Vector2(3850, 280),
	]
	for f in flyers:
		var fl = FlyerScript.new()
		fl.position = f
		add_child(fl)


# ------------------------------------------------------------ game flow

func _on_player_died() -> void:
	hud.show_message("SIGNAL LOST\nRebooting...")
	await get_tree().create_timer(1.6).timeout
	if is_inside_tree():
		get_tree().reload_current_scene()


func _on_goal_reached() -> void:
	player.input_enabled = false
	hud.show_message("SYSTEM RESTORED!\nScore: %d\nPress Space to play again" % ScoreManager.score)
	await get_tree().create_timer(0.8).timeout
	can_restart = true


# ------------------------------------------------------------ background

func _draw() -> void:
	draw_rect(Rect2(-200, -300, LEVEL_WIDTH + 400.0, 1400), Color("#0a0e1a"))
	var grid := Color(0.2, 0.4, 0.6, 0.07)
	var x: float = 0.0
	while x <= LEVEL_WIDTH:
		draw_line(Vector2(x, -300), Vector2(x, 1100), grid, 1.0)
		x += 64.0
	var y: float = -256.0
	while y <= 1100.0:
		draw_line(Vector2(-200, y), Vector2(LEVEL_WIDTH + 200.0, y), grid, 1.0)
		y += 64.0
	# "data streams"
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 90:
		var sx: float = rng.randf_range(0.0, LEVEL_WIDTH)
		var sy: float = rng.randf_range(0.0, 520.0)
		var seg: float = rng.randf_range(20.0, 90.0)
		var a: float = rng.randf_range(0.08, 0.25)
		draw_line(Vector2(sx, sy), Vector2(sx, sy + seg), Color(0.2, 0.9, 0.8, a), 2.0)
