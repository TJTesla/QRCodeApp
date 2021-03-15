//
//  MatrixFilling.swift
//  QRCodeApp
//
//  Created by Theodor Teslia on 11.03.21.
//

import Foundation

func finderPatterns(_ pMatrix: [[CodeModule]], x: Int, y: Int) -> [[CodeModule]] {
	// Steps for drawing a finder pattern at the coordinates
	// Lines in the jmatrix are shown via an empty line
	var matrix = pMatrix
	for i in 0 ..< 7 {
		matrix[y][x+i] = CodeModule(pColor: .black, reserve: .finder)
	}
	
	matrix[y+1][x] = CodeModule(pColor: .black, reserve: .finder)
	for i in 1 ... 5 {
		matrix[y+1][x+i] = CodeModule(pColor: .white, reserve: .finder)
	}
	matrix[y+1][x+6] = CodeModule(pColor: .black, reserve: .finder)
	
	for j in 0 ..< 3 {
		matrix[y+2+j][x] = CodeModule(pColor: .black, reserve: .finder)
		matrix[y+2+j][x+1] = CodeModule(pColor: .white, reserve: .finder)
		for i in 2 ... 4 {
			matrix[y+2+j][x+i] = CodeModule(pColor: .black, reserve: .finder)
		}
		matrix[y+2+j][x+5] = CodeModule(pColor: .white, reserve: .finder)
		matrix[y+2+j][x+6] = CodeModule(pColor: .black, reserve: .finder)
	}
	
	matrix[y+5][x] = CodeModule(pColor: .black, reserve: .finder)
	for i in 1 ... 5 {
		matrix[y+5][x+i] = CodeModule(pColor: .white, reserve: .finder)
	}
	matrix[y+5][x+6] = CodeModule(pColor: .black, reserve: .finder)
	
	for i in 0 ..< 7 {
		matrix[y+6][x+i] = CodeModule(pColor: .black, reserve: .finder)
	}
	
	return matrix
}

func separator(_ pMatrix: [[CodeModule]], corner: Corner) -> [[CodeModule]] {
	// Algorithm for drawing separators around the finder pattern at the specified corner
	var matrix = pMatrix
	
	var horiStart: (x: Int, y: Int)
	var vertiStart: (x: Int, y: Int)
	switch corner {  // Determine the correct corner coordinates, based on the given Corner object
		case .upperLeft:
			horiStart = (0, 7)
			vertiStart = (7, 0)
		case .upperRight:
			horiStart = (matrix.count-1-7, 7)
			vertiStart = (matrix.count-1-7, 0)
		case .lowerLeft:
			horiStart = (0, matrix.count-1-7)
			vertiStart = (7, matrix.count-7)
		default:
			horiStart = (0, 0)
			vertiStart = (0, 0)
	}
	
	for i in 0 ..< 8 {  // Draw separators
		matrix[horiStart.y][horiStart.x+i] = CodeModule(pColor: .white, reserve: .separator)
	}

	for i in 0 ..< 7 {
		matrix[vertiStart.y+i][vertiStart.x] = CodeModule(pColor: .white, reserve: .separator)
	}
	
	return matrix
}

func alignmentPattern(_ pMatrix: [[CodeModule]], _ version: Int) -> [[CodeModule]] {
	// Draw the alignment pttern
	// Only needed with version 2 or higher
	if version == 1 {
		return pMatrix
	}
	
	let pos = Helper.getAlignmentPatternLocations(version)
	var matrix = pMatrix
	
	print(pos)
	// From version 7 there are more patterns needed
	if (pos.2 == -1) {
		matrix = placeAlignmentPattern(matrix, pos: (pos.1-2, pos.1-2))
	} else {
		matrix = placeAlignmentPattern(matrix, pos: (pos.1-2, pos.0-2))
		matrix = placeAlignmentPattern(matrix, pos: (pos.0-2, pos.1-2))
		matrix = placeAlignmentPattern(matrix, pos: (pos.1-2, pos.1-2))
		matrix = placeAlignmentPattern(matrix, pos: (pos.2-2, pos.1-2))
		matrix = placeAlignmentPattern(matrix, pos: (pos.1-2, pos.2-2))
		matrix = placeAlignmentPattern(matrix, pos: (pos.2-2, pos.2-2))
	}
	
	return matrix
}

func placeAlignmentPattern(_ pMatrix: [[CodeModule]], pos p: (Int, Int)) -> [[CodeModule]] {
	// Draw the alignmetn pattern at the specified position
	var matrix = pMatrix
	
	if matrix[p.1+2][p.0+2].isReserved() {
		return pMatrix
	}
	
	for i in 0 ..< 5 {
		matrix[p.1][p.0+i] = CodeModule(pColor: .black, reserve: .alignment)
	}
	
	matrix[p.1+1][p.0] = CodeModule(pColor: .black, reserve: .alignment)
	for i in 1 ... 3 {
		matrix[p.1+1][p.0+i] = CodeModule(pColor: .white, reserve: .alignment)
	}
	matrix[p.1+1][p.0+4] = CodeModule(pColor: .black, reserve: .alignment)
	
	matrix[p.1+2][p.0+0] = CodeModule(pColor: .black, reserve: .alignment)
	matrix[p.1+2][p.0+1] = CodeModule(pColor: .white, reserve: .alignment)
	matrix[p.1+2][p.0+2] = CodeModule(pColor: .black, reserve: .alignment)
	matrix[p.1+2][p.0+3] = CodeModule(pColor: .white, reserve: .alignment)
	matrix[p.1+2][p.0+4] = CodeModule(pColor: .black, reserve: .alignment)
	
	matrix[p.1+3][p.0] = CodeModule(pColor: .black, reserve: .alignment)
	for i in 1 ... 3 {
		matrix[p.1+3][p.0+i] = CodeModule(pColor: .white, reserve: .alignment)
	}
	matrix[p.1+3][p.0+4] = CodeModule(pColor: .black, reserve: .alignment)
	
	for i in 0 ..< 5 {
		matrix[p.1+4][p.0+i] = CodeModule(pColor: .black, reserve: .alignment)
	}
	
	return matrix
}

