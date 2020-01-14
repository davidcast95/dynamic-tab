//
//  ViewController.swift
//  dynamic-tab
//
//  Created by David-UC on 6/16/19.
//  Copyright © 2019 David-DAS. All rights reserved.
//

import UIKit


class ViewController: UIViewController, DynamicTabPageViewDataSource {

    @IBOutlet weak var tabView: UICollectionView!
    @IBOutlet weak var contentView: DynamicTabPageView!
    let tabs = ["TEst1","asfdasdaasfdasda"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.datasource = self
        contentView.setup(viewController: self)
        
    }
    
    func numberOfPage() -> Int {
        return tabs.count
    }
    
    func dynamicTab(titleForPage index: Int) -> String {
        return tabs[index]
    }
    
    func dynamicTab(viewControllerForPage index: Int) -> UIViewController {
        let vc = storyboard?.instantiateViewController(withIdentifier: "content")
        return vc!
    }
    
    func dynamicTab(prepareFor viewController: UIViewController,in index: Int) {
        if let contentVC = viewController as? ContentViewController {
            contentVC.content = tabs[index]
        }
    }
}

