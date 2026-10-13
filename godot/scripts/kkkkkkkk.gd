extends AudioStreamPlayer

@export var tempo_para_ficar_grave: float = 60.0
@export var pitch_final: float = 0.5

var tempo_passado := 0.0

func _ready() -> void:
	pitch_scale = 1.0
	finished.connect(_reiniciar_musica)
	play()

func _process(delta: float) -> void:
	if not playing:
		return

	tempo_passado += delta
	var progresso: float = clamp(tempo_passado / tempo_para_ficar_grave, -1.0, 1.0)

	pitch_scale = lerp(1.0, pitch_final, progresso)

func _reiniciar_musica() -> void:
	tempo_passado = 0.0
	pitch_scale = 1.0
	play()
