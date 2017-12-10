//
//  DrawMode.swift
//  Sunglassity
//
//  Created by HideakiTouhara on 2017/12/10.
//  Copyright © 2017年 HideakiTouhara. All rights reserved.
//

import Foundation
import UIKit

enum Thickness: String {
    case thick
    case medium
    case thin
    
    static let allValues: [Thickness] = [.thick, .medium, .thin]
    
    var thickness: CGFloat {
        switch self {
        case .thick:
            return 0.005
        case .medium:
            return 0.003
        case .thin:
            return 0.001
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
