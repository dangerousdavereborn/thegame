extends KinematicBody2D

export var gravity=7
export var speed=50
export var runspeed=100
export var maxgravity=70
var height=14
export var hasClass = false
var velocity = Vector2.ZERO
var isLife = true
var canFire = true
var inTree = false
onready var raycast = $RayCast2D
onready var animation = $Sprite
onready var globals = get_node("/root/Globals")
const BULLET = preload("res://object/Bullet.tscn")

func _ready():
	self.add_to_group("player")

func _physics_process(delta):
	if isLife:
		velocity = move_and_slide(velocity)
		if Input.is_action_just_pressed("jetpack") and globals.hasJetpack:
			globals.jetpackIsActive = !globals.jetpackIsActive
		if globals.jetpackIsActive:
			animation.play("jetpack")
			jetpack_move(delta)
		if inTree:
			climb(delta)
		else:
			move(delta)
		if Input.is_action_just_pressed("fire") and globals.hasGun and canFire:
			var bullet = BULLET.instance()
			get_parent().add_child(bullet)
			bullet.position = get_node("Position2D").global_position
			canFire = false
			$Timer.start()
		velocity = move_and_slide(velocity)
	else:
		print("Death")

func jetpack_move(delta):
	if Input.is_action_pressed("jump"):
		velocity.y = -speed*delta*runspeed
		animation.play("jetpack")
	elif Input.is_action_pressed("ui_down"):
		velocity.y = speed*delta*runspeed
		animation.play("jetpack")
	elif Input.is_action_pressed("left"):
		velocity.x=-speed*delta*runspeed
		animation.play("jetpack")
		animation.flip_h=true
	elif Input.is_action_pressed("right"):
		velocity.x=+speed*delta*runspeed
		animation.play("jetpack")
		animation.flip_h=false
	else:
		velocity.y = 0
		velocity.x = 0

func move(delta):
	velocity.y+=gravity*delta*speed
	if velocity.y>maxgravity:
		velocity.y=maxgravity
	if Input.is_action_pressed("jump") and raycast.is_colliding():
		velocity.y-=speed*delta*gravity*height
	if Input.is_action_pressed("left"):
		velocity.x=-speed*delta*runspeed
		animation.flip_h=true
		animation.play("walk")
	elif Input.is_action_pressed("right"):
		velocity.x=+speed*delta*runspeed
		animation.flip_h=false
		animation.play("walk")
	else:
		velocity.x=0
		animation.play("stop")
		
	if not raycast.is_colliding():
		animation.play("jump")

func climb(delta):
	if Input.is_action_pressed("jump"):
		velocity.y = -speed*delta*runspeed
		if !raycast.is_colliding():animation.play("climb")
	elif Input.is_action_pressed("ui_down"):
		velocity.y = speed*delta*runspeed
		if !raycast.is_colliding():animation.play("climb")
	elif Input.is_action_pressed("left"):
		velocity.x=-speed*delta*runspeed
		if !raycast.is_colliding():animation.play("climb")
	elif Input.is_action_pressed("right"):
		velocity.x=+speed*delta*runspeed
		if !raycast.is_colliding():animation.play("climb")
	else:
		velocity.y = 0
		velocity.x = 0
		animation.stop()

func _on_Area2D_area_entered(area):
	if area.is_in_group("hit"):
		globals.healt -= 1
		if globals.healt == 0:
			isLife = false
		else:
			get_tree().reload_current_scene()
	
	if area.is_in_group("tree"):
		inTree = true

func _on_Area2D_area_exited(area):
	if area.is_in_group("tree"):
		inTree = false

func _on_Timer_timeout():
	canFire = true
