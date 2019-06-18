
//
//  TabButton.swift
//  dynamic-tab
//
//  Created by David-UC on 6/16/19.
//  Copyright © 2019 David-DAS. All rights reserved.
//

import UIKit

class TabButton: UIView {

    @IBOutlet weak var tabButton: UIButton!
    @IBOutlet weak var indicatorLine: UIView!
    
    // indicator properties
    @IBInspectable var indicatorHeight: CGFloat = 1.0 {
        didSet {
            indicatorLine.frame = CGRect(origin: indicatorLine.frame.origin, size: CGSize(width: indicatorLine.frame.width, height: indicatorHeight))
        }
    }
    

}
