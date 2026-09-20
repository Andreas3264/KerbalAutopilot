
function get_aircraft_state {
	local state to lexicon().
	set state["telemetry"] to get_aircraft_telemetry().
	set state["config"] to get_aircraft_config().

	return state.
}

function update_aircraft_state {
	parameter aircraft_state.

	local old_tel to aircraft_state:TELEMETRY.
	local new_tel to get_aircraft_telemetry().
	set aircraft_state:TELEMETRY to new_tel.

	local dt to new_tel:TIME - old_tel:TIME.

	set aircraft_state:TELEMETRY:DT to dt.

	set aircraft_state:TELEMETRY:ACCELERATION to (new_tel:AIRSPEED - old_tel:AIRSPEED) / dt.
	//set aircraft_state:TELEMETRY:PITCH_ANGLE_RATE to (new_tel:PITCH_ANGLE - old_tel:PITCH_ANGLE) / dt.
	//set aircraft_state:TELEMETRY:PITCH_ANGLE_RATE_RATE to (new_tel:PITCH_ANGLE_RATE - old_tel:PITCH_ANGLE_RATE) / dt.
	set aircraft_state:TELEMETRY:ROLL_ANGLE_RATE to (new_tel:ROLL_ANGLE - old_tel:ROLL_ANGLE) / dt.
}

function get_aircraft_config {
	local config to lexicon().

	set config["max_roll"] to 40.

	set config["roll_deploy_limit"] to 5.
	set config["roll_response"] to 0.005.	// response factor
	set config["roll_deg_per_deg"] to 5.	// target roll angle per degree heading error

	//set config["max_pitch"] to 25.		// unused
	//set config["min_pitch"] to -25.		// unused

	set config["pitch_deploy_limit"] to 23.
	set config["pitch_response"] to 0.2.	// response factor

	set config["vspeed_per_m"] to 0.1.	// target vertical speed per altitude
	set config["max_vspeed"] to 30.		// maximum target vertical speed

	set config["pitch_trim_gain"] to 0.1.
	set config["pitch_trim"] to 0.
	
	set config["speed_response"] to 1 / 10.

	return config.
}

function get_aircraft_telemetry {

	// wait for next frame
	local frame_switch_detection to time:seconds.
	until time:seconds > frame_switch_detection { }	

	local state to lexicon().

	set state["time"] to time:seconds.
	set state["dt"] to 0.

	set state["altitude"] to SHIP:ALTITUDE.
	set state["radar_altitude"] to ALT:RADAR.	

	set state["latitude"] to SHIP:GEOPOSITION:LAT.
	set state["longitude"] to SHIP:GEOPOSITION:LNG.

	set state["dynamic_pressure"] to SHIP:DYNAMICPRESSURE.

	set state["airspeed"] to SHIP:AIRSPEED.
	set state["acceleration"] to 0.
	set state["VSPEED"] to SHIP:VERTICALSPEED.
	set state["HSPEED"] to SHIP:GROUNDSPEED.

	//TODO: make mass independant
	//set state["thrust"] to 0.
	//LIST ENGINES IN myVariable.
	//for eng in myVariable {
    	//	set state["thrust"] to state["thrust"] + eng:THRUST.
	//}.

	
	set state["pitch_angle"] to (90 - vectorangle(UP:FOREVECTOR, FACING:FOREVECTOR)).
	//set state["pitch_angle_rate"] to 0.		// unused
	//set state["pitch_angle_rate_rate"] to 0.		// unused

	local velocity_direction to SHIP:VELOCITY:SURFACE:NORMALIZED.
	local ship_up to SHIP:FACING:TOPVECTOR:NORMALIZED.

	set state["angle_of_attack"] to ARCCOS(VDOT(velocity_direction, ship_up)) - 90.


	set state["compass_angle"] to compass_angle().

	
	set state["roll_angle"] to (-90 + vectorangle(UP:FOREVECTOR, FACING:STARVECTOR)).
	set state["roll_angle_rate"] to 0.	


	// fuel consumption

	return state.
}

function compass_angle {

 	//local pointing is ship:facing:forevector.
	local pointing is SHIP:VELOCITY:SURFACE:NORMALIZED.
	local east is vcrs(ship:up:vector, ship:north:vector).
	local trig_x is vdot(ship:north:vector, pointing).
	local trig_y is vdot(east, pointing).
	local result is arctan2(trig_y, trig_x).
	
	if result < 0 {
		return 360 + result.
	} else {
		return result.
	}
}