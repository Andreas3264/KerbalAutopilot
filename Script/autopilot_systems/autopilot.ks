runoncepath("0:/autopilot_systems/includes.ks").

set display_string to "".
clearguis().
clearscreen.

local autopilot_gui to get_autopilot_gui().
local aircraft_state to get_aircraft_state(autopilot_gui).

local runway_vec to VECDRAW(V(0,0,0),V(0,0,0),RGB(0,1,0),"",1.0,FALSE,0.2,TRUE,FALSE).
local flare_vec  to VECDRAW(V(0,0,0),V(0,0,0),RGB(1,1,0),"",1.0,FALSE,0.2,FALSE,FALSE).
local glide_vec  to VECDRAW(V(0,0,0),V(0,0,0),RGB(0,0,1),"",1.0,FALSE,0.2,FALSE,FALSE).
local glide_low_vec  to VECDRAW(V(0,0,0),V(0,0,0),RGB(0,0,1),"",1.0,FALSE,0.2,FALSE,FALSE).
local final_vec to VECDRAW(V(0,0,0),V(0,0,0),RGB(0,1,1),"",1.0,FALSE,0.2,TRUE,FALSE).

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

set CONFIG:IPU to 2000.

until false {
	autopilot_loop().

	//prevents gui from being removed
	set main_gui to autopilot_gui:GUIROOT.

	clearscreen.
	print display_string.
	set display_string to "".
}

function autopilot_loop {
	update_aircraft_state(autopilot_gui, aircraft_state).

	handle_gui_pitch(autopilot_gui, aircraft_state).
	handle_gui_heading(autopilot_gui, aircraft_state).
	handle_gui_speed(autopilot_gui, aircraft_state).
	handle_gui_systems(autopilot_gui, aircraft_state).

	show_runway_debug(autopilot_gui, aircraft_state).
	terminal_debug_print(autopilot_gui, aircraft_state).
}

function show_runway_debug {
	parameter gui, aircraft_state.

	if(not gui:visual_debug_button:PRESSED){
		set runway_vec:SHOW to false.
		set flare_vec:SHOW to false.
		set glide_vec:SHOW to false.
		set glide_low_vec:SHOW to false.
		set final_vec:SHOW to false.
		return.
	}

	local runway to get_runway(gui:runway_select_menu:VALUE).

	local runway_start to cord_to_point(runway:LAT_START, runway:LNG_START, runway:ALTITUDE + aircraft_state:CONFIG:RUNWAY_ALTITUDE_OFFSET).
	local runway_end   to cord_to_point(runway:LAT_END,   runway:LNG_END,   runway:ALTITUDE + aircraft_state:CONFIG:RUNWAY_ALTITUDE_OFFSET).
	local runway_dir   to (runway_end - runway_start):NORMALIZED.
	local runway_up    to (cord_to_point(runway:LAT_START, runway:LNG_START, 100000) - runway_start):NORMALIZED.

	set runway_vec:SHOW to TRUE.
	set runway_vec:START to runway_start.
	set runway_vec:VEC to runway_end - runway_start.

	local grade_min to aircraft_state:CONFIG:LANDING_VSPEED / aircraft_state:CONFIG:LANDING_SPEED.
	local grade_max to aircraft_state:CONFIG:LANDING_GRADE.
	local grade_grade to aircraft_state:CONFIG:LANDING_GRADE_GRADE / (aircraft_state:CONFIG:LANDING_SPEED * aircraft_state:CONFIG:LANDING_SPEED).

	local flare_dist to ((grade_max - grade_min) / (grade_grade * 2)).
	local alt_at_flare_dist to flare_dist * flare_dist * grade_grade + flare_dist * grade_min.

	local flare_start to runway_start + runway_up * alt_at_flare_dist - runway_dir * (flare_dist - aircraft_state:CONFIG:RUNWAY_DOWNRANGE_OFFSET).
	local flare_end to runway_start + runway_dir*aircraft_state:CONFIG:RUNWAY_DOWNRANGE_OFFSET.

	set flare_vec:SHOW to TRUE.
	set flare_vec:START to flare_start.
	set flare_vec:VEC to flare_end - flare_start.

	local glide_start_distance to 10000.
	local glide_start to flare_start // will always be too high due to round planet
			- runway_dir * glide_start_distance
			+  runway_up * (grade_max * glide_start_distance).

	local glide_start_low to flare_start 
			- runway_dir * glide_start_distance
			+  runway_up * ((grade_max - 0.02) * glide_start_distance).

	local glide_end to flare_start.

	set glide_vec:SHOW to TRUE.
	set glide_vec:START to glide_start.
	set glide_vec:VEC to glide_end - glide_start.

	set glide_low_vec:SHOW to TRUE.
	set glide_low_vec:START to glide_start_low.
	set glide_low_vec:VEC to glide_end - glide_start_low.

	set final_vec:SHOW to TRUE.
	set final_vec:START to aircraft_state:CACHE:SHIP_POSITION.
	set final_vec:VEC to aircraft_state:CACHE:SHIP_TO_FINAL_POINT.
}

