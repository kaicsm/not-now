extends Label

class_name TypewriterLabel

const ERROR_CHARS = ["a", "e", "i", "o", "u", "d", "p"]
const ERROR_DELAY_MIN := 0.2
const ERROR_DELAY_MAX := 0.5

# Configurações exportadas
@export var base_speed := 0.05
@export var speed_variation := 0.02
@export var mistake_chance := 0.05
@export var allow_skip := true  # Permite pular manualmente
@export var dialog_file := "res://dialogs/welcome.json"
@export var end_sequence_delay := 3.0

@onready var character_sound = $"../../../Audio/SoundEffects/CharacterSound"

# Variáveis de controle
var text_to_show := ""
var current_text := ""
var current_char := 0
var is_typing := false
var is_correcting := false
var last_char := ""

# Variáveis para sequência de diálogos
var dialog_sequence := []
var current_sequence_index := 0
var is_sequence_active := false

var timer: Timer

var container_size: Vector2
var initial_position: Vector2

func _ready():
	# Cria e configura o timer
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)

	# Configurações do Label
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Define o tamanho do container e a posição inicial
	container_size = get_parent().size
	initial_position = position

	# Carrega os diálogos
	load_dialogs()

func update_text_position():
	# Atualiza a posição do texto para centralizar na tela
	var text_size = get_minimum_size()
	var new_position = Vector2(
		(container_size.x - text_size.x) * 0.5,
		(container_size.y - text_size.y) * 0.5
	)
	position = new_position

func load_dialogs():
	if FileAccess.file_exists(dialog_file):
		var file = FileAccess.open(dialog_file, FileAccess.READ)
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			dialog_sequence = json.data  # Agora recebe diretamente o array
			is_sequence_active = true
			show_next_dialog()
		file.close()

func show_next_dialog():
	if current_sequence_index < dialog_sequence.size():
		var current_dialog = dialog_sequence[current_sequence_index]
		
		# Aplica a velocidade específica do diálogo
		base_speed = current_dialog["speed"] if current_dialog["speed"] else base_speed
		
		# Aplica o atraso antes de iniciar
		if current_dialog["start_delay"] > 0:
			await get_tree().create_timer(current_dialog["start_delay"]).timeout
		
		start_typing(current_dialog["text"])
		current_sequence_index += 1
	else:
		is_sequence_active = false
		# Delay antes de terminar
		await get_tree().create_timer(end_sequence_delay).timeout
		sequence_finished.emit()

func start_typing(new_text: String):
	text_to_show = new_text
	current_char = 0
	current_text = ""
	is_typing = true
	is_correcting = false
	_start_next_char()

func _start_next_char():
	# Define um tempo aleatório para o próximo caractere
	var random_speed = base_speed + randf_range(-speed_variation, speed_variation)
	timer.start(random_speed)

func _on_timer_timeout():
	if not is_typing:
		return

	if is_correcting:
		# Corrige o erro (remove o último caractere e reinicia a digitação)
		current_text = current_text.left(current_text.length() - 1)
		text = current_text
		update_text_position()
		is_correcting = false
		
		# Pausa do erro  
		var random_delay_error = randf_range(ERROR_DELAY_MIN, ERROR_DELAY_MAX)
		timer.start(random_delay_error)
		return
	else:
		# Adiciona o próximo caractere
		if current_char < text_to_show.length():
			character_sound.play()
			if randf() < mistake_chance and current_char < text_to_show.length() - 1:
				# Adiciona um erro proposital
				var random_error = ERROR_CHARS[randi() % ERROR_CHARS.size()]
				current_text += random_error
				is_correcting = true
				play_character_sound()
					
			else:
				current_text += text_to_show[current_char]
				current_char += 1
				play_character_sound()
				
			text = current_text
			update_text_position()
	timer.start(base_speed)

	if current_char >= text_to_show.length() and not is_correcting:
		finish_typing()

func finish_typing():
	is_typing = false
	timer.stop()
	text = text_to_show
	typing_finished.emit()
	
	# Se não permitir pulo manual, avança automaticamente
	if not allow_skip and is_sequence_active:
		show_next_dialog()

func play_character_sound():
	if character_sound:
		character_sound.pitch_scale = randf_range(0.9, 1.1) # Variação de pitch
		character_sound.play()

signal typing_finished
signal sequence_finished

func _input(event):
	if not allow_skip:  # Se não permitir pular, ignora o input
		return
		
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			finish_typing()
		elif is_sequence_active:
			show_next_dialog()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		container_size = get_parent().size
		update_text_position()

func _on_sequence_finished() -> void:
	pass
