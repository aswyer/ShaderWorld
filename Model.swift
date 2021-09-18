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
    
    
    private let filter = Filter(image: Model.inputImage)
    
    init() {
        displayImage = filter.applyFilter()
    }
}