function terminal_debug_print {
	parameter gui, aircraft_state.

	set display_string to display_string
	+ "dt  " + round(aircraft_state:TELEMETRY:DT, 3) + char(10)
	+ "ins " + round((aircraft_state:TELEMETRY:DT / 0.02) * CONFIG:IPU, 0) + char(10)
	+ "ipu " + CONFIG:IPU + char(10).

	if(not gui:terminal_debug_button:PRESSED){return.}

	if(true) { // runway info
		local selected_runway to get_runway(gui:runway_select_menu:VALUE).
		set display_string to display_string
		+ "runway center L " + round(get_distance_to_runway_center_line(selected_runway, aircraft_state), 2) + char(10)
		+ "runway distance " + round(get_distance_to_runway(selected_runway, aircraft_state), 2) + char(10)
		+ "runway angle    " + round(get_angle_to_runway(selected_runway, aircraft_state), 2) + char(10)
		+ "runway altitude " + round(get_altitude_to_runway(selected_runway, aircraft_state), 2) + char(10)
		+ "run alt error   " + round(aircraft_state:TELEMETRY:ALTITUDE - get_altitude_to_runway(selected_runway, aircraft_state), 2) + char(10)
		+ " " + char(10).
	}

	if(true) { // attitude
		set display_string to display_string
		+ "pitch       " + round(aircraft_state:TELEMETRY:PITCH_ANGLE, 2) + char(10)
		+ "AoA         " + round(aircraft_state:TELEMETRY:ANGLE_OF_ATTACK, 2) + char(10)
		+ "yaw         " + round(aircraft_state:TELEMETRY:COMPASS_ANGLE, 2) + char(10)
		+ "roll        " + round(aircraft_state:TELEMETRY:ROLL_ANGLE, 2) + char(10)
		+ " " + char(10).
	}

	if(true) {
		set display_string to display_string
		+ "altitude      " + round(aircraft_state:TELEMETRY:ALTITUDE, 2) + char(10)
		+ "v speed       " + round(aircraft_state:TELEMETRY:VSPEED, 2) + char(10)
		+ "air speed     " + round(aircraft_state:TELEMETRY:AIRSPEED, 2) + char(10)
		+ "dynamic press " + round(aircraft_state:TELEMETRY:DYNAMIC_PRESSURE, 2) + char(10)
		+ " " + char(10).
	}

	if(true) {
		set display_string to display_string
		+ "pitch input  " + round(ship:control:pitch, 2) + char(10)
		+ "pitch trim   " + round(aircraft_state:CONFIG:PITCH_TRIM, 2) + char(10)
		+ "yaw input    " + round(ship:control:yaw, 2) + char(10)
		+ "roll input   " + round(ship:control:roll, 2) + char(10)
		+ "thrust    kN " + round(aircraft_state:TELEMETRY:THRUST, 2) + char(10)
		+ " " + char(10).
	}
}


function handle_gui_pitch {
	parameter gui, aircraft_state.

	if(gui:altitude_plus_100_btn:TAKEPRESS) {
		set gui:INPUT_ALTITUDE to min(gui:INPUT_ALTITUDE + 100, 25000).
	}

	if(gui:altitude_plus_1000_btn:TAKEPRESS) {
		set gui:INPUT_ALTITUDE to min(gui:INPUT_ALTITUDE + 1000, 25000).
	}

	if(gui:altitude_minus_100_btn:TAKEPRESS) {
		set gui:INPUT_ALTITUDE to max(gui:INPUT_ALTITUDE - 100, 0).
	}

	if(gui:altitude_minus_1000_btn:TAKEPRESS) {
		set gui:INPUT_ALTITUDE to max(gui:INPUT_ALTITUDE - 1000, 0).
	}
	set gui:INPUT_ALTITUDE to round(gui:INPUT_ALTITUDE, 0).
	
	set gui:INPUT_ALTITUDE_TEXT:TEXT to gui:INPUT_ALTITUDE + " m".
	
	if (gui:altitude_glideslope_button:PRESSED) {
		local selected_runway to get_runway(gui:runway_select_menu:VALUE).
		local glide_slope_altitude to get_altitude_to_runway(selected_runway, aircraft_state).
		local input_altitude to gui:INPUT_ALTITUDE.
		local target_altitude to min(glide_slope_altitude, input_altitude).
		set ship:control:pitch to get_commanded_altitude(target_altitude, aircraft_state) + ship:CONTROL:PILOTPITCH.
		//set altitude_label:TEXT to round(glide_slope_altitude(), 0) + " m".
	} else if (gui:altitude_input_button:PRESSED) {
		set ship:control:pitch to get_commanded_altitude(gui:INPUT_ALTITUDE, aircraft_state) + ship:CONTROL:PILOTPITCH.
		//set altitude_label:TEXT to input_target_alt + " m".
	} else if (gui:altitude_manual_button:PRESSED) {
		set ship:control:PITCH to ship:control:pilotpitch.
		//set altitude_label:TEXT to "MANUAL".
	}
}

