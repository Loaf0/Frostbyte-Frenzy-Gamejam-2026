extends AnimationPlayer

@export var step_fps: float = 12.0
var step_time: float
var timer: float = 0.0

func _ready() -> void:
	step_time = 1.0 / step_fps
	callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL

func _process(delta: float) -> void:
	timer += delta
	while timer >= step_time:
		advance(step_time)
		timer -= step_time
