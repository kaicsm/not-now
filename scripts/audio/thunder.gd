extends AudioStreamPlayer

var rng = RandomNumberGenerator.new()

@onready var timer = $Timer
var thunder_chance = 0.3  # Chance de 30% para o trovão tocar

func _ready():
	# Adiciona o temporizador como filho do AudioStreamPlayer
	add_child(timer)
	# Conecta o sinal "timeout" do temporizador à função _on_timer_timeout
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	# Define o intervalo fixo para verificar a chance do trovão (20 segundos)
	timer.wait_time = 20.0
	timer.start()
	
func _on_timer_timeout():
	# Checa se o trovão deve tocar com base na chance
	if rng.randf() < thunder_chance:
		# Ajusta o volume aleatoriamente para simular distância
		var volume = rng.randf_range(-10.0, 0.0)  # Volume entre -10dB e 0dB
		volume_db = volume
		# Ajusta o pitch aleatoriamente para simular variações
		pitch_scale = rng.randf_range(0.9, 1.1)
		# Toca o som de trovão
		play()
