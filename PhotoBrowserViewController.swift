//
//  PhotoBrowserViewController.swift
//  cars
//
//  Created by Jose Zamudio on 10/8/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import Foundation
import UIKit

class PhotoBrowserViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView = UIScrollView()
    var carArray = NSMutableArray()
    var fileArray = NSMutableArray()
    var pageController = UIPageControl()
    var counter = UILabel()
    var zoomView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView = UIScrollView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.contentSize = CGSizeMake(self.view.frame.width * CGFloat(fileArray.count), self.view.frame.height)
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        for (var i = 0; i < fileArray.count; i++) {
            scrollView.addSubview(self.addPFImageView(fileArray.objectAtIndex(i) as PFFile, atIndex: i))
        }

        counter = UILabel(frame: CGRectMake(0, 35, self.view.frame.width, 30))
        counter.text = "1 of \(fileArray.count)"
        counter.textColor = UIColor.whiteColor()
        counter.textAlignment = .Center
        
        var doneButton = UIButton(frame: CGRectMake(self.view.frame.width - 15 - 82/2, 35, 45, 30))
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        doneButton.layer.borderColor = UIColor(hex: "ffffff").CGColor
        doneButton.layer.borderWidth = 1
        doneButton.layer.cornerRadius = 5
        doneButton.clipsToBounds = true
        doneButton.addTarget(self, action: "dismissModalView", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(scrollView)
        self.view.addSubview(doneButton)
        self.view.addSubview(counter)
    }
    
    func addPFImageView(file:PFFile, atIndex:Int) -> UIScrollView {
        var zoomingScrollView = UIScrollView(frame: CGRectMake(self.view.frame.width * CGFloat(atIndex), 0, self.view.frame.width, self.view.frame.height))
        zoomingScrollView.pagingEnabled = true
        zoomingScrollView.scrollEnabled = false
        zoomingScrollView.minimumZoomScale = 1
        zoomingScrollView.maximumZoomScale = 3
        zoomingScrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        zoomingScrollView.showsHorizontalScrollIndicator = false
        zoomingScrollView.showsVerticalScrollIndicator = false
        zoomingScrollView.delegate = self
        
        var imageView = PFImageView(frame: CGRectMake(0, CGRectGetMidY(self.view.frame) - 150, self.view.frame.width, 250))
        imageView.clipsToBounds = true
        imageView.contentMode = .Center
        imageView.contentMode = .ScaleAspectFill
        imageView.image = UIImage(named: "car_placeholder.jpg")
        imageView.file = file
        imageView.loadInBackground()
        imageView.userInteractionEnabled = true
        imageView.tag = 1
        
        var tap = UITapGestureRecognizer(target: self, action: "dismissModalView")
        imageView.addGestureRecognizer(tap)
        
        zoomingScrollView.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.height)
        zoomingScrollView.addSubview(imageView)
        
        return zoomingScrollView
    }
    
    func dismissModalView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}


extension PhotoBrowserViewController:UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x,y: 0)
        
        var pageWidth:CGFloat = self.scrollView.frame.size.width
        var fractionalPage:Double = Double(self.scrollView.contentOffset.x / pageWidth)
        var page:NSInteger = lround(fractionalPage)
        
        counter.text = "\(page + 1) of \(fileArray.count)"
    }
    
    func viewForZoomingInScrollView(sv: UIScrollView) -> UIView? {
        return sv.viewWithTag(1)
    }
}