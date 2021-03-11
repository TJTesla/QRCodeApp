//
//  Module.swift
//  QRCodeApp
//
//  Created by Theodor Teslia on 11.03.21.
//

import Foundation

struct CodeModule {
	private var reserved: Bool
	private var color: Color
	
	init() {
		self.color = .none
		self.reserved = false
	}
	
	init(pColor: Color, reserve: Bool = false) {
		self.color = pColor
		self.reserved = reserve
	}
	
	public func isReserved() -> Bool {
		return self.reserved
	}
	
	public func getColor() -> Color {
		return self.color
	}
	
	public enum Color {
		case white, black, none
	}
}
