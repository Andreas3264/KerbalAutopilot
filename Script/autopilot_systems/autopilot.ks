runoncepath("0:/autopilot_systems/includes.ks").

set display_string to "".
clearguis().
clearscreen.

set autopilot_gui to get_autopilot_gui().
set aircraft_state to get_aircraft_state().

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

	terminal_debug_print().
}

function terminal_debug_print {

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
	
	if (false) { //(gui:altitude_glideslope_button:PRESSED) {
		//maintain_altitude_adv(glide_slope_altitude(), 50).
		//set altitude_label:TEXT to round(glide_slope_altitude(), 0) + " m".
	} else if (gui:altitude_input_button:PRESSED) {
		set ship:control:pitch to get_commanded_altitude(gui:INPUT_ALTITUDE, aircraft_state) + ship:CONTROL:PILOTPITCH.
		//set ship:control:pitch to get_commanded_pitch(5, aircraft_state) + ship:CONTROL:PILOTPITCH.

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
	
	if (false) { //(gui:heading_runway_button:PRESSED) {
	//	maintain_heading_simple(get_angle_to_runway()).
	//	set heading_label:TEXT to round(get_angle_to_runway(), 1) + " deg".
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
	if (gui:autobrake_armed_button:PRESSED and aircraft_state:TELEMETRY:RADAR_ALTITUDE < 10) {
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







