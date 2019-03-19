//
//  ImageBannerPage.swift
//  HKBanner
//
//  Created by Harley-xk on 2019/3/18.
//  Copyright © 2019 Harley. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

open class ImageBannerPage: UIViewController, BannerPageable {
    
    public var item: ImageBannerItem!
    public var index: Int = 0
    
    public var action: ImagePageVendor.Action?
    
    weak var imageView: UIImageView!
    
    override open func loadView() {
        super.loadView()
        
        view.backgroundColor = .clear
        
        /// ImageView
        let imageView = UIImageView(frame: view.bounds)
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        self.imageView = imageView
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(red: CGFloat.random(in: 0.5 ..< 1), green: CGFloat.random(in: 0.5 ..< 1), blue: CGFloat.random(in: 0.5 ..< 1), alpha: 1)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(bannerAction(gesture:)))
        view.addGestureRecognizer(tap)
        
        refreshPageContent()
    }
    
    open func refreshPageContent() {
        
        /// 手动触发 loadView 方法加载
        let _ = self.view
        item.setImageForBanner(imageView: imageView)
    }
    
    @objc func bannerAction(gesture: UITapGestureRecognizer) {
        if gesture.state == .recognized {
            self.action?(index)
        }
    }
}
