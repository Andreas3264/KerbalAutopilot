
function get_aircraft_state {
	parameter autopilot_gui.
	local state to lexicon().
	set state["telemetry"] to get_aircraft_telemetry().
	set state["config"] to get_aircraft_config().
	set state["cache"] to get_aircraft_cache(autopilot_gui, state).

	return state.
}

function update_aircraft_state {
	parameter autopilot_gui, aircraft_state.

	// wait for next frame
	local frame_switch_detection to time:seconds.
	until time:seconds > frame_switch_detection { }

	local old_tel to aircraft_state:TELEMETRY.
	local new_tel to get_aircraft_telemetry().
	set aircraft_state:TELEMETRY to new_tel.
	set aircraft_state:CACHE to get_aircraft_cache(autopilot_gui, aircraft_state).

	local dt to new_tel:TIME - old_tel:TIME.

	set aircraft_state:TELEMETRY:DT to dt.

	set aircraft_state:TELEMETRY:ACCELERATION to (new_tel:AIRSPEED - old_tel:AIRSPEED) / dt.
	//set aircraft_state:TELEMETRY:PITCH_ANGLE_RATE to (new_tel:PITCH_ANGLE - old_tel:PITCH_ANGLE) / dt.
	//set aircraft_state:TELEMETRY:PITCH_ANGLE_RATE_RATE to (new_tel:PITCH_ANGLE_RATE - old_tel:PITCH_ANGLE_RATE) / dt.
	set aircraft_state:TELEMETRY:ROLL_ANGLE_RATE to (new_tel:ROLL_ANGLE - old_tel:ROLL_ANGLE) / dt.
}

function get_aircraft_cache {
	parameter autopilot_gui, aircraft_state.

	local cache to lexicon().
	
	local runway to get_runway(gui:runway_select_menu:VALUE).
	set cache["selected_runway"] to runway.
	
	local ship_pos to  cord_to_point(aircraft_state:TELEMETRY:LATITUDE, aircraft_state:TELEMETRY:LONGITUDE, aircraft_state:TELEMETRY:ALTITUDE).
	//set cache["ship_position"] to ship_pos.

	local runway_start to cord_to_point(runway:LAT_START, runway:LNG_START, runway:ALTITUDE).
	//set cache["runway_start"] to runway_start.
	
	local runway_end to cord_to_point(runway:LAT_END, runway:LNG_END, runway:ALTITUDE).
	//set cache["runway_end"] to runway_end.

	local runway_dir to (runway_end - runway_start):NORMALIZED.
	//set cache["runway_dir"] to runway_dir.

	local runway_up to (cord_to_point(runway:LAT_START, runway:LNG_START, 100000) - runway_start):NORMALIZED.
	//set cache["runway_up"] to runway_up.

	local runway_right to VCRS(runway_dir, runway_up). // left handed: (Left X Forward = UP)
	//set cache["runway_right"] to runway_right.

	local ship_to_runway to (runway_start - ship_pos).
	//set cache["ship_to_runway"] to ship_to_runway.

	local ship_to_center_dist to VDOT(runway_right, -ship_to_runway).
	set cache["ship_to_center_dist"] to ship_to_center_dist.

	local ship_to_runway_dist to VDOT(-runway_dir, -ship_to_runway).
	set cache["ship_to_runway_dist"] to ship_to_center_dist.

	return cache.
}

function get_aircraft_config {
	local config to lexicon().

	set config["max_roll"] to 40.

	set config["roll_deploy_limit"] to 5.
	set config["roll_response"] to 0.005.	// response factor
	set config["roll_deg_per_deg"] to 5.	// target roll angle per degree heading error

	set config["max_pitch"] to 10.		// max speed angle
	set config["min_pitch"] to -20.		// min speed angle

	set config["pitch_deploy_limit"] to 23.
	set config["pitch_response"] to 0.2.	// response factor

	set config["vspeed_per_m"] to 0.1.	// target vertical speed per altitude
	set config["max_vspeed"] to 30.		// maximum target vertical speed

	set config["pitch_trim_gain"] to 1.
	set config["pitch_trim"] to 0.
	
	set config["speed_response"] to 1 / 10.

	set config["runway_altitude_offset"] to 6.		// correction for landing altitude
	set config["landing_vspeed"] to 2.		// target vertical speed at touchdown
	set config["landing_grade"] to 0.1.		// grade of the approach
	set config["landing_grade_grade"] to 0.5.		// vertical acceleration of flare
	set config["landing_speed"] to 120.		// target landing speed
	set config["runway_downrange_offset"] to 400.	// distance downrange to touchdown

	return config.
}

function get_aircraft_telemetry {

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
	set state["thrust"] to 0.
	LIST ENGINES IN myVariable.
	for eng in myVariable {
    		set state["thrust"] to state["thrust"] + eng:THRUST.
	}.

	
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