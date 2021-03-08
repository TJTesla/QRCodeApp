//
//  Helper.swift
//  QRCodeApp
//
//  Created by Theodor Teslia on 04.03.21.
//

import Foundation

class Helper {
	public static func ByteModeEncoding(_ input: String) -> [String] {
		var save = [String]()
		
		for char in input {
			let temp = String(char).utf8CString[0]
			let hex = String(temp, radix: 2)
			save.append(hex)
		}
		
		for i in 0 ..< save.count {
			save[i] = self.pad(toSize: 8, message: save[i])
		}
		
		return save
	}
	
	public static func pad(toSize size: Int, message msg: String) -> String {
		var str = msg
		
		if str.count >= size {
			return str
		}
		
		for _ in 0 ..< size - str.count {
			str.insert("0", at: str.startIndex)
		}
		
		return str
	}
	
	public static func findCorrectSize(size: Int) -> Int {
		// Since I am only using the byte Mode and the M Level of error correction, as well as version 20 as the maximum,
		// I only need to save 20 Values to determine the correct size
		// The sizes are taken from the website of DENSO WAVE: https://www.qrcode.com/en/about/version.html
		let sizes = [14, 26, 42, 62, 84, 106, 122, 152, 180, 213,
					 251, 287, 331, 362, 412, 450, 504, 560, 624, 666]
		
		for i in 0 ..< sizes.count {
			if size < sizes[i] {
				return i+1
			}
		}
		
		return -1
	}
	
	public static func encodeCharCountIndicator(version v: Int, _ str: String) -> String {
		var result = String(Int(str.count), radix: 2)
		var bitLength: Int
		
		if v < 10 {
			bitLength = 8
		} else{
			bitLength = 16
		}
		
		result = self.pad(toSize: bitLength, message: result)
		
		return result
	}
	
	public static func getECInfo(version: Int, _ info: Generator.ECWords) -> Int {
		let ecTable =
		[[16, 10, 1, 16, 0, 0, 16], [28, 16, 1, 28, 0, 0, 28], [44, 26, 1, 44, 0, 0, 44],
			[64, 18, 2, 32, 0, 0, 64], [86, 24, 2, 43, 0, 0, 86], [108, 16, 4, 27, 0, 0, 108],
			[124, 18, 4, 31, 0, 0, 124], [154, 22, 2, 38, 2, 39, 154], [182, 22, 3, 36, 2, 37, 182], [216, 26, 4, 43, 1, 44, 216],
		 [254, 30, 1, 50, 4, 51, 254], [290, 22, 6, 36, 2, 37, 290], [334, 22, 8, 37, 1, 38, 334],
			[365, 24, 4, 40, 5, 41, 365], [415, 24, 5, 41, 5, 42, 415], [453, 28, 7, 45, 3, 46, 453],
			[507, 28, 10, 46, 1, 47, 507], [563, 26, 9, 43, 4, 44, 563], [627, 26, 3, 44, 11, 45, 627], [669, 26, 3, 41, 13, 42, 669]]
		// Source: https://www.thonky.com/qr-code-tutorial/error-correction-table
		
		return ecTable[version-1][info.rawValue]
	}
}
