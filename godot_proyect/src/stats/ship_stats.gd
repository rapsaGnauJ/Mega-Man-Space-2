class_name StatsShip
extends Stats


export var max_hp: float = 28.0
export var max_speed: float = 260
# Multiplier to calculate acceleration from speed.
export var acceleration_ratio: float = 7.0/4.0
export var deacceleration_ratio: float = 4.0/5.0
# Damage dealt when colliding with another Ship.
export var collision_damage: float = 4.0
# Time until the ship can take damage again.
export var invencibility_time: float = .5
# Distance at which this ships sees other ships.
export var view_distance: float = 300.0

# Value to multiply damage by. Higher is weaker.
export(Dictionary) var weaknesses = { 
	Weapon.TYPES.MEGA : 1,
	Weapon.TYPES.BUBBLE : 1,
	Weapon.TYPES.AIR : 1,
	Weapon.TYPES.QUICK : 1,
	Weapon.TYPES.HEAT : 1,
	Weapon.TYPES.WOOD : 1,
	Weapon.TYPES.METAL : 1,
	Weapon.TYPES.FLASH : 1,
	Weapon.TYPES.CRASH : 1,
}

export var _cap_max_speed:= Vector2(200, 380)
export var _cap_max_hp:= Vector2(20, 36)
