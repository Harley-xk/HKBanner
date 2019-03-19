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
        options.isCyclic = false
        options.pageInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        options.bannerInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        options.autoScrollDelay = 3
//        options.pageEngineType = .pageController
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
            "http://seopic.699pic.com/photo/40006/5720.jpg_wh1200.jpg",
            "https://img.pconline.com.cn/images/upload/upc/tx/itbbs/1807/03/c0/95475558_1530549524482_mthumb.jpg",
            "http://image.jisuxz.com/desktop/1924/jisuxz_fengjingsheying_201801_09.jpg",
            "https://desk-fd.zol-img.com.cn/t_s960x600c5/g5/M00/02/01/ChMkJ1bKxJuIC9j4AA0ddWOyVH8AALHJgNVISwADR2N309.jpg",
            "http://yangqinchuan.com/wp-content/uploads/2017/07/8294_2560x1600.jpg",
            "http://seopic.699pic.com/photo/40098/2544.jpg_wh1200.jpg",
            "http://seopic.699pic.com/photo/40007/2702.jpg_wh1200.jpg",
            ]) { (index) in
                print("Taped at index: \(index)")
        }
        
        banner.reload(with: imagePageVendor)
//        banner.reload(with: imagePageVendor, beginIndex: 3)
    }
    
    
}

