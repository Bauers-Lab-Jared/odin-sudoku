package sudoku

import "core:fmt"

main :: proc() {
    return
}

Cell :: bit_field u16 {
    value: u8                   | 4, //Contains solved cell value or 0 if unsolved
    possible: u16               | 9, //Contains the yet possible solution values
    reserved1: bool             | 1,
    reserved2: bool             | 1,
    reserved3: bool             | 1,
}

CellPossibilities :: bit_set[1..=9]

SudokuPuzzle :: [9][9]Cell

Address_Rows :: proc(indexGrp: u16, indexCell: u16) -> (x: u16, y: u16, ok: bool) {
    if (indexGrp > 8) || (indexCell > 8) do return 0, 0, false
    return indexGrp, indexCell, true
}

Address_Cols :: proc(indexGrp: u16, indexCell: u16) -> (x: u16, y: u16, ok: bool) {
    if (indexGrp > 8) || (indexCell > 8) do return 0, 0, false
    return indexCell, indexGrp, true
}

Address_Sqrs :: proc(indexGrp: u16, indexCell: u16) -> (x: u16, y: u16, ok: bool) {
    if (indexGrp > 8) || (indexCell > 8) do return 0, 0, false
    switch indexGrp {
    case 0..=2:
        switch indexCell {
            case 0..=2: x = 0
            case 3..=5: x = 1
            case 6..=8: x = 2
        }
    case 3..=5:
        switch indexCell {
            case 0..=2: x = 3
            case 3..=5: x = 4
            case 6..=8: x = 5
        }
    case 6..=8:
        switch indexCell {
            case 0..=2: x = 6
            case 3..=5: x = 7
            case 6..=8: x = 8
        }
    }

    switch indexGrp {
    case 0,3,6:
        switch indexCell {
            case 0,3,6: y = 0
            case 1,4,7: y = 1
            case 2,5,8: y = 2
        }
    case 1,4,7:
        switch indexCell {
            case 0,3,6: y = 3
            case 1,4,7: y = 4
            case 2,5,8: y = 5
        }
    case 2,5,8:
        switch indexCell {
            case 0,3,6: y = 6
            case 1,4,7: y = 7
            case 2,5,8: y = 8
        }
    }
    return x, y, true
}

Address_All :: proc(indexGrp: u16, indexCell: u16) -> (x: u16, y: u16, ok: bool) {
    ig: u16 = indexGrp%9
    switch indexGrp {
        case 0..<9:
            return Address_Rows(cast(u16)indexGrp, indexCell)
        case 9..<18:
            return Address_Cols(ig, indexCell)
        case 18..<27:
            return Address_Sqrs(ig, indexCell)
        case:
            return 0, 0, false
    }
}

// CellGroup :: [9]^Cell
// 
// _Group_Set :: proc(puzzle: ^SudokuPuzzle) -> (grps: [9]CellGroup)
// _Group_All_Sets :: proc(puzzle: ^SudokuPuzzle) -> (rows, cols, sqrs: [9]CellGroup)
// 
// Get_Rows :: proc(puzzle: ^SudokuPuzzle) -> (grps: [9]CellGroup) {
//     rows:= &puzzle^[9]
//     return rows
// }
// 
// Get_Cols :: proc(puzzle: ^SudokuPuzzle) -> (grps: [9]CellGroup) {
//     cols: [9]CellGroup
//     for r in 0..<9 {
//         for c in 0..<9 {
//            cols[c][r] = &puzzle^[r][c]
//         }
//     }
// }
// 
// Cell_Grouper :: union {
//     _Group_Set,
//     _Group_All_Sets,
// }

LogicResult :: struct {
    changedCells: bool
}

// _Proc_On_Set :: proc(grps: [9]CellGroup) -> (res: LogicResult)
// _Proc_On_All_Sets :: proc(rows, cols, sqrs: [9]CellGroup) -> (res: LogicResult)
// 
// Proc_On_Groups :: union {
//     _Proc_On_Set,
//     _Proc_On_All_Sets,
// }
// 
// SudokuWorkspace :: struct {
// 	targetSudoku:     ^SudokuPuzzle,
// 	rows, cols, sqrs: [9]CellGroup,
// 	grps:             [27]CellGroup,
// }
