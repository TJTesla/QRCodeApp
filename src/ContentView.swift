//
//  ContentView.swift
//  This file contains the main algorithm for generating a QR-Code from Scratch
//  The generated QR-Code can go up to version 10,
//  has the errorcorrection level M and the maaking pattern 1
//  The Code is drawn with CoreImage onto an UIImage, which then is converted to an Image
//  The logic is written by me, however a few functions, as well as the ECC is coming from someone else
//  However, I have given credit at the points, where this occurs
//
//  Created by Theodor Teslia on 04.03.21.
//

import SwiftUI
import CoreImage


// Gives the fuction to hide the keyboard
// Taken from: https://www.hackingwithswift.com/quick-start/swiftui/how-to-dismiss-the-keyboard-for-a-textfield
#if canImport(UIKit)
extension View {
	func hideKeyboard() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
#endif // canImport(UIKit)

struct ContentView: View {
	private let modeIndicator = "0100"
	private let ec = ErrorCorrector()
	
	@State private var input: String = ""
	
	@State private var bitMessage = [String]()
	@State private var version: Int = 0
	@State private var charCountIndicator: String = ""
	@State private var terminator: String = ""
	@State private var padBytes = [String]()
	@State private var matrix = [[CodeModule]]()
	
	@State private var finishedCode: Image?
	
	// UI
	var body: some View {
		Text("QR-Code App")
			.font(.largeTitle)
			.padding()
		VStack(alignment: .leading, spacing: 5) {
			TextEditor(text: $input)
				.frame(height: 120)
				.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
				.disableAutocorrection(true)
			HStack {
				Button("Generate the Code") {
					hideKeyboard()
					self.start()
					self.createImage()
				}
				.padding()
				Button("Dismiss keyboard") {
					hideKeyboard()
				}
				.font(.system(size: 11))
				.frame(width: 50)
				.padding()
			}
			
			finishedCode?
				.resizable()
				.aspectRatio(contentMode: .fit)
				.scaledToFit()
			
			Spacer()
		}
		.padding()
	}
	// End UI
	
	// Draw the finished QR-Code on an image
	// Source: https://www.hackingwithswift.com/read/27/3/drawing-into-a-core-graphics-context-with-uigraphicsimagerenderer
	// The source just gave the info about how to draw on an UIImage
	func createImage() {
		let size = (matrix.count + 8) * 10
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
		let rectImage = renderer.image { ctx in
			// Draw code
			for row in 0 ..< matrix.count {
				for cell in 0 ..< matrix[row].count {
					
					if matrix[row][cell].getColor() == .black {
						let rectangle = CGRect(x: (cell+4)*10, y: (row+4)*10, width: 10, height: 10)
						ctx.cgContext.setFillColor(UIColor.black.cgColor)
						ctx.cgContext.addRect(rectangle)
						ctx.cgContext.drawPath(using: .fill)
					} else if matrix[row][cell].getColor() == .white {  // Needed for when dark mode is activated
						let rectangle = CGRect(x: (cell+4)*10, y: (row+4)*10, width: 10, height: 10)
						ctx.cgContext.setFillColor(UIColor.white.cgColor)
						ctx.cgContext.addRect(rectangle)
						ctx.cgContext.drawPath(using: .fill)
					}
					
				}
			}
			
		}
		finishedCode = Image(uiImage: rectImage)
	}
	
	// This function is the main function, which is calling every other one
	// Furthermore, it initialises the important variables with values
	func start() {
		bitMessage.removeAll()  // Reset all values if new QR-Code has to be generated
		version = 0
		charCountIndicator = ""
		terminator = ""
		padBytes.removeAll()
		
		input = input.trimmingCharacters(in: .whitespacesAndNewlines)
		if input.count == 0 {  // Make sure that the message is not empty
			return
		}
		
		// Initialise all values
		bitMessage = Helper.ByteModeEncoding(input)
		version = Helper.findCorrectSize(size: input.count)
		if (version == -1) {
			print("Couldn't find a size. Size: \(input.count)")
			return
		}
		charCountIndicator = Helper.encodeCharCountIndicator(version: version, input)
		
		// Start the algorithm
		padTheMessage()
		finalizeBitMessage()
		let str = errorCorrection()
		fillMatrix(str)
	}
	
	// Make the bit message the correct length with the terminator etc.
	func padTheMessage() {
		let neededSize = Helper.getECInfo(version: version, .TOTAL_CODEWORDS) * 8
		var currentSize = (bitMessage.count * 8) + modeIndicator.count + charCountIndicator.count
		
		// Calculate if a terminator is needed
		var difference = neededSize - currentSize
		if (difference < 4) {
			for _ in 0 ..< difference {
				terminator.append("0")
			}
			return
		} else {
			terminator.append("0000")
		}
		
		// Make the size a multiple of 8
		currentSize += terminator.count
		if currentSize % 8 != 0 {
			for _ in 0 ..< 8 - currentSize % 8 {
				terminator.append("0")
			}
		}
		
		// Fill the complete size of the Code with pad bytes
		difference = neededSize - ((bitMessage.count * 8) + modeIndicator.count + charCountIndicator.count + terminator.count)
		let numOfNeededWords = difference / 8
		let possiblePadBytes = ["11101100", "00010001"]
		
		for i in 0 ..< numOfNeededWords {
			self.padBytes.append(possiblePadBytes[i%2])
		}
	}
	
