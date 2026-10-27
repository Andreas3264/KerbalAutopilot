local prev_target_altitude to 0.
function get_commanded_altitude {
	parameter altitude, aircraft_state.
	
	local CONFIG to aircraft_state:CONFIG.
	local TELEMETRY to aircraft_state:TELEMETRY.

	local target_altitude_rate to (altitude - prev_target_altitude) / TELEMETRY:DT.
	set prev_target_altitude to altitude.

	local altitude_error to altitude - TELEMETRY:ALTITUDE.
	local target_vspeed to altitude_error * CONFIG:VSPEED_PER_M.
	local target_vspeed to target_vspeed + target_altitude_rate.
	local target_vspeed to clamp(target_vspeed, -CONFIG:MAX_VSPEED, CONFIG:MAX_VSPEED).

	local vspeed_max to sin(CONFIG:MAX_PITCH) * TELEMETRY:AIRSPEED.
	local vspeed_min to sin(CONFIG:MIN_PITCH) * TELEMETRY:AIRSPEED.

	local target_vspeed to clamp(target_vspeed, vspeed_min, vspeed_max).

	local vspeed_error to target_vspeed - TELEMETRY:VSPEED.
	local response_f to CONFIG:PITCH_RESPONSE / (TELEMETRY:DYNAMIC_PRESSURE * CONFIG:PITCH_DEPLOY_LIMIT).
	local response to response_f * vspeed_error.

	set CONFIG:PITCH_TRIM to CONFIG:PITCH_TRIM + response * CONFIG:PITCH_TRIM_GAIN * TELEMETRY:DT.
	set CONFIG:PITCH_TRIM to clamp(CONFIG:PITCH_TRIM, -1, 1).

	return CONFIG:PITCH_TRIM + response.
}