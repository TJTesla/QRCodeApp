//
//  Module.swift
//  QRCodeApp
//
//  Created by Theodor Teslia on 11.03.21.
//

import Foundation

struct CodeModule {
	private var reserved: ModuleType
	private var color: Color
	
	init() {
		self.color = .none
		self.reserved = .data
	}
	
	init(pColor: Color, reserve: ModuleType = .data) {
		self.color = pColor
		self.reserved = reserve
	}
	
	public func isReserved() -> Bool {
		return self.reserved == .data
	}
	
	public func getPart() -> ModuleType {
		return self.reserved
	}
	
	public func getColor() -> Color {
		return self.color
	}
	
	public enum Color {
		case white, black, none
	}
}

enum ModuleType {
	case finder, separator, alignment
	case vTiming, hTiming
	case format, upVersion, lowVersion
	case data
}