	// Finalize the bit string by putting everything in an fitting array in 8-bit byte form
	func finalizeBitMessage() {
		// Create string by appending everything
		var finalBitString: String = modeIndicator + charCountIndicator
		for byte in bitMessage {
			finalBitString.append(byte)
		}
		finalBitString.append(terminator)
		for pad in padBytes {
			finalBitString.append(pad)
		}
		
		// Save that string in an array with 8-bit bytes
		bitMessage.removeAll()
		while (finalBitString.count > 0) {
			bitMessage.append(String(finalBitString.prefix(8)))
			finalBitString.removeFirst(8)
		}
	}
	
	// Fill and create the ec words for the correct block and groups
	func errorCorrection() -> String {
		var blocks:[(data: [String], ec: [String])] = divideIntoBlocks()
		
		// Fill the ec words in blocks
		for i in 0 ..< blocks.count {
			if blocks[i].data.count == 0 {
				continue
			}
			// Transform the binary data codewords to decimal numbers
			var intMsg = [Int]()
			for bin in blocks[i].data {
				intMsg.append(Int(bin, radix: 2) ?? -1)
			}
			
			let ecWords = ec.createCode(msg: intMsg, amountOfWords: Helper.getECInfo(version: version, .EC_WORDS_PER_BLOCK))
			// Transform the ec words (decimal) to binary
			var temp = [String]()
			for dec in ecWords {
				var byte = String(dec, radix: 2)
				byte = Helper.padLeft(toSize: 8, message: byte)
				temp.append(byte)
			}
			blocks[i].ec = temp
		}
		
		// Create the final, interleaved message
		// Initialise final structure for saving
		var filledBlocks: [(data: [String], ec: [String])] = []
		for block in blocks {
			if block.data.count != 0 {
				filledBlocks.append(block)
			}
		}
		
		// Fill strucuture with interleaved data codewords
		var finalSaveArr: [String] = [String]()
		for index in 0 ..< (filledBlocks.last?.data.count ?? 0) {  // Iterates through columns (thonky tutorial)
			for j in 0 ..< filledBlocks.count {  // Iterates through rows
				if index >= filledBlocks[j].data.count {  // Because the first group can have fewer elements than second
					continue
				}
				finalSaveArr.append(filledBlocks[j].data[index])
			}
		}
		
		// Fill strucuture with interleaved ec codewords
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
		let absBlockNum = Helper.getECInfo(version: version, .GROUP1_BLOCK_NUM) + Helper.getECInfo(version: version, .GROUP2_BLOCK_NUM)
		for _ in 0 ..< absBlockNum {
			returnVal.append( ([String](), [String]()) )
		}
		
		let gr1BlockAmount = Helper.getECInfo(version: version, .GROUP1_BLOCK_NUM)
		var counter = 0
		var block = 0
		
		for _ in 0 ..< gr1BlockAmount {  // Fill the first group with the binary information (message data)
			let wordAmount = Helper.getECInfo(version: version, .WORD_NUM_GROUP1)
			for _ in 0 ..< wordAmount {
				returnVal[block].data.append(bitMessage[counter])
				counter += 1
			}
			block += 1
		}
		
		let gr2BlockAmount = Helper.getECInfo(version: version, .GROUP2_BLOCK_NUM)
		for _ in 0 ..< gr2BlockAmount {  // Fill the second group with the binary information (message data)
			let wordAmount = Helper.getECInfo(version: version, .WORD_NUM_GROUP2)
			for _ in 0 ..< wordAmount {
				returnVal[block].data.append(bitMessage[counter])
				counter += 1
			}
			block += 1
		}
		
		return returnVal
	}
	
	func fillMatrix(_ msg: String) {
		let edgeSize = ((version - 1) * 4) + 21
		matrix = Array(repeating: Array(repeating: CodeModule(), count: edgeSize), count: edgeSize)
		
		matrix = finderPatterns(matrix, x: 0, y: 0)
		matrix = finderPatterns(matrix, x: edgeSize-7, y: 0)
		matrix = finderPatterns(matrix, x: 0, y: edgeSize-7)
		
		matrix = separator(matrix, corner: .lowerLeft)
		matrix = separator(matrix, corner: .upperRight)
		matrix = separator(matrix, corner: .upperLeft)
		
		matrix = alignmentPattern(matrix, version)
		matrix = timingPatterns(matrix)
		matrix = darkModule(matrix, version)
		matrix = formatStringAndVersionInformation(matrix, version)
		
		matrix = fillWithMsg(matrix, pMsg: msg)
		matrix = masking(matrix)
	}
	
	func masking(_ pMatrix: [[CodeModule]]) -> [[CodeModule]] {
		// Always using mask pattern 1
		// Every even number of rows is masked
		var vMatrix = pMatrix
		
		for row in 0 ..< vMatrix.count {
			if row % 2 != 0 {
				continue
			}
			for column in 0 ..< vMatrix[row].count {
				if vMatrix[row][column].isReserved() {
					continue
				}
				vMatrix[row][column].switchColor()
			}
		}
		
		return vMatrix
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
			.previewDevice("iPhone X")
    }
}
