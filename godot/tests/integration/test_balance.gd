extends SceneTree
var failures := 0
func _initialize() -> void:
	for policy in ["moderate", "maximum", "zero"]:
		var city := CityState.new()
		city.start("Simulacao", "medium")
		city.set_daily_tax({"moderate": 0.25, "maximum": 0.5, "zero": 0.0}[policy])
		var map := CityVisuals.new()
		map.bind(city)
		for month in range(96):
			if city.outcome != "playing": break
			if policy == "moderate":
				var weakest := "education"
				for area in GameRules.AREAS:
					if city.indicators[area] < city.indicators[weakest]: weakest = area
				if city.funds >= 25000: city.invest(weakest, 6000)
				for lot in map.lots:
					if city.housing_requests() <= 0: break
					if city.can_build(lot): city.place_home(lot)
				city.apply_problem({"category": "common"}, true)
			for day in range(30): city.advance_day(month * 30 + day + 1)
			city.advance_month()
		print("POLICY %s month=%d funds=%.0f reputation=%.1f population=%d outcome=%s" % [policy, city.completed_months, city.funds, city.reputation, city.population, city.outcome])
		if policy == "moderate" and city.outcome != "completed": failures += 1
		if policy != "moderate" and city.outcome == "completed": failures += 1
		map.free()
	var city := CityState.new()
	city.start("Teste", "medium")
	if city.daily_tax_revenue(0.5) >= city.daily_tax_revenue(0.25): failures += 1
	city.set_daily_tax(0.5)
	city.advance_day(29)
	city.set_daily_tax(0.25)
	city.advance_day(30)
	city.advance_month()
	if city.reputation > 50: failures += 1
	print("Balanceamento: %d falhas. END" % failures)
	quit(0 if failures == 0 else 1)
