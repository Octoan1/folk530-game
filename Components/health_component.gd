extends Node
class_name HealthComponent

@export var debug_mode: bool = false

var max_health: float = 3

var health: float


signal died
signal damaged

func _init() -> void:
	health = max_health
	
#func damage_health(attack: Attack):
func damage_health(attack_damage: float) -> bool:
	health -= attack_damage
	if debug_mode:
		print(owner.name + " health is now: "+ str(health))
		
	damaged.emit()
	
	# death 
	if health <= 0:
		died.emit()
	return true
	

func heal_health(heal_amount: float) -> void:
	health += heal_amount
	
	if health >= max_health:
		health = max_health
