//
//  Generator.swift
//  QRCodeApp
//
//  Created by Theodor Teslia on 04.03.21.
//

import SwiftUI

struct Generator: View {
	private let modeIndicator = "0100"
	private let ec = ErrorCorrector()
	
	@State private var input: String = ""
	
	@State private var bitMessage = [String]()
	@State private var version: Int = 0
	@State private var charCountIndicator: String = ""
	@State private var terminator: String = ""
	@State private var padBytes = [String]()
	
	// UI
    var body: some View {
		VStack {
			TextEditor(text: $input)
				.frame(height: 200)
				.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
				.disableAutocorrection(true)
			
			Button("Generate the Code") {
				self.start()
			}
			.padding()
			
			Spacer()
		}
		.padding()
    }
	// End UI
	
	func start() {
		bitMessage = Helper.ByteModeEncoding(input)
		version = Helper.findCorrectSize(size: input.count)
		if (version == -1) {
			print("Couldn't find a size. Size: \(input.count)")
			return
		}
		charCountIndicator = Helper.encodeCharCountIndicator(version: version, input)
		
		padTheMessage()
		finalizeBitMessage()
		errorCorrection()
	}
	
	func padTheMessage() {
		let neededSize = Helper.getECInfo(version: version, .TOTAL_CODEWORDS) * 8
		var currentSize = (bitMessage.count * 8) + modeIndicator.count + charCountIndicator.count
		
		var difference = neededSize - currentSize
		if (difference < 4) {
			for _ in 0 ..< difference {
				terminator.append("0")
			}
			return
		}
		
		terminator.append("0000")
		
		currentSize += terminator.count
		if currentSize % 8 != 0 {
			for _ in 0 ..< 8 - currentSize % 8 {
				terminator.append("0")
			}
		}
		
		difference = neededSize - ((bitMessage.count * 8) + modeIndicator.count + charCountIndicator.count + terminator.count)
		let numOfNeededWords = difference / 8
		let possiblePadBytes = ["11101100", "00010001"]
		
		for i in 0 ..< numOfNeededWords {
			self.padBytes.append(possiblePadBytes[i%2])
		}
		
	}
	
	func finalizeBitMessage() {
		var finalBitString: String = modeIndicator + charCountIndicator
		for byte in bitMessage {
			finalBitString.append(byte)
		}
		finalBitString.append(terminator)
		for pad in padBytes {
			finalBitString.append(pad)
		}
		
		bitMessage.removeAll()
		while (finalBitString.count > 0) {
			bitMessage.append(String(finalBitString.prefix(8)))
			finalBitString.removeFirst(8)
		}
	}
	
	func errorCorrection() {
		
	}
	
	public enum ECWords: Int {
		case TOTAL_CODEWORDS = 0,  // Total number of data codewords for this version and EC Level
		WORDS_PER_BLOCK,  // EC Codewords per block
		GROUP1_BLOCK_NUM,  // Number of blocks in group 1
		WORD_NUM_GROUP1,  // Number of data codeworks in each of group1's blocks
		GROUP2_BLOCK_NUM,  // Number of blocks in group 2
		WORD_NUM_GROUP2,  // Number of data codeworks in each of group2's blocks
		TOTAL_DATA_CODEWORKS  // Total data codewords
		// Source: https://www.thonky.com/qr-code-tutorial/error-correction-table
	}
}

struct Generator_Previews: PreviewProvider {
    static var previews: some View {
        Generator()
    }
}
