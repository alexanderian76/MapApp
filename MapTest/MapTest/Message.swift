//
//  Message.swift
//  MapTest
//
//  Created by Alexander Malygin on 13.02.2021.
//

import Foundation
import UIKit

class Message: UILabel {
    override var intrinsicContentSize: CGSize{
        let orig = super.intrinsicContentSize
        let height = orig.height
        layer.cornerRadius = 20
        return CGSize(width: orig.width, height: orig.height)
    }
}
