function get_commanded_altitude {
	parameter altitude, aircraft_state.
	return get_commanded_altitude_PD(altitude, aircraft_state).
}

local prev_target_altitude to 0.
function get_commanded_altitude_PD {
	parameter altitude, aircraft_state.

	local target_altitude_rate to (altitude - prev_target_altitude) / aircraft_state:TELEMETRY:DT.
	set prev_target_altitude to altitude.

	local altitude_error to altitude - aircraft_state:TELEMETRY:ALTITUDE.
	local target_vspeed to altitude_error * aircraft_state:CONFIG:VSPEED_PER_M.
	local target_vspeed to target_vspeed + target_altitude_rate.
	local target_vspeed to clamp(target_vspeed, -aircraft_state:CONFIG:MAX_VSPEED, aircraft_state:CONFIG:MAX_VSPEED).
	local vspeed_error to target_vspeed - aircraft_state:TELEMETRY:VSPEED.

	local response_f to aircraft_state:CONFIG:PITCH_RESPONSE / (aircraft_state:TELEMETRY:DYNAMIC_PRESSURE * aircraft_state:CONFIG:PITCH_DEPLOY_LIMIT).
	local response to response_f * vspeed_error.

	set aircraft_state:CONFIG:PITCH_TRIM to aircraft_state:CONFIG:PITCH_TRIM + response * aircraft_state:CONFIG:PITCH_TRIM_GAIN * aircraft_state:TELEMETRY:DT.
	set aircraft_state:CONFIG:PITCH_TRIM to clamp(aircraft_state:CONFIG:PITCH_TRIM, -1, 1).

	return aircraft_state:CONFIG:PITCH_TRIM + response.
}