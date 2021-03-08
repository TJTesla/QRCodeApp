//
//  Information.swift
//  QRCodeApp
//
//  Created by Theodor Teslia on 04.03.21.
//

import SwiftUI

struct Information: View {
	var body: some View {
		Text("Diese App ist der Praktische Teil meiner Facharbeit im Fach Informatik. Der Code ist von mir geschrieben, ausser es ist in den Kommentaren anders beschrieben. Die App kann mithilfe einer eingegeben Nachricht einen eigenen Code erstellen. Dafür wird [...] benutzt. Des weiteren kann sie mit Hilfe von [...] QR-Codes Scannen und deren Inhalt ausgeben.\nDer Generator:\nDer Generator benutzt nur den Bytee Modus zum codieren von Zeichen, sowie nur die Fehlerkorrektur-Stufe M. Dies liegt daran, um das Programm zu vereinfachen. Wobei die Implementation der anderen Kodierungsmethoden und Fehlerkorrektur-Stufen hauptsächlich aus dem Abrufen aus Datenbanken bestände, was ich mir ersparen möchte. Deshalb habe ich auch die maximale Größe des generierten Codes auf Version 20, also 97x97 Module, beschränkt, da der einzige Unterschied wäre, dass ich bloß mehrer Tabellen weiter abschreiebn gemusst hätte, was ja aber nicht das Zeil der Projektarbeit war.\nDen Großteil der Informationen habe ich aus dem folgenden Tutorial zu QR-Codes: https://www.thonky.com/qr-code-tutorial/")
			.padding()
		Spacer()
	}
}
