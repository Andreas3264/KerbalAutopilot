
function get_autopilot_gui {
	set gui to lexicon().
	
	LOCAL my_gui is GUI(800).
	set gui["guiroot"] to my_gui.
	local controll_pane to my_gui:ADDHBOX().


	// ALTITUDE
	set gui["input_altitude"] to 1000.	

	local altitude_pane to controll_pane:ADDVBOX().
	local altitude_label to altitude_pane:ADDLABEL("Altitude:").
	SET altitude_label:STYLE:ALIGN TO "CENTER".

	local altitude_custom_pane to altitude_pane:ADDHBOX().
	set gui["altitude_glideslope_button"] to altitude_custom_pane:ADDRADIOBUTTON("LND").
	set gui["altitude_input_button"] to altitude_custom_pane:ADDRADIOBUTTON("IN").
	set gui["altitude_manual_button"] to altitude_custom_pane:ADDRADIOBUTTON("MAN", true).

	// ALTITUDE SELECT
	local altitude_pm_pane to altitude_pane:ADDHBOX().
	set gui["altitude_minus_1000_btn"] to altitude_pm_pane:ADDBUTTON("-1K").
	set gui["altitude_minus_100_btn"] to altitude_pm_pane:ADDBUTTON("-100").

	local altitude_input_label to altitude_pm_pane:ADDLABEL("").
	SET altitude_input_label:STYLE:ALIGN TO "CENTER".
	set gui["input_altitude_text"] to altitude_input_label.

	set gui["altitude_plus_100_btn"] to altitude_pm_pane:ADDBUTTON("+100").
	set gui["altitude_plus_1000_btn"] to altitude_pm_pane:ADDBUTTON("+1K").


	//HEADING
	set gui["input_heading"] to 90.

	local heading_pane to controll_pane:ADDVBOX().
	local heading_label to heading_pane:ADDLABEL("Heading:").
	SET heading_label:STYLE:ALIGN TO "CENTER".

	local heading_custom_pane to heading_pane:ADDHBOX().
	set gui["heading_target_button"] to heading_custom_pane:ADDRADIOBUTTON("TAR").
	set gui["heading_runway_button"] to heading_custom_pane:ADDRADIOBUTTON("RUN").
	set gui["heading_input_button"] to heading_custom_pane:ADDRADIOBUTTON("IN").
	set gui["heading_manual_button"] to heading_custom_pane:ADDRADIOBUTTON("MAN", true).

	// HEADING SELECT
	local heading_pm_pane to heading_pane:ADDHBOX().
	set gui["heading_minus_45_btn"] to heading_pm_pane:ADDBUTTON("-45").
	set gui["heading_minus_5_btn"] to heading_pm_pane:ADDBUTTON("-5").
	
	local heading_input_label to heading_pm_pane:ADDLABEL("").
	SET heading_input_label:STYLE:ALIGN TO "CENTER".
	set gui["input_heading_text"] to heading_input_label.

	set gui["heading_plus_5_btn"] to heading_pm_pane:ADDBUTTON("+5").
	set gui["heading_plus_45_btn"] to heading_pm_pane:ADDBUTTON("+45").


	// SPEED
	set gui["input_speed"] to 100.

	local speed_pane to controll_pane:ADDVBOX().
	local speed_label to speed_pane:ADDLABEL("Speed:").
	SET speed_label:STYLE:ALIGN TO "CENTER".

	local speed_custom_pane to speed_pane:ADDHBOX().
	set gui["speed_input_button"] to speed_custom_pane:ADDRADIOBUTTON("IN").
	set gui["speed_manual_button"] to speed_custom_pane:ADDRADIOBUTTON("MAN", true).

	// SPEED SELECT
	local speed_pm_pane to speed_pane:ADDHBOX().
	set gui["speed_minus_50_btn"] to speed_pm_pane:ADDBUTTON("-50").
	set gui["speed_minus_10_btn"] to speed_pm_pane:ADDBUTTON("-10").
	
	local speed_input_label to speed_pm_pane:ADDLABEL("").
	SET speed_input_label:STYLE:ALIGN TO "CENTER".
	set gui["input_speed_text"] to speed_input_label.

	set gui["speed_plus_10_btn"] to speed_pm_pane:ADDBUTTON("+10").
	set gui["speed_plus_50_btn"] to speed_pm_pane:ADDBUTTON("+50").


	// RUNWAY
	local runway_pane to controll_pane:ADDVBOX().
	
	set gui["runway_select_menu"] to runway_pane:ADDPOPUPMENU().
	for key in get_runways():KEYS {
		gui:runway_select_menu:ADDOPTION(key).
	}


	// UTILS
	local util_pane to controll_pane:ADDVBOX().

	set gui["autobrake_button"] to util_pane:ADDCHECKBOX("Autobrake", true).
	set gui["autobrake_armed_button"] to util_pane:ADDCHECKBOX("Autobrake arm", false).
	set gui["autogear_button"] to util_pane:ADDCHECKBOX("Autogear", true).


	my_gui:SHOW().
	return gui.
}