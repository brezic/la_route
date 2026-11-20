extends GdUnitTestSuite
## Tests du réservoir d'essence.

const CAPACITY_LITERS: float = 50.0
const TOLERANCE: float = 0.0001


func _create_tank(level_liters: float) -> FuelTankComponent:
	var tank: FuelTankComponent = auto_free(FuelTankComponent.new())
	tank.capacity_liters = CAPACITY_LITERS
	tank.set_fuel_level(level_liters)
	return tank


func test_set_fuel_level_is_clamped_to_capacity() -> void:
	var tank: FuelTankComponent = _create_tank(CAPACITY_LITERS + 10.0)
	assert_float(tank.current_liters).is_equal_approx(CAPACITY_LITERS, TOLERANCE)


func test_draw_fuel_removes_requested_amount() -> void:
	var tank: FuelTankComponent = _create_tank(10.0)
	var delivered: float = tank.draw_fuel(2.5)
	assert_float(delivered).is_equal_approx(2.5, TOLERANCE)
	assert_float(tank.current_liters).is_equal_approx(7.5, TOLERANCE)


func test_draw_fuel_cannot_deliver_more_than_remaining() -> void:
	var tank: FuelTankComponent = _create_tank(1.0)
	var delivered: float = tank.draw_fuel(3.0)
	assert_float(delivered).is_equal_approx(1.0, TOLERANCE)
	assert_bool(tank.is_empty()).is_true()


func test_draw_fuel_ignores_negative_amount() -> void:
	var tank: FuelTankComponent = _create_tank(5.0)
	assert_float(tank.draw_fuel(-1.0)).is_equal_approx(0.0, TOLERANCE)
	assert_float(tank.current_liters).is_equal_approx(5.0, TOLERANCE)


func test_fuel_depleted_is_emitted_once_when_tank_runs_dry() -> void:
	var tank: FuelTankComponent = _create_tank(1.0)
	var depleted_count: Array[int] = [0]
	tank.fuel_depleted.connect(func() -> void: depleted_count[0] += 1)
	tank.draw_fuel(0.6)
	tank.draw_fuel(0.6)
	tank.draw_fuel(0.6)
	assert_int(depleted_count[0]).is_equal(1)


func test_fill_ratio() -> void:
	var tank: FuelTankComponent = _create_tank(CAPACITY_LITERS / 4.0)
	assert_float(tank.get_fill_ratio()).is_equal_approx(0.25, TOLERANCE)
