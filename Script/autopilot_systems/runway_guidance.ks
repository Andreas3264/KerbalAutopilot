
function get_altitude_to_runway {
	parameter runway, aircraft_state.

	local distance_to_runway to get_distance_to_runway(runway, aircraft_state).

	return 	runway:ALTITUDE + 
		aircraft_state:CONFIG:RUNWAY_ALTITUDE_OFFSET + 
		get_glide_slope_altitude_for_distance(
			distance_to_runway + aircraft_state:CONFIG:RUNWAY_DOWNRANGE_OFFSET,
			aircraft_state:CONFIG:LANDING_VSPEED / aircraft_state:CONFIG:LANDING_SPEED,
			aircraft_state:CONFIG:LANDING_GRADE,
			aircraft_state:CONFIG:LANDING_GRADE_GRADE / (aircraft_state:CONFIG:LANDING_SPEED * aircraft_state:CONFIG:LANDING_SPEED)).
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

// target speed for approach to this runway
function get_speed_to_runway {
	parameter runway, aircraft_state.
	return aircraft_state:CONFIG:LANDING_SPEED
		+ (get_distance_to_runway(runway, aircraft_state) - aircraft_state:CONFIG:FINAL_DISTANCE) * 0.002.
}

// target heading for approach to this runway
function get_angle_to_runway {
	parameter runway, aircraft_state.

	local dist to get_distance_to_runway(runway, aircraft_state).
	local dist_c to get_distance_to_runway_center_line(runway, aircraft_state).
	if(abs(dist_c) < aircraft_state:CONFIG:FINAL_TURN_RADIUS 
		and dist < (aircraft_state:CONFIG:FINAL_TURN_RADIUS + aircraft_state:CONFIG:FINAL_DISTANCE)) {
		local target_angle to clamp(90 * dist_c / aircraft_state:CONFIG:FINAL_TURN_RADIUS, -90, 90).
		set target_angle to target_angle + clamp(dist_c / 100, -10, 10).		// TODO: define magic constants
		set target_angle to target_angle + clamp(dist_c / 20, -1, 1).		// TODO: define magic constants
		return mod((clamp(target_angle, -90, 90) + runway:ANGLE + 360), 360).
	} else {
		return aircraft_state:CACHE:DIR_TO_FINAL.
	}
}

// signed distance
function get_distance_to_runway {
	parameter runway, aircraft_state.
	return aircraft_state:CACHE:SHIP_TO_RUNWAY_DIST.
}

// left is +, right is -
function get_distance_to_runway_center_line {
	parameter runway, aircraft_state.
	return aircraft_state:CACHE:SHIP_TO_CENTER_DIST.
}

