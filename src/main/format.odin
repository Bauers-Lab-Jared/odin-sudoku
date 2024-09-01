package SudokuSolver

import "base:runtime"
import "core:fmt"
import "core:io"
import "core:strconv"
import "core:strings"

make_puzzle_format_builder :: proc(
	puzzle: ^SudokuPuzzle,
	builder: strings.Builder = {},
	allocator := context.allocator,
) -> (
	res: strings.Builder,
	err: runtime.Allocator_Error,
) {
	builder := builder

	puzzleStringTemplate := `
     . . . | . . . | . . . 
     . . . | . . . | . . . 
     . . . | . . . | . . . 
    -------|-------|-------
     . . . | . . . | . . . 
     . . . | . . . | . . . 
     . . . | . . . | . . . 
    -------|-------|-------
     . . . | . . . | . . . 
     . . . | . . . | . . . 
     . . . | . . . | . . . 
`

	if strings.builder_len(builder) == 0 {
		builder = strings.builder_make(0, len(puzzleStringTemplate), allocator) or_return
	} else if strings.builder_space(builder) < len(puzzleStringTemplate) {
		strings.builder_grow(&builder, len(puzzleStringTemplate))
	}
	strings.builder_reset(&builder)

	cellIndex: int
	for char in puzzleStringTemplate {
		if char == '.' {
			cell, cell_solved := puzzle^.data[cellIndex / 9][cellIndex % 9].(u16)
			if cellIndex < 81 {
				if cell_solved {
					if cell >= 1 && cell <= 9 {
						strings.write_int(&builder, cast(int)cell)
					} else {
						strings.write_byte(&builder, '!')
					}
				} else {
					strings.write_byte(&builder, cast(u8)char)
				}
				cellIndex += 1
			} else {
				strings.write_byte(&builder, '?')
			}
		} else {
			strings.write_byte(&builder, cast(u8)char)
		}
	}

	return builder, nil
}

make_puzzle_format_builder_full :: proc(
	puzzle: ^SudokuPuzzle,
	allocator := context.allocator,
) -> (
	res: strings.Builder,
	err: runtime.Allocator_Error,
) {

	emptySpace :: " "
	ruledOut :: "."
	innerVert :: "│"
	innerHor :: "─"
	innerInt :: "┼"
	outerVert :: "║"
	outerHor :: "═"
	outerInt :: "╬"
	lineLength :: 71
	emptyP :: emptySpace + emptySpace
	innerHoriP :: innerHor + innerHor
	outerHoriP :: outerHor + outerHor
	emptyC :: emptyP + emptyP + emptyP + emptySpace
	innerHoriC :: innerHoriP + innerHoriP + innerHoriP + innerHor
	outerHoriC :: outerHoriP + outerHoriP + outerHoriP + outerHor
	emptyG :: emptyC + innerVert + emptyC + innerVert + emptyC
	innerHoriG :: innerHoriC + innerInt + innerHoriC + innerInt + innerHoriC
	outerHoriG :: outerHoriC + outerHor + outerHoriC + outerHor + outerHoriC
	emptyLine :: emptyG + outerVert + emptyG + outerVert + emptyG
	innerHoriLine :: innerHoriG + outerVert + innerHoriG + outerVert + innerHoriG
	outerHoriLine :: outerHoriG + outerInt + outerHoriG + outerInt + outerHoriG

	builder := strings.builder_make(0, 5120, allocator) or_return
	subrows: [3]strings.Builder
	defer for &buf in subrows {
		strings.builder_destroy(&buf)
	}
	for &buf in subrows {
		buf = strings.builder_make(0, lineLength, allocator) or_return
	}

	for &row, rowIndex in puzzle^.data {
		switch rowIndex {
		case 0:
		case 3, 6:
			strings.write_string(&builder, "\n" + outerHoriLine + "\n")
		case:
			strings.write_string(&builder, "\n" + innerHoriLine + "\n")
		}

		for &buf in subrows {
			strings.builder_reset(&buf)
		}

		for cell, cellIndex in row {
			for &subrow, srIndex in subrows {
				prefix: string
				switch cellIndex {
				case 0:
					prefix = emptySpace
				case 3, 6:
					prefix = outerVert + emptySpace
				case:
					prefix = innerVert + emptySpace
				}
				strings.write_string(&subrow, prefix)
				switch c in cell {
				case u16:
					strings.write_string(&subrow, ruledOut + emptySpace)
					if srIndex == 1 {
						strings.write_byte(&subrow, u8('0' + c))
						strings.write_string(&subrow, emptySpace)
					} else {
						strings.write_string(&subrow, ruledOut + emptySpace)
					}
					strings.write_string(&subrow, ruledOut + emptySpace)
				case CellPossibilities:
					for i in 1 ..= 3 {
						cellPossibility := i + srIndex * 3
						if cellPossibility in c {
							strings.write_byte(&subrow, u8('0' + cellPossibility))
							strings.write_string(&subrow, emptySpace)
						} else {
							strings.write_string(&subrow, ruledOut + emptySpace)
						}
					}
				case nil:
					for i in 1 ..= 3 {
						strings.write_string(&subrow, "?" + emptySpace)
					}
				case:
					for i in 1 ..= 3 {
						strings.write_string(&subrow, "!" + emptySpace)
					}
				}
			}
		}

		strings.write_string(&builder, strings.to_string(subrows[0]))
		strings.write_string(&builder, "\n")
		strings.write_string(&builder, strings.to_string(subrows[1]))
		strings.write_string(&builder, "\n")
		strings.write_string(&builder, strings.to_string(subrows[2]))
	}

	return builder, nil
}
