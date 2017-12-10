//
//  DrawMode.swift
//  Sunglassity
//
//  Created by HideakiTouhara on 2017/12/10.
//  Copyright © 2017年 HideakiTouhara. All rights reserved.
//

import Foundation
import UIKit

enum Size: String {
    case big
    case medium
    case small
    
    static let allValues: [Size] = [.big, .medium, .small]
    
    var thickness: CGFloat {
        switch self {
        case .big:
            return 0.005
        case .medium:
            return 0.003
        case .small:
            return 0.001
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .big:
            return 0.5
        case .medium:
            return 0.4
        case .small:
            return 0.3
        }
    }
}

enum Color: String {
    case red
    case blue
    case white
    
    static let allValues: [Color] = [.red, .blue, .white]
    
    var color: UIColor {
        switch self {
        case .red:
            return UIColor.red
        case .blue:
            return UIColor.blue
        case .white:
            return UIColor.white
        }
    }
}
