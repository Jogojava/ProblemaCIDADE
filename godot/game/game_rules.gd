class_name GameRules
extends RefCounted

# Operational game rules, not empirical claims about municipal administration.
# Values are centralized so balancing can be reviewed without changing UI code.
const TERM_MONTHS := 48
const FINAL_MONTH := 96
const REELECTION_APPROVAL := 50.0
const IMPEACHMENT_APPROVAL := 10.0
const CRISIS_MONTHS := 3
const INITIAL_FUNDS := 220000.0
const MIN_INVESTMENT := 5000.0
const BUILDING_COST := 35000.0
const BUILDING_DAYS := 20
const INITIAL_POPULATION := 8400
const INITIAL_SERVICE_LEVEL := 55.0
const REVENUE_PER_RESIDENT := 14.0
const MONTHLY_BASE_UPKEEP := 106000.0
const BUILDING_UPKEEP := 1000.0
const MONTHLY_SERVICE_DECAY := 0.7
const INVESTMENT_PER_POINT := 7500.0
const EVENT_REWARD_FUNDS := 3000.0
const EVENT_LOSS_FUNDS := 2500.0
const EVENT_REPUTATION := 1.2
const AREAS := ["education", "health", "water", "security", "culture", "social"]
const AREA_NAMES := {
	"education": "Educação", "health": "Saúde", "water": "Saneamento",
	"security": "Segurança", "culture": "Cultura", "social": "Assistência social"
}
const BUILDING_NAMES := {
	"education": "Escola", "health": "Unidade de saúde", "water": "Estação de saneamento",
	"security": "Posto de segurança", "culture": "Centro cultural", "social": "Centro de assistência"
}
const DIFFICULTIES := {
	"easy": {"name": "Fácil", "approval": 60.0, "gain": 1.15, "loss": 0.85, "common": 0, "budget": 1.12},
	"medium": {"name": "Médio", "approval": 52.0, "gain": 0.95, "loss": 1.1, "common": 1, "budget": 1.0},
	"hard": {"name": "Difícil", "approval": 42.0, "gain": 0.75, "loss": 1.3, "common": 1, "budget": 0.9}
}

static func date_index(day: int, month: int, year: int) -> int:
	return (year - 1) * 360 + (month - 1) * 30 + day - 1
