extends GdUnitTestSuite
## Tests de la thermique moteur.

const AMBIENT_CELSIUS: float = 20.0
const STEP_SECONDS: float = 1.0 / 120.0
const TOLERANCE: float = 0.01


func _create_temperature(start_celsius: float) -> EngineTemperatureComponent:
	var temperature: EngineTemperatureComponent = auto_free(EngineTemperatureComponent.new())
	temperature.reset_to(start_celsius)
	return temperature


func _simulate_for(temperature: EngineTemperatureComponent, seconds: float, power_kw: float,
		is_running: bool, airspeed_mps: float) -> void:
	var steps: int = roundi(seconds / STEP_SECONDS)
	for step in steps:
		temperature.simulate(STEP_SECONDS, power_kw, is_running, AMBIENT_CELSIUS, airspeed_mps)


func test_engine_off_at_ambient_stays_at_ambient() -> void:
	var temperature: EngineTemperatureComponent = _create_temperature(AMBIENT_CELSIUS)
	_simulate_for(temperature, 60.0, 0.0, false, 0.0)
	assert_float(temperature.current_celsius).is_equal_approx(AMBIENT_CELSIUS, TOLERANCE)


func test_engine_heats_up_under_load() -> void:
	var temperature: EngineTemperatureComponent = _create_temperature(AMBIENT_CELSIUS)
	_simulate_for(temperature, 40.0, 45.0, true, 10.0)
	assert_float(temperature.current_celsius).is_greater(80.0)


func test_engine_off_cools_down_towards_ambient() -> void:
	var temperature: EngineTemperatureComponent = _create_temperature(95.0)
	_simulate_for(temperature, 120.0, 0.0, false, 0.0)
	assert_float(temperature.current_celsius).is_less(95.0)
	assert_float(temperature.current_celsius).is_greater(AMBIENT_CELSIUS)


func test_cruise_stays_in_normal_range() -> void:
	# Croisière à 90 km/h environ : 10 kW pour 25 m/s.
	var temperature: EngineTemperatureComponent = _create_temperature(90.0)
	_simulate_for(temperature, 600.0, 10.0, true, 25.0)
	assert_float(temperature.current_celsius).is_between(88.0, 100.0)
	assert_bool(temperature.is_overheating).is_false()


func test_full_load_overheats() -> void:
	var temperature: EngineTemperatureComponent = _create_temperature(90.0)
	_simulate_for(temperature, 120.0, 45.0, true, 30.0)
	assert_bool(temperature.is_overheating).is_true()
	assert_float(temperature.get_power_factor()).is_less(1.0)


func test_overheat_warning_uses_hysteresis() -> void:
	var temperature: EngineTemperatureComponent = _create_temperature(112.0)
	assert_bool(temperature.is_overheating).is_true()
	temperature.reset_to(107.0)
	assert_bool(temperature.is_overheating).is_true()
	temperature.reset_to(104.0)
	assert_bool(temperature.is_overheating).is_false()


func test_power_factor_bounds() -> void:
	var temperature: EngineTemperatureComponent = _create_temperature(90.0)
	assert_float(temperature.get_power_factor()).is_equal_approx(1.0, TOLERANCE)
	temperature.reset_to(temperature.critical_celsius + 20.0)
	assert_float(temperature.get_power_factor()).is_equal_approx(temperature.min_power_factor, TOLERANCE)
