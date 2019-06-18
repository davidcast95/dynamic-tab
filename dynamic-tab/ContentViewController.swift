//
//  ContentViewController.swift
//  dynamic-tab
//
//  Created by David-UC on 6/16/19.
//  Copyright © 2019 David-DAS. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

    @IBOutlet weak var contentLabel: UILabel!
    var content = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentLabel.text = content
    }
    
}
