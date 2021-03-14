//
//  Information.swift
//  QRCodeApp
//
//  Created by Theodor Teslia on 04.03.21.
//

import SwiftUI

struct Information: View {
	var body: some View {
		Text("Diese App ist der Praktische Teil meiner Facharbeit im Fach Informatik. Der Code ist von mir geschrieben, ausser es ist in den Kommentaren anders beschrieben. Die App kann mithilfe einer eingegeben Nachricht einen eigenen Code erstellen. Dafür wird [...] benutzt. Des weiteren kann sie mit Hilfe von [...] QR-Codes Scannen und deren Inhalt ausgeben.\nDer Generator:\nDer Generator benutzt nur den Bytee Modus zum codieren von Zeichen, sowie nur die Fehlerkorrektur-Stufe M. Dies liegt daran, um das Programm zu vereinfachen. Wobei die Implementation der anderen Kodierungsmethoden und Fehlerkorrektur-Stufen hauptsächlich aus dem Abrufen aus Datenbanken bestände, was ich mir ersparen möchte. Die Größe des QR-Codes habe ich auf maximal 10 begrenzt. Dies kommt daher, dass dies die einfachste Größe (Galois-Feld: 2^8) für das Fehler-Korrekturverfahren ist, weshalb auch alle Anleitungen nur für diese ist und ich mich sehr stark auf diese stützen muss. Dadurch ist die maximal mögliche Anzahl der Zeichen zur Verschlüsselung 216.\nDen Großteil der Informationen habe ich aus dem folgenden Tutorial zu QR-Codes: https://www.thonky.com/qr-code-tutorial/")
			.padding()
		Spacer()
	}
}
