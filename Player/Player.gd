extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const ACCELERATION = 500
const MAX_SPEED = 100
const ROLL_SPEED = 150
const FRICTION = 500

enum { MOVE, ROLL, ATTACK }

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
# onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitBoxPivot/SwordHitBox

# Called when the node enters the scene tree for the first time.
func _ready():
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)
	
func move_state(delta):	
	# TODO: Fix jitter and stutter:
	# https://docs.godotengine.org/uk/latest/tutorials/misc/jitter_stutter.html
	# https://youtu.be/EQA9MJ5_TxU?t=922
	
	# delta is time spent to calculate frame
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength(("ui_right")) - Input.get_action_strength(("ui_left"))
	input_vector.y = Input.get_action_strength(("ui_down")) - Input.get_action_strength(("ui_up"))
	
	# https://www.youtube.com/watch?v=EQA9MJ5_TxU
	# normalized()
	# Returns the vector scaled to unit length. Equivalent to v / v.length().
	input_vector = input_vector.normalized()	
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func move():
	velocity = move_and_slide(velocity)

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func roll_animation_finished():
	velocity = roll_vector * MAX_SPEED
	state = MOVE
	
func attack_animation_finished():
	state = MOVE
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
