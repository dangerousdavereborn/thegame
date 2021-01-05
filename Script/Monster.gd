extends KinematicBody2D

const BULLET = preload("res://Prefabs/MonsterBullet.tscn")
onready var globals = get_node("/root/Globals")
onready var animation = $AnimatedSprite
export var texture = "res://Images/enemies/conevir.png"
var timer

export var move_speed = 100
export (NodePath) var patrol_path
var patrol_points
var velocity = Vector2.ZERO
var patrol_index = 0
export var is_rotate = false

var canFire=true

func _ready():
	if texture:
		$Sprite.texture = load(texture)
	add_to_group("monster")
	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()

	timer = get_tree().create_timer(0.0)
	if animation:
		1==1
		animation.play("dummy")
	self.add_to_group("monster")
	if is_rotate:
		$AnimationPlayer.play("rotate")

func _process(_delta):
	if !patrol_path:
		return
	var target = patrol_points[patrol_index]
	if position.distance_to(target) < 1:
		patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
		target = patrol_points[patrol_index]
	velocity = (target - position).normalized() * move_speed
	velocity = move_and_slide(velocity)

func dead():
	if $Sprite:
		$Sprite.queue_free()
	if animation:
		var i=0
		while i<5:
			animation.play("dead")
			yield(animation,"animation_finished")
			i=i+1
	queue_free()

func fire():
	if canFire:
		var bullet = BULLET.instance()
		get_parent().get_parent().add_child(bullet)
		bullet.global_position = $Position2D.global_position
		canFire = false
		$Timer.start()

func _on_PlayerDetect_body_entered(body):
	if body.is_in_group("player"):
		body.dead()
		dead()
	

func _on_Timer_timeout():
	canFire=true



func _on_PlayerDetect_area_entered(area):
	if area.is_in_group("firezone"):
		print("uwu")
		fire()
