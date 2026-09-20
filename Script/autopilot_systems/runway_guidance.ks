
function get_altitude_to_runway {
	parameter runway, aircraft_state.

	local altitude_offset to 6.				// TODO: define magic constants
	local landing_speed to 120.				// TODO: define magic constants
	local grade_min to 1 / landing_speed.			// TODO: define magic constants
	local grade_max to 0.2.					// TODO: define magic constants
	local grade_grade to 0.5 / (landing_speed * landing_speed).// TODO: define magic constants
	local downrang_landing_distance to 300.			// TODO: define magic constants

	local distance_to_runway to get_distance_to_runway(runway, aircraft_state).

	return runway:ALTITUDE + altitude_offset + get_glide_slope_altitude_for_distance(distance_to_runway + downrang_landing_distance, grade_min, grade_max, grade_grade).
}

function get_glide_slope_altitude_for_distance {
	parameter distance, grade_min, grade_max, grade_grade.

	local flare_dist to (grade_max - grade_min) / (grade_grade * 2).
	local alt_at_flare_dist to flare_dist * flare_dist * grade_grade + flare_dist * grade_min.

	local land_alt to distance * grade_min.
	local flare_alt to distance * distance * grade_grade + land_alt.
	local glide_alt to grade_max * (distance - flare_dist) + alt_at_flare_dist.

	if(distance > flare_dist) {
		return glide_alt.
	} else if(distance > 0) {
		return flare_alt.
	} else {
		return land_alt.
	}
}

// target heading for approach to this runway
function get_angle_to_runway {
	parameter runway, aircraft_state.

	local runway_angle to dir_from_to(runway:LAT_START, runway:LNG_START, runway:LAT_END, runway:LNG_END).
	local dist to get_distance_to_runway_center_line(runway, aircraft_state).
	local target_angle to clamp(90 * dist / 10000, -90, 90).		// TODO: define magic constants
	set target_angle to target_angle + clamp(dist / 100, -10, 10).	// TODO: define magic constants
	set target_angle to target_angle + clamp(dist / 20, -1, 1).		// TODO: define magic constants
	return mod((clamp(target_angle, -90, 90) + runway_angle + 360), 360).
}

// signed distance
function get_distance_to_runway {
	parameter runway, aircraft_state.

	local runway_start to cord_to_point(runway:LAT_START, runway:LNG_START, 0).
	local runway_end   to cord_to_point(runway:LAT_END,   runway:LNG_END, 0).
	local runway_len   to (runway_end - runway_start):MAG.
	local ship_pos     to cord_to_point(aircraft_state:TELEMETRY:LATITUDE, aircraft_state:TELEMETRY:LONGITUDE, 0).

	return (runway_end - ship_pos):MAG - runway_len.
}

// left is +, right is -
function get_distance_to_runway_center_line {
	parameter runway, aircraft_state.

	local runway_start to cord_to_point(runway:LAT_START, runway:LNG_START, 0).
	local runway_end   to cord_to_point(runway:LAT_END,   runway:LNG_END,   0).
	local runway_dir   to (runway_end - runway_start):NORMALIZED.
	local runway_up    to (cord_to_point(runway:LAT_START, runway:LNG_START, 100000) - runway_start):NORMALIZED.
	local ship_pos     to cord_to_point(aircraft_state:TELEMETRY:LATITUDE, aircraft_state:TELEMETRY:LONGITUDE, 0).
	local ship_to_runway to (runway_start - ship_pos).
	
	local dist to VDOT(VCRS(runway_dir, ship_to_runway), runway_up).
	return dist.
}

