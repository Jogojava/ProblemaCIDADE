class_name GameRules
extends RefCounted

# Operational game rules, not empirical claims about municipal administration.
# Values are centralized so balancing can be reviewed without changing UI code.
const TERM_MONTHS := 48
const FINAL_MONTH := 96
const REELECTION_APPROVAL := 50.0
const IMPEACHMENT_APPROVAL := 10.0
const CRISIS_MONTHS := 3
const INITIAL_FUNDS := 250000.0
const MIN_INVESTMENT := 5000.0
const BUILDING_COST := 35000.0
const BUILDING_DAYS := 20
const INITIAL_POPULATION := 10000
const INITIAL_SERVICE_LEVEL := 55.0
const REVENUE_PER_RESIDENT := 7.5
const DEFAULT_DAILY_TAX := REVENUE_PER_RESIDENT / 30.0
const MAX_DAILY_TAX := 0.5
const MONTHLY_BASE_UPKEEP := 69000.0
const BUILDING_UPKEEP := 1400.0
const EXTRA_RESIDENT_UPKEEP := 9.0
const SERVICE_UPKEEP_PER_POINT := 60.0
const HOME_COST := 6000.0
const TAX_COLLECTION_SLOPE := 3.0
const TAX_PRESSURE_PER_UNIT := 30.0
const MONTHLY_SERVICE_DECAY := 0.5
const INVESTMENT_PER_POINT := 3000.0
const EVENT_REWARD_FUNDS := 1500.0
const EVENT_LOSS_FUNDS := 2000.0
const EVENT_REPUTATION := 1.5
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
	"easy": {"name": "Fácil", "approval": 65.0, "gain": 1.25, "loss": 0.75, "common": 1, "budget": 1.15},
	"medium": {"name": "Médio", "approval": 55.0, "gain": 1.0, "loss": 1.0, "common": 2, "budget": 1.0},
	"hard": {"name": "Difícil", "approval": 45.0, "gain": 0.8, "loss": 1.2, "common": 3, "budget": 0.9}
}

static func date_index(day: int, month: int, year: int) -> int:
	return (year - 1) * 360 + (month - 1) * 30 + day - 1
