extends GdUnitTestSuite
## Tests du moteur (démarrage, consommation, panne sèche, surchauffe).

const TOLERANCE: float = 0.000001
const HOUR_SECONDS: float = 3600.0


func _create_engine(fuel_liters: float) -> EngineComponent:
	var tank: FuelTankComponent = auto_free(FuelTankComponent.new())
	tank.set_fuel_level(fuel_liters)
	var temperature: EngineTemperatureComponent = auto_free(EngineTemperatureComponent.new())
	temperature.reset_to(90.0)
	var engine: EngineComponent = auto_free(EngineComponent.new())
	engine.fuel_tank = tank
	engine.temperature = temperature
	return engine


func test_cannot_start_with_empty_tank() -> void:
	var engine: EngineComponent = _create_engine(0.0)
	assert_bool(engine.try_start()).is_false()
	assert_bool(engine.is_running).is_false()


func test_starts_with_fuel() -> void:
	var engine: EngineComponent = _create_engine(1.0)
	assert_bool(engine.try_start()).is_true()
	assert_bool(engine.is_running).is_true()


func test_no_power_when_stopped() -> void:
	var engine: EngineComponent = _create_engine(1.0)
	assert_float(engine.get_output_power_kw(1.0)).is_equal_approx(0.0, TOLERANCE)


func test_consumption_matches_hourly_rates() -> void:
	var engine: EngineComponent = _create_engine(1.0)
	var expected: float = engine.idle_consumption_liters_per_hour \
			+ 10.0 * engine.specific_consumption_liters_per_kwh
	assert_float(engine.compute_consumption_liters(HOUR_SECONDS, 10.0)).is_equal_approx(expected, TOLERANCE)


func test_run_step_draws_fuel_from_tank() -> void:
	var engine: EngineComponent = _create_engine(1.0)
	engine.try_start()
	engine.run_step(60.0, 45.0)
	assert_float(engine.fuel_tank.current_liters).is_less(1.0)


func test_stalls_when_tank_runs_dry() -> void:
	var engine: EngineComponent = _create_engine(0.001)
	var stalled_count: Array[int] = [0]
	engine.stalled.connect(func() -> void: stalled_count[0] += 1)
	engine.try_start()
	engine.run_step(60.0, 45.0)
	assert_bool(engine.is_running).is_false()
	assert_int(stalled_count[0]).is_equal(1)


func test_overheat_reduces_output_power() -> void:
	var engine: EngineComponent = _create_engine(1.0)
	engine.try_start()
	var normal_power: float = engine.get_output_power_kw(1.0)
	engine.temperature.reset_to(engine.temperature.critical_celsius)
	assert_float(engine.get_output_power_kw(1.0)).is_less(normal_power)
