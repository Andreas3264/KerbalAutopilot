function get_commanded_heading {
	parameter target_heading, aircraft_state.

	local CONFIG to aircraft_state:CONFIG.
	local TELEMETRY to aircraft_state:TELEMETRY.

	local delta_angle to (mod(target_heading - TELEMETRY:COMPASS_ANGLE + 180 + 360, 360) - 180).
	
	local target_roll to delta_angle * CONFIG:ROLL_DEG_PER_DEG.
	local target_roll to clamp(target_roll, -CONFIG:MAX_ROLL, CONFIG:MAX_ROLL).

	local delta_angle to (target_roll - TELEMETRY:ROLL_ANGLE).
	
	local response to (CONFIG:ROLL_RESPONSE * delta_angle) / (TELEMETRY:DYNAMIC_PRESSURE * CONFIG:ROLL_DEPLOY_LIMIT).
	local response to clamp(response, -1, 1).

	return response.
}

function get_commanded_roll_UNUSED {
	parameter target_roll, aircraft_state.

	local CONFIG to aircraft_state:CONFIG.
	local TELEMETRY to aircraft_state:TELEMETRY.

	local delta_angle to (target_roll - TELEMETRY:ROLL_ANGLE).
	
	local response to (CONFIG:ROLL_RESPONSE * delta_angle) / (TELEMETRY:DYNAMIC_PRESSURE * CONFIG:ROLL_DEPLOY_LIMIT).
	local response to clamp(response, -1, 1).

	return response.
}