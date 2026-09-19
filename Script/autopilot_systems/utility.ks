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