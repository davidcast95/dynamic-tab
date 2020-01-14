//
//  DynamicTabTableView.swift
//  dynamic-tab
//
//  Created by David-UC on 6/18/19.
//  Copyright © 2019 David-DAS. All rights reserved.
//

import UIKit

protocol DynamicTabPageViewDataSource {
    func numberOfPage() -> Int
    func dynamicTab(titleForPage index: Int) -> String
    func dynamicTab(viewControllerForPage index: Int) -> UIViewController
    func dynamicTab(prepareFor viewController: UIViewController,in index: Int)
}

@objc enum TabStyle: Int {
    case condensed = 0
    case expanded = 1
}

class DynamicTabPageView: UIView {
    @IBOutlet weak var tabView: UICollectionView!
    
    @IBInspectable var tabStyle: TabStyle = .condensed
    
    // delegate
    var datasource: DynamicTabPageViewDataSource?
    
    // page view controller
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var pagesViewController:[UIViewController] = []
    var tabTitles:[String] = []
    var currentIndex = 0
    
    private var tabScrollOffset:CGPoint = .zero
    
    
    // indicator properties
    private let indicatorLine = UIView()
    var indicatorWidth:CGFloat = 1.0
    var indicatorColor:UIColor = .black
    
    // tab properties
    var tabFont = UIFont.systemFont(ofSize: 17)
    var margin:CGFloat = 20.0
    
    func setup(viewController: UIViewController) {
        
        // assign page view controller to content view (connect to iboutlet)
        addSubview(pageViewController.view)
        pageViewController.didMove(toParent: viewController)
        
        // set self to datasource and delegate of page view controller
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        // populate page view controller datasource
        if let numberOfPages = datasource?.numberOfPage() {
            
            for i in 0..<numberOfPages {
                if let vc = datasource?.dynamicTab(viewControllerForPage: i), let tabTitle = datasource?.dynamicTab(titleForPage: i) {
                    tabTitles.append(tabTitle)
                    pagesViewController.append(vc)
                    datasource?.dynamicTab(prepareFor: vc, in: i)
                }
            }
        }
        
        // initate first view controller to page view controller
        if let firstViewController = pagesViewController.first {
            pageViewController.setViewControllers([firstViewController],
                                                  direction: .forward,
                                                  animated: true,
                                                  completion: nil)
        }
        
        // set assign scrollview delegate of page view controller
        for view in pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.tag = 1
                scrollView.delegate = self
            }
        }
        
        // generate tabs
        tabView.register(UINib(nibName: "TabButtonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "tab-button")
        tabView.delegate = self
        tabView.dataSource = self
        
        if let layout = tabView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        
        layoutIfNeeded()
        // generate indicator
        if let firstTitle = tabTitles.first {
            
            let tabWidth = tabStyle == .condensed ? tabView.frame.size.width / CGFloat(tabTitles.count) : calculateOffsetTabLabel(index: 0)
            
            indicatorLine.frame = CGRect(x: tabView.frame.origin.x, y: 0, width: tabWidth, height: 2)
            indicatorLine.backgroundColor = indicatorColor
            self.addSubview(indicatorLine)
            self.bringSubviewToFront(indicatorLine)
        }
    }
    
    func calculateWidthTabLabel(label: String) -> CGFloat {
        let calculatedLabelSize = NSString(string: label).size(withAttributes: [NSAttributedString.Key.font : tabFont])
        return tabStyle == .condensed ? tabView.frame.size.width / CGFloat(tabTitles.count) + 20 + (margin * 2) : calculatedLabelSize.width + 20 + (margin * 2)
    }
    
    func calculateOffsetTabLabel(index: Int) -> CGFloat {
        var totalOffset:CGFloat = 0.0
        for i in 0..<index {
            totalOffset += tabStyle == .condensed ? tabView.frame.size.width / CGFloat(tabTitles.count) : calculateWidthTabLabel(label: tabTitles[i])
        }
        return totalOffset
    }
}

