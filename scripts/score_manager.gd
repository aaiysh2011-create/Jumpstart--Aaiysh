extends Node
## Keeps track of the score (autoload).

var score: int = 0
var fragments: int = 0


func reset() -> void:
	score = 0
	fragments = 0
	SignalBus.score_changed.emit(score)


func add_points(amount: int) -> void:
	score += amount
	SignalBus.score_changed.emit(score)


func add_fragment() -> void:
	fragments += 1
	add_points(10)
	SignalBus.fragment_collected.emit()
