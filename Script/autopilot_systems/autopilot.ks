runoncepath("0:/autopilot_systems/includes.ks").

set display_string to "".
clearguis().
clearscreen.

local autopilot_gui to get_autopilot_gui().
local aircraft_state to get_aircraft_state().

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

until false {
	autopilot_loop().

	//prevents gui from being removed
	set main_gui to autopilot_gui:GUIROOT.

	clearscreen.
	print display_string.
	set display_string to "".
}

function autopilot_loop {
	update_aircraft_state(aircraft_state).

	handle_gui_pitch(autopilot_gui, aircraft_state).
	handle_gui_heading(autopilot_gui, aircraft_state).
	handle_gui_speed(autopilot_gui, aircraft_state).
	handle_gui_systems(autopilot_gui, aircraft_state).

	terminal_debug_print(autopilot_gui, aircraft_state).
}

function terminal_debug_print {
	parameter gui, aircraft_state.

	if(false) { // runway info
		local selected_runway to get_runway(gui:runway_select_menu:VALUE).
		set display_string to display_string + "dist centerline " + get_distance_to_runway_center_line(selected_runway, aircraft_state) + char(10).
		set display_string to display_string + "dist runway     " + get_distance_to_runway(selected_runway, aircraft_state) + char(10).
		set display_string to display_string + "runway angle    " + get_angle_to_runway(selected_runway, aircraft_state) + char(10).
		set display_string to display_string + "runway altitude " + get_altitude_to_runway(selected_runway, aircraft_state) + char(10).
	}

	set display_string to display_string + "pitch input  " + ship:control:pitch + char(10).
	set display_string to display_string + "roll input   " + ship:control:roll + char(10).

	//set display_string to display_string + "thrust        " + aircraft_state:TELEMETRY:THRUST + char(10).
	//set display_string to display_string + "dynamic press " + aircraft_state:TELEMETRY:DYNAMIC_PRESSURE + char(10).
	set display_string to display_string + "AoA         " + aircraft_state:TELEMETRY:ANGLE_OF_ATTACK + char(10).
	set display_string to display_string + "pitch       " + aircraft_state:TELEMETRY:PITCH_ANGLE + char(10).
	//set display_string to display_string + "pitch rate  " + aircraft_state:TELEMETRY:PITCH_ANGLE_RATE + char(10).
	//set display_string to display_string + "pitch rate2 " + aircraft_state:TELEMETRY:PITCH_ANGLE_RATE_RATE + char(10).

	set display_string to display_string + "dt " + aircraft_state:TELEMETRY:DT + char(10).

	set display_string to display_string + "pitch trim  " + aircraft_state:CONFIG:PITCH_TRIM + char(10).
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







