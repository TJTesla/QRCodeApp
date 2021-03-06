//
//  ErrorCorrector.swift
//  QRCodeApp
//
//  Created by Theodor Teslia on 08.03.21.
//

import Foundation

class ErrorCorrector {
	// Nearly the complete code of this part is taken from the website: https://en.m.wikiversity.org/wiki/Reed–Solomon_codes_for_coders#Encoding_main_function
	// I took the parts I needed and translated them from Python to Swift
	// However, the functions getOtherGenPoly(), createFormatString() and createVersionInfo(),
	// as well as the enum Case were completely written by
	
	private var gf_exp = [Int](repeating: 0, count: 512)
	private var gf_log = [Int](repeating: 0, count: 256)
	
	public init() {
		init_tables()
	}
	
	private func init_tables() {
		let prim: Int = 0x11d
		
		var x = 1
		for i in 0 ..< 255 {
			gf_exp[i] = x
			gf_log[x] = i
			x = gf_mult_noLUT(x, 2, prim)
		}
		for i in 255 ..< 512 {
			gf_exp[i] = gf_exp[i - 255]
		}
	}
	
	private func gf_mult_noLUT(_ pX: Int, _ pY: Int, _ prim: Int) -> Int {
		var r = 0
		var x = pX
		var y = pY
		while y > 0 {
			if y % 2 != 0 {
				r = r ^ x
			}
			y = y >> 1
			x = x << 1
			if prim > 0 && x >= 256 {
				x = x ^ prim
			}
		}
		return r
	}

	private func gf_mul(_ x: Int, _ y: Int) -> Int {
		if x == 0 || y == 0 {
			return 0
		}
		return gf_exp[gf_log[x] + gf_log[y]]
	}

	private func gf_poly_mul(_ p: [Int], _ q: [Int]) -> [Int] {
		var r = [Int](repeating: 0, count: p.count+q.count-1)
		
		for j in 0 ..< q.count {
			for i in 0 ..< p.count {
				r[i+j] ^= gf_mul(p[i], q[j])
			}
		}
		return r
	}

	private func gf_pow(_ x: Int, _ power: Int) -> Int {
		return gf_exp[(gf_log[x] * power) % 255]
	}

	private func rs_generator_poly(_ nsym: Int) -> [Int] {
		var g = [1]
		for i in 0 ..< nsym {
			g = gf_poly_mul(g, [1, gf_pow(2, i)])
		}
		return g
	}
	
	private func getOtherGenPoly() -> [Int] {
		// Source: https://www.thonky.com/qr-code-tutorial/format-version-information
		return [1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1]
	}

	private func rs_encode_message(_ msg_in: [Int], _ nsym: Int, genCase: Case = .data) -> [Int] {
		if msg_in.count + nsym > 255 {
			return [-1]
		}
		
		let gen: [Int]
		if genCase == .data {
			gen = rs_generator_poly(nsym)
		} else {
			gen = getOtherGenPoly()
		}

		var msg_out = [Int](repeating: 0, count: msg_in.count + gen.count-1)
		for i in 0 ..< msg_in.count { msg_out[i] = msg_in[i] }
				
		for i in 0 ..< msg_in.count {
			let coef = msg_out[i]
			
			if (coef != 0) {
				for j in 1 ..< gen.count {
					msg_out[i+j] ^= gf_mul(gen[j], coef)
				}
			}
		}
			
		for i in 0 ..< msg_in.count { msg_out[i] = msg_in[i] }
			
		return msg_out
	}
	
	public func createCode(msg: [Int], amountOfWords amount: Int) -> [Int] {
		var returnVal = rs_encode_message(msg, amount)
		returnVal.removeFirst(msg.count)
		return returnVal
	}
	
	public func createFormatString() -> [Int] {
		// Error Correction Level: M (0) 101000100100101
		// Masking pattern: 1: (row) % 2 == 0
		var formatString = "101000100100101"
		var returnVal = [Int]()
		for _ in 0 ..< formatString.count {
			returnVal.append( Int(String(formatString.first!))! )
			formatString.removeFirst()
		}
		return returnVal
	}
	
	public func createVersionInfo(_ version: Int) -> [Int] {
		let table = ["000111110010010100", "001000010110111100", "001001101010011001", "001010010011010011"]
		// Source: https://www.thonky.com/qr-code-tutorial/format-version-tables
		var entry = table[version-7]
		var returnVal = [Int]()
		for _ in 0 ..< entry.count {
			returnVal.append( Int(String(entry.first!))! )
			entry.removeFirst()
		}
		return returnVal
	}
	
	private enum Case {
		case data, format, versionInfo
	}
}
