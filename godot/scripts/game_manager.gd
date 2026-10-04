extends Node

@onready var time_manager = $TimeManager
@onready var event_database = $EventDatabase
@onready var event_manager = $EventManager

func _register_test_events() -> void:
	event_database.register_event("teste_comum_01", {
		"title": "Buraco na rua",
		"description": "Moradores pedem solução.",
		"category": "common",
		"interaction_type": "choice",
		"availability_duration_days": 5,
		"payload": {
			"options": [
				{"id": "resolver", "text": "Mandar equipe"},
				{"id": "adiar", "text": "Adiar"}
			]
		}
	})

func _connect_event_signals() -> void:
	event_manager.event_scheduled.connect(_on_event_scheduled)
	event_manager.event_triggered.connect(_on_event_triggered)
	event_manager.event_expired.connect(_on_event_expired)

func _on_event_scheduled(event_id: String, category: String, day: int, month: int, year: int) -> void:
	print("Agendado: ", event_id, " | ", category, " | ", day, "/", month, "/", year)

func _on_event_triggered(runtime_event: Dictionary) -> void:
	print("Disparado: ", runtime_event)

func _on_event_expired(runtime_event: Dictionary) -> void:
	print("Expirado: ", runtime_event)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("event_database: ", event_database)
	print("script: ", event_database.get_script())
	print("tem register_event? ", event_database.has_method("register_event"))
	print("tem build_runtime_event? ", event_database.has_method("build_runtime_event"))
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
