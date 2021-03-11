//
//  Generator.swift
//  QRCodeApp
//
//	This file contains the struct for generating a QR-Code
//	The maximum size is version 10 to make the ec calculation easier
// 	The ec Level M ist always used, as well as the masking pattern number 1
//  The logic is written by me, except the ec algorithms
//	For websites, where I just took the information from, the URL is pasted below
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
	@State private var matrix = [[CodeModule]]()
	
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
	
	// This function is the main function, which is calling every other one
	// Furthermore, it initialises the important variables with values
	func start() {
		bitMessage = Helper.ByteModeEncoding(input.trimmingCharacters(in: .whitespacesAndNewlines))
		version = Helper.findCorrectSize(size: input.count)
		if (version == -1) {
			print("Couldn't find a size. Size: \(input.count)")
			return
		}
		charCountIndicator = Helper.encodeCharCountIndicator(version: version, input)
		
		padTheMessage()
		finalizeBitMessage()
		let str = errorCorrection()
		fillMatrix(str)
	}
	
	// Make the bit message the correct length with the terminatord etc.
	func padTheMessage() {
		let neededSize = Helper.getECInfo(version: version, .TOTAL_CODEWORDS) * 8
		var currentSize = (bitMessage.count * 8) + modeIndicator.count + charCountIndicator.count
		
		var difference = neededSize - currentSize
		if (difference < 4) {  // Calculate if a terminator is needed
			for _ in 0 ..< difference {
				terminator.append("0")
			}
			return
		} else {
			terminator.append("0000")
		}
		
		currentSize += terminator.count  // make the size a multiple of 8
		if currentSize % 8 != 0 {
			for _ in 0 ..< 8 - currentSize % 8 {
				terminator.append("0")
			}
		}
		
		difference = neededSize - ((bitMessage.count * 8) + modeIndicator.count + charCountIndicator.count + terminator.count)
		let numOfNeededWords = difference / 8
		let possiblePadBytes = ["11101100", "00010001"]
		
		for i in 0 ..< numOfNeededWords {  // Fill the complete size of the Code with pad bytes
			self.padBytes.append(possiblePadBytes[i%2])
		}
		
	}
	
	// Finalize the bit string by putting everything in an fitting array in 8-bit byte form
	func finalizeBitMessage() {
		var finalBitString: String = modeIndicator + charCountIndicator
		for byte in bitMessage {
			finalBitString.append(byte)
		}
		finalBitString.append(terminator)
		for pad in padBytes {
			finalBitString.append(pad)
		}
		print(finalBitString)
		
		bitMessage.removeAll()
		while (finalBitString.count > 0) {
			bitMessage.append(String(finalBitString.prefix(8)))
			finalBitString.removeFirst(8)
		}
	}
	
	// Fill and create the ec words for the correct block and groups
	func errorCorrection() -> String {
		var blocks = divideIntoBlocks()
		
		for i in 0 ..< blocks.count {  // Fill the ec words in blocks where it is needed
			if blocks[i].data.count == 0 {
				continue
			}
			var intMsg = [Int]()
			for bin in blocks[i].data {
				intMsg.append(Int(bin, radix: 2) ?? -1)
			}
			let ecWords = ec.createCode(msg: intMsg, amountOfWords: Helper.getECInfo(version: version, .EC_WORDS_PER_BLOCK))
			var temp = [String]()  // Transform the ec words (decimal) to binary
			for dec in ecWords {
				temp.append(String(dec, radix: 2))
			}
			blocks[i].ec = temp
		}
		
		var filledBlocks: [(data: [String], ec: [String])] = []
		for block in blocks {
			if block.data.count != 0 {
				filledBlocks.append(block)
			}
		}
		
		var finalSaveArr: [String] = [String]()
		for index in 0 ..< (filledBlocks.last?.data.count ?? 0) {  // Iterates through columns (thonky tutorial)
			for j in 0 ..< filledBlocks.count {  // Iterates through rows
				if index >= filledBlocks[j].data.count {  // Because the first group can have fewer elements than second
					continue
				}
				finalSaveArr.append(filledBlocks[j].data[index])
			}
		}
		
		for index in 0 ..< (filledBlocks.last?.ec.count ?? 0) {  // Iterates through columns (thonky tutorial)
			for j in 0 ..< filledBlocks.count {  // Iterates through rows
				if index >= filledBlocks[j].ec.count {  // Because the first group can have fewer elements than second
					continue
				}
				finalSaveArr.append(filledBlocks[j].ec[index])
			}
		}
		
		var finalSaveStr: String = finalSaveArr.joined(separator: "")
		
		if ( 2 <= version && version <= 6) {
			finalSaveStr.append("0000000")
		}
		
		return finalSaveStr
	}
	
	// Divide the bit message in blocks so the ec words can be created
	func divideIntoBlocks() -> [(data: [String], ec: [String])] {
		var returnVal: [(data: [String], ec: [String])] = []  // Initialisation
		for _ in 0 ..< 4 {
			returnVal.append( ([String](), [String]()) )
		}
		
		let gr1BlockAmount = Helper.getECInfo(version: version, .GROUP1_BLOCK_NUM)
		var counter = 0
		
		for _ in 0 ..< gr1BlockAmount {  // Fill the first group with the binary information (message data)
			var block = 0
			let wordAmount = Helper.getECInfo(version: version, .WORD_NUM_GROUP1)
			for _ in 0 ..< wordAmount {
				returnVal[block].data.append(bitMessage[counter])
				counter += 1
			}
			block += 1
		}
		
		let gr2BlockAmount = Helper.getECInfo(version: version, .GROUP2_BLOCK_NUM)
		for _ in 0 ..< gr2BlockAmount {  // Fill the second group with the binary information (message data)
			var block = 2
			let wordAmount = Helper.getECInfo(version: version, .WORD_NUM_GROUP2)
			for _ in 0 ..< wordAmount {
				returnVal[block].data.append(bitMessage[counter])
				counter += 1
			}
			block += 1
		}
		
		return returnVal
	}
	
	func fillMatrix(_ str: String) {
		let edgeSize = ((version - 1) * 4) + 21
		matrix = Array(repeating: Array(repeating: CodeModule(), count: edgeSize), count: edgeSize)
		
		matrix = finderPatterns(matrix, x: 0, y: 0)
		matrix = finderPatterns(matrix, x: edgeSize-7, y: 0)
		matrix = finderPatterns(matrix, x: 0, y: edgeSize-7)
	}
	
	
	
	// Word placeolder for getting version-specific information
	public enum ECWords: Int {
		case TOTAL_CODEWORDS = 0,  // Total number of data codewords for this version and EC Level
		EC_WORDS_PER_BLOCK,  // EC Codewords per block
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