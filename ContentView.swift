//
//  ContentView.swift
//  ShaderWorld
//
//  Created by Andrew Sawyer on 9/17/21.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var model = Model()
    @State var lastScaleValue: CGFloat = 1.0
    
    @State var scale = 4.0
    
    var body: some View {
        VStack {
            
            
            if let displayImage = model.displayImage {
                Image(uiImage: displayImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    //.scaleEffect(scale)
//                    .gesture(MagnificationGesture().onChanged { val in
//                                let delta = val / self.lastScaleValue
//                                self.lastScaleValue = val
//                                let newScale = self.scale * delta
//
//                    //... anything else e.g. clamping the newScale
//                    }.onEnded { val in
//                      // without this the next gesture will be broken
//                      self.lastScaleValue = 1.0
//                    })
            }
            Slider(value: $scale, in: 1...64) { didChange in
                model.update(with: FilterAttributes(pixelSize: Int(scale)))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
