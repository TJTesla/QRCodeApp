//
//  MatrixFilling.swift
//  QRCodeApp
//
//  Created by Theodor Teslia on 11.03.21.
//

import Foundation

func finderPatterns(_ pMatrix: [[CodeModule]], x: Int, y: Int) -> [[CodeModule]] {
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
	var matrix = pMatrix
	
	var horiStart: (x: Int, y: Int)
	var vertiStart: (x: Int, y: Int)
	switch corner {
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
	
	for i in 0 ..< 8 {
		matrix[horiStart.y][horiStart.x+i] = CodeModule(pColor: .white, reserve: .separator)
	}

	for i in 0 ..< 7 {
		matrix[vertiStart.y+i][vertiStart.x] = CodeModule(pColor: .white, reserve: .separator)
	}
	
	return matrix
}

func alignmentPattern(_ pMatrix: [[CodeModule]], _ version: Int) -> [[CodeModule]] {
	if version == 1 {
		return pMatrix
	}
	
	let pos = Helper.getAlignmentPatternLocations(version)
	var matrix = pMatrix
	
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
	
	let formatString = ErrorCorrector().createFormatString()
	
	for i in 0 ..< 6 {
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
	
	for i in 0 ..< 7 {
		matrix[(4*version)+10+i][8] = CodeModule(pColor: (formatString[15-9-i] == 1 ? .black : .white), reserve: .format)
	}
	for i in 0 ..< 8 {
		matrix[8][(4*version)+9+i] = CodeModule(pColor: (formatString[7+i] == 1 ? .black : .white), reserve: .format)
	}
	
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

func fillWithMsg(_ pMatrix: [[CodeModule]], pMsg: String) {
	var msg = [Character]()
	for bit in pMsg {
		msg.append(bit)
	}
	var matrix = pMatrix
	
	
}

enum Corner {
	case upperLeft, upperRight, lowerLeft, lowerRight
}
