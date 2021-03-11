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
		matrix[y][x+i] = CodeModule(pColor: .black, reserve: true)
	}
	
	matrix[y+1][x] = CodeModule(pColor: .black, reserve: true)
	for i in 1 ... 5 {
		matrix[y+1][x+i] = CodeModule(pColor: .white, reserve: true)
	}
	matrix[y+1][x+6] = CodeModule(pColor: .black, reserve: true)
	
	for j in 0 ..< 3 {
		matrix[y+2+j][x] = CodeModule(pColor: .black, reserve: true)
		matrix[y+2+j][x+1] = CodeModule(pColor: .white, reserve: true)
		for i in 2 ... 4 {
			matrix[y+2+j][x+i] = CodeModule(pColor: .black, reserve: true)
		}
		matrix[y+2+j][x+5] = CodeModule(pColor: .white, reserve: true)
		matrix[y+2+j][x+6] = CodeModule(pColor: .black, reserve: true)
	}
	
	matrix[y+5][x] = CodeModule(pColor: .black, reserve: true)
	for i in 1 ... 5 {
		matrix[y+5][x+i] = CodeModule(pColor: .white, reserve: true)
	}
	matrix[y+5][x+6] = CodeModule(pColor: .black, reserve: true)
	
	for i in 0 ..< 7 {
		matrix[y+6][x+i] = CodeModule(pColor: .black, reserve: true)
	}
	
	return matrix
}

func seperator(_ pMatrix: [[CodeModule]], corner: Corner) -> [[CodeModule]] {
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
		matrix[horiStart.y][horiStart.x+i] = CodeModule(pColor: .white, reserve: true)
	}

	for i in 0 ..< 7 {
		matrix[vertiStart.y+i][vertiStart.x] = CodeModule(pColor: .white, reserve: true)
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
		
	} else {
		
	}
}

func placePattern(_ pMatrix: [[CodeModule]], pos p: (Int, Int)) -> [[CodeModule]] {
	var matrix = pMatrix
	
	if matrix[p.1+2][p.0+2].isReserved() {
		return pMatrix
	}
	
	for i in 0 ..< 5 {
		matrix[p.1][p.0+i] = CodeModule(pColor: .black, reserve: true)
	}
	
	matrix[p.1+1][p.0] = CodeModule(pColor: .black, reserve: true)
	for i in 1 ... 3 {
		matrix[p.1+1][p.0+i] = CodeModule(pColor: .white, reserve: true)
	}
	matrix[p.1+1][p.0+4] = CodeModule(pColor: .black, reserve: true)
	
	matrix[p.1+2][p.0+0] = CodeModule(pColor: .black, reserve: true)
	matrix[p.1+2][p.0+1] = CodeModule(pColor: .white, reserve: true)
	matrix[p.1+2][p.0+2] = CodeModule(pColor: .black, reserve: true)
	matrix[p.1+2][p.0+3] = CodeModule(pColor: .white, reserve: true)
	matrix[p.1+2][p.0+4] = CodeModule(pColor: .black, reserve: true)
	
	matrix[p.1+3][p.0] = CodeModule(pColor: .black, reserve: true)
	for i in 1 ... 3 {
		matrix[p.1+3][p.0+i] = CodeModule(pColor: .white, reserve: true)
	}
	matrix[p.1+3][p.0+4] = CodeModule(pColor: .black, reserve: true)
	
	for i in 0 ..< 5 {
		matrix[p.1+4][p.0+i] = CodeModule(pColor: .black, reserve: true)
	}
	
	return matrix
}

enum Corner {
	case upperLeft, upperRight, lowerLeft, lowerRight
}
