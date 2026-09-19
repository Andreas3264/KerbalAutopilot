function get_commanded_roll {
	parameter target_roll, aircraft_state.

	local delta_angle to (target_roll - aircraft_state:TELEMETRY:ROLL_ANGLE).
	
	local response to (aircraft_state:CONFIG:ROLL_RESPONSE * delta_angle) / (aircraft_state:TELEMETRY:DYNAMIC_PRESSURE * aircraft_state:CONFIG:ROLL_DEPLOY_LIMIT).
	local response to clamp(response, -1, 1).

	return response.
}

function get_commanded_heading {
	parameter target_heading, aircraft_state.

	local delta_angle to (mod(target_heading - aircraft_state:TELEMETRY:COMPASS_ANGLE + 180 + 360, 360) - 180).
	
	local target_roll to delta_angle * aircraft_state:CONFIG:ROLL_DEG_PER_DEG.
	local target_roll to clamp(target_roll, -aircraft_state:CONFIG:MAX_ROLL, aircraft_state:CONFIG:MAX_ROLL).

	return get_commanded_roll(target_roll, aircraft_state).
}