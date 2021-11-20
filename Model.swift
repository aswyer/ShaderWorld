//
//  Model.swift
//  Model
//
//  Created by Andrew Sawyer on 9/17/21.
//

import Foundation
import UIKit

class Model: ObservableObject {
    static private let inputImage = UIImage(named: "zion")!
    
    @Published var displayImage: UIImage?
    
    
    let filter = Filter(image: Model.inputImage)
    
    init() {
        let attributes = FilterAttributes(pixelSize: 1)
        update(with: attributes)
    }
    
    func update(with attributes: FilterAttributes) {
        displayImage = filter.applyFilter(with: attributes)
    }
}