function handle_gui_heading {
	parameter gui, aircraft_state.

	if(gui:heading_plus_5_btn:TAKEPRESS) {
		set gui:input_heading to mod((gui:input_heading + 360 + 5), 360).
	}

	if(gui:heading_plus_45_btn:TAKEPRESS) {
		set gui:input_heading to mod((gui:input_heading + 360 + 45), 360).
	}

	if(gui:heading_minus_5_btn:TAKEPRESS) {
		set gui:input_heading to mod((gui:input_heading + 360 - 5), 360).
	}

	if(gui:heading_minus_45_btn:TAKEPRESS) {
		set gui:input_heading to mod((gui:input_heading + 360 - 45), 360).
	}
	set gui:input_heading to round(gui:input_heading, 0).
	set gui:input_heading_text:text to gui:input_heading + " deg".
	
	if (gui:heading_runway_button:PRESSED) {
		local selected_runway to get_runway(gui:runway_select_menu:VALUE).
		local target_heading to get_angle_to_runway(selected_runway, aircraft_state).
		set ship:control:roll to get_commanded_heading(target_heading, aircraft_state) + ship:CONTROL:PILOTROLL.
		//set heading_label:TEXT to round(get_angle_to_runway(), 1) + " deg".

	} else if (gui:heading_target_button:PRESSED) {
		local heading_to_target to 0.
		if(hastarget) {
			set heading_to_target to LATLNG(target:geoposition:lat, target:geoposition:lng):heading.
		} else {
			local selected to false.
			local waypoint to 0.
			FOR point IN ALLWAYPOINTS() {
    				if(point:isselected) {set selected to true. set waypoint to point.}
			}
			if(selected) {
				set heading_to_target to LATLNG(waypoint:geoposition:lat, waypoint:geoposition:lng):heading.
			} else { 
				// no target and no waypoint
				set gui:heading_manual_button:PRESSED to true.
			}
		}
		set ship:control:roll to get_commanded_heading(heading_to_target, aircraft_state) + ship:CONTROL:PILOTROLL.
		//set heading_label:TEXT to round(heading_to_target, 1) + " deg".
	} else if (gui:heading_input_button:PRESSED) {
		set ship:control:roll to get_commanded_heading(gui:input_heading, aircraft_state) + ship:CONTROL:PILOTROLL.
		//set heading_label:TEXT to input_target_heading + " deg".
	} else if (gui:heading_manual_button:PRESSED) {
		set ship:control:ROLL to ship:control:pilotroll.
		//set heading_label:TEXT to "MANUAL".
	}
}

function handle_gui_speed {
	parameter gui, aircraft_state.

	if(gui:speed_plus_10_btn:TAKEPRESS) {
		set gui:input_speed to min(gui:input_speed + 10, 300).
	}

	if(gui:speed_plus_50_btn:TAKEPRESS) {
		set gui:input_speed to min(gui:input_speed + 50, 300).
	}

	if(gui:speed_minus_10_btn:TAKEPRESS) {
		set gui:input_speed to max(gui:input_speed - 10, 100).
	}

	if(gui:speed_minus_50_btn:TAKEPRESS) {
		set gui:input_speed to max(gui:input_speed - 50, 100).
	}
	set gui:input_speed to round(gui:input_speed, 0).
	set gui:input_speed_text:TEXT to gui:input_speed + " m/s".
	
	if(brakes) {
		LOCK THROTTLE to 0.
		//set speed_label:TEXT to "BRAKE".
	} else {
		if (gui:speed_input_button:PRESSED) {
			LOCK THROTTLE to get_commanded_speed(gui:input_speed, aircraft_state).
			//set speed_label:TEXT to input_target_speed + " m/s".
		} else if (gui:speed_manual_button:PRESSED) {
			UNLOCK THROTTLE.
			//set speed_label:TEXT to "MANUAL".
		}
	}
}

function handle_gui_systems {
	parameter gui, aircraft_state.

	// autobrake
	if (gui:autobrake_armed_button:PRESSED and aircraft_state:TELEMETRY:RADAR_ALTITUDE < 10 and abs(aircraft_state:TELEMETRY:VSPEED) < 0.5) {
		set BRAKES to true.
		lock THROTTLE to 0.
	}
	if (gui:autobrake_button:PRESSED and aircraft_state:TELEMETRY:RADAR_ALTITUDE > 100) {
		set gui:autobrake_armed_button:PRESSED to true.
	}
	if (aircraft_state:TELEMETRY:AIRSPEED < 1) {
		//set auto_brake_armed to false.
		set gui:autobrake_armed_button:PRESSED to false.
	}

	// autogear
	if (gui:autogear_button:PRESSED) {
		set gear to (alt:radar < 500).
	}

	// airbrakes
	set ag1 to brakes.
}







