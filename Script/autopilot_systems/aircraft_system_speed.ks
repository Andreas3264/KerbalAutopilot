
function get_commanded_speed {
	parameter target_speed, aircraft_state.

	local delta_speed to (target_speed-aircraft_state:TELEMETRY:AIRSPEED).
	
	local response to (aircraft_state:CONFIG:SPEED_RESPONSE * delta_speed).
	local response to clamp(response, -1, 1).

	return response.
}