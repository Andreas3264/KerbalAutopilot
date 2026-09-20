
function get_runway {
	parameter runway_name.
	return runways[runway_name].
}

function get_runways {
	return runways.
}

function new_runway {
	parameter lat_start, lng_start, lat_end, lng_end, altitude.
	local runway to lexicon().
	set runway["lat_start"] to lat_start.
	set runway["lng_start"] to lng_start.
	set runway["lat_end"] to lat_end.
	set runway["lng_end"] to lng_end.
	set runway["altitude"] to altitude.
	return runway.
}

local runways to lexicon().

// TEMPLATE
// local runway to new_runway(lat_start, lng_start, lat_end, lng_end, altitude).

// kerman atoll 111 R
// lat start	-37.071534
// lng start	-71.168194
// lat end	-37.156901
// lng end	-70.888919
// alt		204
set runways["runway_kerman_atoll_111_r"] to new_runway(-37.071534, -71.168194, -37.156901, -70.888919, 204).

// kerman atoll 111 L
// lat start	-37.029578
// lng start	-71.142658
// lat end	-37.114998
// lng end	-70.863743
// alt		204
set runways["runway_kerman_atoll_111_l"] to new_runway(-37.029578, -71.142658, -37.114998, -70.863743, 204).

// KSC 90	
// lat start	-0.048630
// lng start	-74.718788
// lat end	-0.050164
// lng end	-74.499351
// alt		69
set runways["runway_ksc_90"] to new_runway(-0.048630, -74.718788, -0.050164, -74.499351, 69).

// KSC 270	
// lat start	-0.050164
// lng start	-74.499351
// lat end	-0.048630
// lng end	-74.718788
// alt		69
set runways["runway_ksc_270"] to new_runway(-0.050164, -74.499351, -0.048630, -74.718788, 69).

// island 90	
// lat start	-1.517881
// lng start	-71.967048
// lat end	-1.515605
// lng end	-71.854972
// alt		133
set runways["runway_island_90"] to new_runway(-1.517881, -71.967048, -1.515605, -71.854972, 133).

// island 270	
// lat start	-1.515605
// lng start	-71.854972
// lat end	-1.517881
// lng end	-71.967048
// alt		133
set runways["runway_island_270"] to new_runway(-1.515605, -71.854972, -1.517881, -71.967048, 133).