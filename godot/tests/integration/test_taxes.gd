extends SceneTree
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		print("FAIL: ", message)
func _initialize() -> void:
	var city := CityState.new()
	city.start("Tributos", "medium")
	check(is_equal_approx(city.daily_tax_revenue(), 2500.0), "Arrecadacao inicial diaria.")
	var initial := city.funds
	city.advance_day(1)
	check(city.funds == initial + 2500, "Primeiro dia credita imposto.")
	city.advance_day(1)
	city.advance_day(0)
	check(city.funds == initial + 2500, "Dias repetidos ou anteriores nao duplicam receita.")
	city.advance_day(30)
	check(city.funds == initial + 75000, "Trinta dias acumulam a receita diaria prevista.")
	city.advance_month()
	check(city.funds == initial + 75000 - GameRules.MONTHLY_BASE_UPKEEP, "Mes desconta despesas sem duplicar receita.")
	city.set_daily_tax(0.5)
	check(city.daily_tax_revenue() == snappedf(city.population * 0.5 * city.tax_efficiency(0.5), 0.01), "Imposto acompanha populacao e taxa.")
	var saved := city.get_save_data()
	var restored := CityState.new()
	restored.load_save_data(JSON.parse_string(JSON.stringify(saved)))
	check(restored.daily_tax == 0.5, "Taxa persiste em save JSON.")
	var money := restored.funds
	restored.advance_day(30)
	check(restored.funds == money, "Carregar nao recolhe o mesmo dia de novo.")
	restored.advance_day(31)
	check(restored.funds == money + restored.daily_tax_revenue(), "Dia seguinte ao save arrecada normalmente.")
	city.set_daily_tax(0)
	money = city.funds
	city.advance_day(31)
	check(city.funds == money, "Isencao zera receita.")
	city.set_daily_tax(999)
	check(city.daily_tax == GameRules.MAX_DAILY_TAX, "Limite superior aplicado.")
	city.set_daily_tax(-10)
	check(city.daily_tax == 0, "Limite inferior aplicado.")
	city.set_daily_tax(NAN)
	check(city.daily_tax == 0, "Taxa nao finita rejeitada.")
	city.outcome = "completed"
	money = city.funds
	city.advance_day(50)
	city.set_daily_tax(0.9)
	check(city.funds == money and city.daily_tax == 0, "Fim de campanha interrompe arrecadacao e alteracao.")
	var legacy := CityState.new()
	legacy.load_save_data({"last_day": 10})
	check(legacy.daily_tax == GameRules.DEFAULT_DAILY_TAX, "Save antigo recebe taxa padrao.")
	for level in GameRules.DIFFICULTIES:
		legacy.start("Teste", level)
		check(legacy.daily_tax_revenue() == snappedf(2500 * float(legacy.profile().budget), 0.01), "Dificuldade ajusta arrecadacao.")
	print("Impostos: %d verificacoes, %d falhas. END" % [checks, failures])
	quit(0 if failures == 0 else 1)
