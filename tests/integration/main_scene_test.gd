extends GdUnitTestSuite
## Tests d'intégration sur la scène principale : physique du véhicule, conduite et interaction.

const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"
const SETTLE_MILLISECONDS: int = 2000
const DRIVE_MILLISECONDS: int = 5000

var _runner: GdUnitSceneRunner


func before_test() -> void:
	_runner = scene_runner(MAIN_SCENE_PATH)


func _car() -> VehicleController:
	return _runner.find_child("Car") as VehicleController


func _player() -> PlayerController:
	return _runner.find_child("Player") as PlayerController


func test_road_is_about_one_kilometer_long() -> void:
	var road: RoadBuilder = _runner.find_child("Road") as RoadBuilder
	assert_float(road.get_length_m()).is_between(1000.0, 1100.0)


func test_car_settles_on_its_four_wheels() -> void:
	await await_millis(SETTLE_MILLISECONDS)
	var car: VehicleController = _car()
	assert_float(car.linear_velocity.length()).is_less(0.2)
	assert_float(car.global_position.y).is_between(-0.4, 0.2)
	for wheel in car.find_children("*", "RaycastWheel", false, false):
		assert_bool((wheel as RaycastWheel).is_grounded).is_true()


func test_car_drives_forward_and_burns_fuel() -> void:
	await await_millis(SETTLE_MILLISECONDS)
	var car: VehicleController = _car()
	var tank: FuelTankComponent = car.get_node("FuelTank") as FuelTankComponent
	var fuel_before: float = tank.current_liters
	car.get_node("DoorArea").interact(_player())
	_runner.simulate_action_press("vehicle_accelerate")
	await await_millis(DRIVE_MILLISECONDS)
	_runner.simulate_action_release("vehicle_accelerate")
	assert_bool((car.get_node("Engine") as EngineComponent).is_running).is_true()
	assert_float(car.get_forward_speed_mps()).is_greater(10.0)
	assert_float(tank.current_liters).is_less(fuel_before)
	assert_float(absf(car.rotation.z)).is_less(0.2)


func test_player_gets_in_and_out_of_the_car() -> void:
	await await_millis(SETTLE_MILLISECONDS)
	var car: VehicleController = _car()
	var player: PlayerController = _player()
	var seat: DriverSeat = car.get_node("DriverSeat") as DriverSeat
	car.get_node("DoorArea").interact(player)
	assert_bool(seat.is_occupied()).is_true()
	assert_bool(player.visible).is_false()
	_runner.simulate_action_pressed("interact")
	await _runner.await_input_processed()
	assert_bool(seat.is_occupied()).is_false()
	assert_bool(player.visible).is_true()
	assert_float(player.global_position.distance_to(car.global_position)).is_less(3.0)
