class_name SkillSet extends Object

enum SkillUID{
	RESPEC = 0,
	BASE_DAMAGE = 0b1, #
	
	BOLT_ACTION_RIFLE = 0b1 << 1, #
	RIFLE_DAMAGE_1 = 0b1 << 2, #
	RIFLE_FIRE_RATE = 0b1 << 3, #
	RIFLE_CHARGE_SHOT = 0b1 << 4, 
	RIFLE_DAMAGE_2 = 0b1 << 5, #
	RIFLE_MAG = 0b1 << 6, #
	RIFLE_EXPLOSIVE_SHOT = 0b1 << 7, #
	
	SHOTGUN = 0b1 << 8, #
	SHOTGUN_FIRE_RATE = 0b1 << 9, #
	SHOTGUN_HP_1 = 0b1 << 10, #
	SHOTGUN_KNOCKBACK = 0b1 << 11,
	SHOTGUN_HP_2 = 0b1 << 12, #
	SHOTGUN_MOVEMENT_SPEED = 0b1 << 13, #
	SHOTGUN_FIRE = 0b1 << 14, #
	
	DUAL_PISTOL = 0b1 << 15, #
	PISTOL_FIRE_RATE = 0b1 << 16, #
	PISTOL_ROLL_COOLDOWN = 0b1 << 17, #
	PISTOL_DOUBLE_SHOT = 0b1 << 18, #
	PISTOL_DAMAGE = 0b1 << 19, #
	PISTOL_MOVEMENT_SPEED = 0b1 << 20, #
	PISTOL_SALVAGE = 0b1 << 21, #
}

static var skill_bitfield : int

static func has_skill(skill : SkillUID) -> bool:
	return skill_bitfield & skill != 0
	
static func add_skill(skill : SkillUID) -> bool:
	var is_successful : bool = not has_skill(skill)
	skill_bitfield |= skill
	return is_successful

static func remove_skill(skill : SkillUID) -> bool:
	var is_successful : bool = has_skill(skill)
	skill_bitfield &= ~skill

	if is_successful:
		Global.skill_removed.emit(skill)

	return is_successful
