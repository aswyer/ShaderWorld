//
//  ContentView.swift
//  ShaderWorld
//
//  Created by Andrew Sawyer on 9/17/21.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var model = Model()
    
    var body: some View {
        HStack {
            Text("Properties")
            if let displayImage = model.displayImage {
                Image(uiImage: displayImage)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