extension DynamicTabPageView: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentIndex = self.pagesViewController.firstIndex(of: viewController){
            if currentIndex - 1 >= 0 {
                return pagesViewController[currentIndex - 1]
            } else {
                return nil
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentIndex = pagesViewController.firstIndex(of: viewController){
            if currentIndex + 1 < pagesViewController.count{
                return pagesViewController[currentIndex + 1]
            } else {
                return nil
            }
        }
        return nil
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let vc = pageViewController.viewControllers?.first {
                if let currentIndex = pagesViewController.firstIndex(of: vc){
                    self.currentIndex = currentIndex
                }
            }
        }
    }
}

extension DynamicTabPageView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 1 {
            let offset = scrollView.contentOffset.x - self.frame.width
            if offset > 0 && currentIndex + 1 < tabTitles.count{
                
                let factor = offset / self.frame.width
                
                let lastWidth = calculateOffsetTabLabel(index: currentIndex)
                let currentTabTitle = tabTitles[currentIndex]
                let currentWidth = calculateWidthTabLabel(label: currentTabTitle)
                
                indicatorLine.frame.origin.x = (currentWidth * factor) + lastWidth - tabScrollOffset.x
                
                let nextTabTitle = tabTitles[currentIndex + 1]
                let nextWidth = calculateWidthTabLabel(label: nextTabTitle)
                indicatorLine.frame.size.width = currentWidth + ((nextWidth - currentWidth) * factor)
                
                
            } else if currentIndex - 1 >= 0 {
                
                let factor = offset / self.frame.width
                
                let lastWidth = calculateOffsetTabLabel(index: currentIndex)
                let currentTabTitle = tabTitles[currentIndex]
                let currentWidth = calculateWidthTabLabel(label: currentTabTitle)
                
                let prevTabTitle = tabTitles[currentIndex - 1]
                let prevWidth = calculateWidthTabLabel(label: prevTabTitle)
                
                indicatorLine.frame.origin.x = lastWidth + (prevWidth * factor) - tabScrollOffset.x
                indicatorLine.frame.size.width = currentWidth - ((prevWidth - currentWidth) * factor)
                
            }
        } else {
            print("Tab \(scrollView.contentOffset.x) \(self.frame.width)")
            tabScrollOffset = scrollView.contentOffset
            let lastWidth = calculateOffsetTabLabel(index: currentIndex)
            indicatorLine.frame.origin.x = lastWidth - scrollView.contentOffset.x
            
        }
    }
    
}

extension DynamicTabPageView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabTitles.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tab-button", for: indexPath) as? TabButtonCollectionViewCell {
            cell.tabLabel.text = tabTitles[indexPath.row]
            cell.tabLabel.font = tabFont
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentIndex == indexPath.row {
            return
        }
        
        pageViewController.setViewControllers([pagesViewController[indexPath.row]], direction: .forward, animated: false, completion: nil)
        
        let lastWidth = calculateOffsetTabLabel(index: indexPath.row)
        let nextTabTitle = tabTitles[indexPath.row]
        let nextWidth = tabStyle == .condensed ? collectionView.frame.size.width / CGFloat(tabTitles.count) : calculateWidthTabLabel(label: nextTabTitle)
        UIView.animate(withDuration: 0.25, animations: {
            self.indicatorLine.frame.origin.x = lastWidth - self.tabScrollOffset.x
            self.indicatorLine.frame.size.width = nextWidth
        }) { (complete) in
            self.currentIndex = indexPath.row
        }
        
    }
    
}

extension DynamicTabPageView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let tabWidth = tabStyle == .condensed ? collectionView.frame.size.width / CGFloat(tabTitles.count) : calculateWidthTabLabel(label: tabTitles[indexPath.row])
        
        return CGSize(width: tabWidth, height: collectionView.frame.height)
    }
}
