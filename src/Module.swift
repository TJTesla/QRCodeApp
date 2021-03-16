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
	private var value: Int
	
	init() {
		self.color = .none
		self.reserved = .data
		self.value = -1
	}
	
	init(pColor: Color, reserve: ModuleType = .data) {
		self.color = pColor
		self.reserved = reserve
		self.value = -1
	}
	
	public mutating func setValue(_ pValue: Int) {
		self.value = pValue
	}
	
	public func getValue() -> Int {
		return self.value
	}
	
	public func isReserved() -> Bool {
		return self.reserved != .data
	}
	
	public func getPart() -> ModuleType {
		return self.reserved
	}
	
	public func getColor() -> Color {
		return self.color
	}
	
	public mutating func switchColor() {
		if self.color == .black {
			self.color = .white
		} else {
			self.color = .black
		}
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
