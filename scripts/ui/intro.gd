extends Control

# Referência ao TypewriterLabel
@onready var typewriter_label = $WelcomeLabel  # Certifique-se de que o nome do nó seja exatamente "Label"

# Sinais
signal intro_finished

func _ready():
	# Conecta os sinais do TypewriterLabel para saber quando o texto termina
	typewriter_label.connect("sequence_finished", Callable(self, "_on_sequence_finished"))

func _on_sequence_finished():
	# Quando a sequência de diálogos terminar, envia um sinal para o `Main`
	emit_signal("intro_finished")
