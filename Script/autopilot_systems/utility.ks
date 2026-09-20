// utility functions

function clamp {
	parameter value, min, max.

	if value < min {
		return min.
	} else if value > max {
		return max.
	} else {
		return value.
	}
}

function sign {
	parameter x.

	if(x = 0) {return 0.}

	if x > 0 {
		return 1.
	} else {
		return -1.
	}
}

function cord_to_point {
	parameter lat, lng, alt.
	return LATLNG(lat, lng):ALTITUDEPOSITION(alt).
}

function dir_from_to {
	parameter lat_from, lng_from, lat_to, lng_to.

	local p1 to LATLNG(lat_from, lng_from).
	local p2 to LATLNG(lat_to, lng_to).
	return mod(360+arctan2(sin(p2:lng-p1:lng)*cos(p2:lat),cos(p1:lat)*sin(p2:lat)-sin(p1:lat)*cos(p2:lat)*cos(p2:lng-p1:lng)),360).
}