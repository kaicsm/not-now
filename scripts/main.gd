extends Node2D

@onready var show_intro = ProjectSettings.get_setting("custom/show_intro", false)
@onready var forest_music = $Audio/Musics/ForestMusic
@onready var rain_music = $Audio/Musics/Rain
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if show_intro:
		fade_in_music(5.0)
		player.can_move = false
		$UI/Intro.show()
	else:
		fade_in_music(0.0)
		# Remove a intro caso o usuario ja tenha visto
		$UI/Intro.queue_free()

	# Sinal que a intro acabou
	$UI/Intro.connect("intro_finished", Callable(self, "_on_intro_finished"))
	

func _on_intro_finished():
	ProjectSettings.set_setting("custom/show_intro", false)
	ProjectSettings.save()
	
	# Cria um novo tween para o fade out
	var tween = create_tween()
	
	# Para cada filho do node Intro
	for child in $UI/Intro.get_children():
		# Faz o fade out da opacidade
		tween.parallel().tween_property(child, "modulate:a", 0.0, 2.0)
	
	# Configura a transição
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	
	# Opcional: remove o node Intro após o fade out
	tween.tween_callback($UI/Intro.queue_free)
	
	# Permitir movimentacao do player depois da intro
	player.can_move = true
	
func fade_in_music(start_delay: int):
	# Configura o volume inicial como 0
	forest_music.volume_db = -80
	rain_music.volume_db = -80
	
	# Inicia a música
	forest_music.play()
	rain_music.play()
	
	# Cria um novo Tween
	var tween = create_tween()
	
	# Configura a transição do volume de -80db para 0db em 2 segundos
	tween.tween_property(forest_music, "volume_db", 0.0, start_delay)
	tween.tween_property(rain_music, "volume_db", 0.0, start_delay)
