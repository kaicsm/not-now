extends CharacterBody2D

const SPEED = 200.0
const GRAVITY = 980.0  # Valor da gravidade (ajuste conforme necessário)

@export var can_move = true

@onready var animation = $Animation

func _physics_process(delta: float) -> void:
	# Adiciona gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction and can_move:
		velocity.x = direction * SPEED
		# Só muda para animação de andar se estiver no chão
		if is_on_floor():
			animation.play("walking")
		animation.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		# Só volta para idle se estiver no chão e parado
		if is_on_floor():
			animation.play("idle")
	
	move_and_slide()
