class_name WeaponResource
extends Resource

@export var weapon_name : String
@export var weapon_type : Global.WeaponType

@export_category("Models")
@export var world_model : PackedScene

@export_category("Weapon Stats")
@export var base_damage : float = 10
@export var base_attack_speed : float = 1
@export var base_size : float = 1
@export var base_mana_cost : float = 15
@export var base_stamina_cost : float = 15
@export var projectile : PackedScene = null
@export var projectile_damage : float = 10

@export_category("Quality Scaling")
@export var strength_scaling : float = 1.0
@export var knowledge_scaling : float = 1.0
@export var dexterity_scaling : float = 1.0
@export var attack_speed_scale : float = 1.0
@export var size_scale : float = 1.0

@export_category("World Model Adjustments")
@export var world_model_pos : Vector3
@export var world_model_rot : Vector3
@export var world_model_scale : Vector3 = Vector3.ONE

@export_category("Animations")
@export var attack1_anim : String
@export var damage_mult1 : float = 1
@export var attack2_anim : String
@export var damage_mult2 : float = 1
@export var attack3_anim : String
@export var damage_mult3 : float = 1

@export_category("Pickup")
@export var pickup_model: PackedScene
@export var pickup_quality: Global.WeaponQuality = Global.WeaponQuality.COMMON
@export var glow_intensity: float = 10.0
@export var pulse_speed: float = 2.0
@export var rotate_speed: float = 1.2
@export var bob_height: float = 0.15
