extends Resource
class_name PowerUp

@export_enum("Hero", "Villain")
var player: String
@export_enum("Damage", "Speed", "Timer Speed", "Health", "Damage Nerf", "Speed Nerf")
var habilidad: String
@export var info: String
@export var damage: int
@export var speed: int
@export var timer_speed: float
@export var health: int
@export var damage_nerf: int
@export var speed_nerf: int
