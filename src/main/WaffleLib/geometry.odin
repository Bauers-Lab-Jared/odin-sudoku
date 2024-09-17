package WaffleLib

is_inside_rectangle :: proc(point, lowerCorner, upperCorner: [2]f32) -> bool {
	for pd, dim in point {
		switch pd {
		case lowerCorner[dim] ..= upperCorner[dim]:
		case:
			return false
		}
	}
	return true
}
