//
//  ViewController.swift
//  HKBanner-Samples
//
//  Created by Harley-xk on 2019/3/14.
//  Copyright © 2019 Harley. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import HKBanner

extension String: ImageBannerItem {
    public func setImageForBanner(imageView: UIImageView) {
        let url = URL(string: self)
        imageView.kf.setImage(with: url)
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var options = BannerOptions()
        options.isCyclic = true
        options.pageInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        options.bannerInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        options.autoScrollDelay = 3
        options.pageEngineType = .scrollView
        options.pageSpacing = 10
        
        let pageIndicator = DashPageIndicator()        
        options.pageIndicator = pageIndicator
        
        let banner = Banner(options: options)
        view.addSubview(banner)
        banner.snp.makeConstraints {
            $0.top.equalToSuperview().inset(50)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(200)
        }
        
        let imagePageVendor = ImagePageVendor<ImageBannerPage>(items: [
            "http://p1.pstatp.com/origin/2a4100008d310b5fd8a8",
            "http://pic1.win4000.com/wallpaper/3/56f508af0c640.jpg",
            "http://up.deskcity.org/pic_source/49/5f/cc/495fcc7d53635b17a341dd682e026b6b.jpg",
            "http://yangqinchuan.com/wp-content/uploads/2017/07/8294_2560x1600.jpg",
            "http://img2.1sucai.com/181006/330816-1Q006164G665.jpg",
            "http://image5.apbianmin8.com/wallpaper/Landscape%20Wallpapers/10157_1280x800.jpg",
            ]) { (index) in
                print("Taped at index: \(index)")
        }
        
        banner.reload(with: imagePageVendor)
//        banner.reload(with: imagePageVendor, beginIndex: 3)
    }
    
    
}

