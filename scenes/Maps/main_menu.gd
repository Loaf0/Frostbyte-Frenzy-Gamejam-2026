extends Node3D

@onready var camera: Camera3D = $SubViewportContainer/SubViewport/POI/Camera3D

@onready var main_location : Node3D = $SubViewportContainer/SubViewport/POI/MAIN_LOCATION
@onready var options_location : Node3D = $SubViewportContainer/SubViewport/POI/OPTIONS
@onready var poi_folder: Node3D = $SubViewportContainer/SubViewport/POI

@onready var character_container : Node3D = $SubViewportContainer/SubViewport/World/Characters

@onready var character_pois: Array[Node3D] = [
	$SubViewportContainer/SubViewport/POI/CHARACTER_0,
	$SubViewportContainer/SubViewport/POI/CHARACTER_1,
	$SubViewportContainer/SubViewport/POI/CHARACTER_2,
	$SubViewportContainer/SubViewport/POI/CHARACTER_3,
	$SubViewportContainer/SubViewport/POI/CHARACTER_4,
	$SubViewportContainer/SubViewport/POI/CHARACTER_5
]

@export var lerp_speed: float = 5.0
var target_poi: Node3D

func _ready() -> void:
	Save.load_player()
	update_character_visibility()
	target_poi = main_location

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_6:
			var index = event.keycode - KEY_1
			go_to_character(index)
		if event.keycode == KEY_0:
			go_to_main()

func update_character_visibility() -> void:
	for i in range(Global.CharacterClass.size()):
		var model = character_container.get_node_or_null(str(i))
		if model:
			model.visible = Global.unlocked_characters.get(i, false)

func _process(delta: float) -> void:
	if not target_poi or not camera:
		return
	
	var weight = lerp_speed * delta
	
	camera.global_position = camera.global_position.lerp(target_poi.global_position, weight)
	camera.quaternion = camera.quaternion.slerp(target_poi.quaternion, weight)

	if camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		var target_zoom = target_poi.get("camera_zoom") if "camera_zoom" in target_poi else 9.5
		camera.size = lerp(camera.size, target_zoom, weight)

func go_to_character(id: int):
	if id >= 0 and id < character_pois.size():
		if Global.unlocked_characters.get(id, false):
			target_poi = character_pois[id]

func go_to_main():
	target_poi = main_location
