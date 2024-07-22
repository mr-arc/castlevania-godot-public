extends Node
class_name Enemy

signal damaged(healthRemaining)
signal killed

enum HitSound {
	NORMAL_HIT,
	INEFFECTIVE_HIT
}

enum DeathBehavior {
	EXPLODE,
	BOSS_EXPLODE,
	NOTIFY_ONLY
}

export(String) var enemyName
export(int) var damage = 1
export(int) var points = 0
export(int) var weakHits = 1
export(int) var strongHits = 1
export(NodePath) var hitbox: NodePath
export(HitSound) var hitSound
export(DeathBehavior) var deathBehavior
export(String) var drop
export(bool) var dieOnSimonCollision: bool = false
export(Vector2) var explosionOffset = Vector2.ZERO

var health: float

onready var hitboxInstance: Hitbox = get_node(hitbox)
onready var simon: Simon = Globals.getSimon()

func _ready():
	health = weakHits - 0.5
	hitboxInstance.connect("hit", self, "_on_hitbox_hit")
	hitboxInstance.connect("hit_simon", self, "_on_hitbox_hitSimon")
	
func _on_hitbox_hit(weapon: String):
	hit(weapon)
	
func _on_hitbox_hitSimon():
	if not simon.invincible:
		simon.doDamage(damage)
		if dieOnSimonCollision:
			die(true)

func hit(weapon: String) -> void:
	var damage = getWeaponDamage(weapon)
	health -= damage
	emit_signal("damaged", max(0, health))
	if health <= 0:
		Globals.playSound(Globals.WHIP_HIT, owner.global_position)
		die()
	else:
		Globals.playSound(
			Globals.WHIP_HIT if hitSound == HitSound.NORMAL_HIT else Globals.INEFFECTIVE_HIT, 
			owner.global_position)
		
func die(muted: bool = false) -> void:
	Stats.kill(enemyName, Globals.currentStage)
	emit_signal("killed")
	simon.score += points
	if deathBehavior == DeathBehavior.EXPLODE:
		Globals.explodeNode(owner, hitboxInstance.global_position + explosionOffset, drop, muted)
	elif deathBehavior == DeathBehavior.BOSS_EXPLODE:
		Globals.bossExplode(owner, owner.global_position + explosionOffset)
	

func getWeaponDamage(weapon: String) -> float:
	match weapon:
		Items.AXE, Items.CROSS, Items.WHIP_2, Items.WHIP_3:
			return float(weakHits) / float(strongHits)
	return 1.0
	
static func findEnemy(node: Node) -> Enemy:
	return node.find_node("Enemy", true, false) as Enemy
