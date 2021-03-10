//
//  ContentView.swift
//  QRCodeApp
//
//  Created by Theodor Teslia on 04.03.21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		NavigationView {
			VStack {
				NavigationLink(destination: Generator()) {
					Text("Generator")
				}
				.padding()
				NavigationLink(destination: Text("Scanner")) {
					Text("Scanner")
				}
				.padding()
				Spacer()
				NavigationLink(destination: Information()) {
					Text("Click here for more information about this app")
				}
				.padding([.bottom], 50)
			}
			.navigationBarTitle("QR-Code App")
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
			.previewDevice("iPhone X")
    }
}
