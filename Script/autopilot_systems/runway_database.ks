
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

// Baikerbanur 198
// island 270	
// lat start	20.718367
// lng start	-146.473616
// lat end	20.491157
// lng end	-146.550809
// alt		417
set runways["baikerbanur_198"] to new_runway(20.718367, -146.473616, 20.491157, -146.550809, 417).

// Baikerbanur 18
// island 270	
// lat start	20.491157
// lng start	-146.550809
// lat end	20.718367
// lng end	-146.473616
// alt		418
set runways["baikerbanur_18"] to new_runway(-20.491157, -146.550809, 20.718367, -146.473616, 418).

// Harvester Airfield 259
// lat start	-56.281700
// lng start	-10.840104
// lat end	-56.312308
// lng end	-11.124958
// alt		3952
set runways["harvester_airfield_259"] to new_runway(-56.281700, -10.840104, -56.312308, -11.124958, 3952).

// Harvester Airfield 79
// lat start	-56.312308
// lng start	-11.124958
// lat end	-56.281700
// lng end	-10.840104
// alt		3952
set runways["harvester_airfield_259"] to new_runway(-56.312308, -11.124958, -56.281700, -10.840104, 3952).

// Kamberwick Green 93
// lat start	36.187033
// lng start	10.454466
// lat end	36.176170
// lng end	10.749345
// alt		623
set runways["kamberwick_green_93"] to new_runway(36.187033, 10.454466, 36.176170, 10.749345, 623).

// Kamberwick Green 273
// lat start	36.176170
// lng start	10.749345
// lat end	36.187033
// lng end	10.454466
// alt		623
set runways["kamberwick_green_273"] to new_runway(36.176170, 10.749345, 36.187033, 10.454466, 623).

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

// Kojave Sands 38 R - long
// lat start	5.956358
// lng start	-142.051495
// lat end	6.144304
// lng end	-141.904314
// alt		718
set runways["kojave_sands_38_l"] to new_runway(5.956358, -142.051495, 6.144304, -141.904314, 718).

// Kojave Sands 218 L - long
// lat start	6.144304
// lng start	-141.904314
// lat end	5.956358
// lng end	-142.051495
// alt		718
set runways["kojave_sands_218_r"] to new_runway(6.144304, -141.904314, 5.956358, -142.051495, 718).

// Nye Island 149
// lat start	5.815271
// lng start	108.707663
// lat end	5.676761
// lng end	108.792190
// alt		320
set runways["nye_island_149"] to new_runway(5.815271, 108.707663, 5.676761, 108.792190, 320).

// Nye Island 329
// lat start	5.676761
// lng start	108.792190
// lat end	5.815271
// lng end	108.707663
// alt		320
set runways["nye_island_329"] to new_runway(5.676761, 108.792190, 5.815271, 108.707663, 320).

// Round Range 282 R - long
// lat start	-6.024928
// lng start	99.627212
// lat end	-5.974304
// lng end	99.393340
// alt		1185
set runways["round_range_282_r"] to new_runway(-6.024928, 99.627212, -5.974304, 99.393340, 1185).

// Round Range 102 L - long
// lat start	-5.974304
// lng start	99.393340
// lat end	-6.024928
// lng end	99.627212
// alt		1185
set runways["round_range_102_l"] to new_runway(-5.974304, 99.393340, -6.024928, 99.627212, 1185).

// South Field 91
// lat start	-47.003407
// lng start	-141.153336
// lat end	-47.009373
// lng end	-140.803705
// alt		79
set runways["south_field_91"] to new_runway(-47.003407, -141.153336, -47.009373, -140.803705, 79).

// South Field 271
// lat start	-47.009373
// lng start	-140.803705
// lat end	-47.003407
// lng end	-141.153336
// alt		79
set runways["south_field_271"] to new_runway(-47.009373, -140.803705, -47.003407, -141.153336, 79).

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