func timingPatterns(_ pMatrix: [[CodeModule]]) -> [[CodeModule]] {
	// Draw the timing patterns
	// Timing patterns are always fixed between the finder patterns
	var matrix = pMatrix
	// Horizontal
	var xStart = 8, yStart = 6
	for i in 0 ..< pMatrix.count-16 {
		if i % 2 == 0 {
			matrix[yStart][xStart+i] = CodeModule(pColor: .black, reserve: .hTiming)
		} else {
			matrix[yStart][xStart+i] = CodeModule(pColor: .white, reserve: .hTiming)
		}
	}
	// Vertical
	xStart = 6; yStart = 8
	for i in 0 ..< pMatrix.count-16 {
		if i % 2 == 0 {
			matrix[yStart+i][xStart] = CodeModule(pColor: .black, reserve: .vTiming)
		} else {
			matrix[yStart+i][xStart] = CodeModule(pColor: .white, reserve: .vTiming)
		}
	}
	
	return matrix
}

func darkModule(_ pMatrix: [[CodeModule]], _ version: Int) -> [[CodeModule]] {
	var matrix = pMatrix
	matrix[(version*4)+9][8] = CodeModule(pColor: .black, reserve: .format)
	return matrix
}

func formatStringAndVersionInformation(_ pMatrix: [[CodeModule]], _ version: Int) -> [[CodeModule]] {
	var matrix = pMatrix
	
	// Format string
	let formatString = ErrorCorrector().createFormatString()
	
	for i in 0 ..< 6 {  // Complete block: Draw format string in upper left corner
		if formatString[i] == 1 {
			matrix[8][i] = CodeModule(pColor: .black, reserve: .format)
		} else {
			matrix[8][i] = CodeModule(pColor: .white, reserve: .format)
		}
	}
	for i in 0 ..< 6 {
		if formatString[14-i] == 1 {
			matrix[i][8] = CodeModule(pColor: .black, reserve: .format)
		} else {
			matrix[i][8] = CodeModule(pColor: .white, reserve: .format)
		}
	}
	matrix[8][7] = CodeModule(pColor: (formatString[6] == 1 ? .black : .white), reserve: .format)
	matrix[8][8] = CodeModule(pColor: (formatString[7] == 1 ? .black : .white), reserve: .format)
	matrix[7][8] = CodeModule(pColor: (formatString[8] == 1 ? .black : .white), reserve: .format)
	
	for i in 0 ..< 7 {  // Draw the format string in the lower left corner
		matrix[(4*version)+10+i][8] = CodeModule(pColor: (formatString[15-9-i] == 1 ? .black : .white), reserve: .format)
	}
	for i in 0 ..< 8 {  // Draw the format string in the upper right corner
		matrix[8][(4*version)+9+i] = CodeModule(pColor: (formatString[7+i] == 1 ? .black : .white), reserve: .format)
	}
	
	// Version Information
	if (version < 7) {
		return matrix
	}
	
	var versionInfo = ErrorCorrector().createVersionInfo(version)
	versionInfo.reverse()
	
	let start = (4*version) + 6
	var counter = 0
	for i in 0 ..< 6 {
		for j in 0 ..< 3 {
			matrix[start+j][i] = CodeModule(pColor: (versionInfo[counter] == 1 ? .black : .white), reserve: .lowVersion)  //  Lower left version info
			matrix[i][start+j] = CodeModule(pColor: (versionInfo[counter] == 1 ? .black : .white), reserve: .upVersion)  //  Upper right version ifno
			counter += 1
		}
	}
	
	return matrix
}

func fillWithMsg(_ pMatrix: [[CodeModule]], pMsg: String) -> [[CodeModule]] {
	// Functionality: Run through complete matrix
	// When area reserved through function patterns etc., just don't draw there
	// Try to draw on the next field
	var msg = [Character]()
	for bit in pMsg {
		msg.append(bit)
	}
	var matrix = pMatrix
	
	var xPos: (left: Int, right: Int) = (matrix.count-2, matrix.count-1)
	var yPos: Int = matrix.count-1
	// var counter = msg.count - 1
	var counter = 0
	var newLine = true
	
	enum  Direction: Int {
		case UP = -1, DOWN = 1
	}
	var direction: Direction = .UP
	
	while counter < msg.count {
		if xPos.left < 0 { // Prevent index out of bounds error (Safety net)
			break
		}
		
		if matrix[yPos][xPos.right].getPart() == .data {  // Only draw when possible
			matrix[yPos][xPos.right] = CodeModule(pColor: msg[counter] == "1" ? .black : .white)
			// counter -= 1
			counter += 1
		}
		if matrix[yPos][xPos.right].getPart() == .data {
			matrix[yPos][xPos.left] = CodeModule(pColor: msg[counter] == "1" ? .black : .white)
			//counter -= 1  // Progress to next element only when could be drawn
			counter += 1
		}
		
		if (yPos == 0 || yPos == matrix.count-1) && !newLine {
			direction = direction == .UP ? .DOWN : .UP
			newLine = true
			if xPos.left == 7 {  // Hit vertical timing pattern
				xPos.left -= 3
				xPos.right -= 3
				continue
			}
			xPos.left -= 2
			xPos.right -= 2
			continue
		}
		newLine = false
		yPos += direction.rawValue
	}
	
	return matrix
}

enum Corner {
	case upperLeft, upperRight, lowerLeft, lowerRight
}
