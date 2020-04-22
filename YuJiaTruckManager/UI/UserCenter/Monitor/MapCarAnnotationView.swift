//
//  MapCarAnnotationView.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/29.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import SnapKit

/// 地图车辆标记view
class MapCarAnnotationView: BMKAnnotationView {
    
    /// 车牌号
    var carLicence: String? {
        didSet {
            carLicenceLbl.text = carLicence
        }
    }
    
    /// 背景图
    var bgImage: UIImage? {
        set {
            bgImageView.image = newValue
        } get {
            return bgImageView.image
        }
    }
    
    /// 附加信息
    var infoDic = [String:Any?]()
    
    // ui
    private var carLicenceLbl = UILabel()
    private var bgImageView = UIImageView()
    
    init!(annotation: BMKAnnotation!, reuseIdentifier: String!, isShowCarPoint: Bool = false) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView(isShowCarPoint: isShowCarPoint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(isShowCarPoint: Bool) {
        
        if isShowCarPoint {
            bounds = CGRect(x: 0, y: 0, width: 134, height: 82)
            centerOffset = CGPoint(x: 0, y: -20)
        } else {
            bounds = CGRect(x: 0, y: 0, width: 134, height: 58)
        }
        
        addSubview(bgImageView)
        
        bgImageView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview()
            maker.top.equalToSuperview()
            maker.right.equalToSuperview()
            maker.height.equalTo(58)
        }
        
        if isShowCarPoint {
            
            let pointImageView = UIImageView(image: UIImage(named: "icon_carCircle"))
            addSubview(pointImageView)
            pointImageView.snp.makeConstraints { (maker) in
                maker.bottom.equalToSuperview()
                maker.centerX.equalToSuperview()
                maker.width.equalTo(32)
                maker.height.equalTo(32)
            }
        }
        
        addSubview(carLicenceLbl)
        carLicenceLbl.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(46)
            maker.right.equalToSuperview().offset(-18)
            maker.centerY.equalTo(bgImageView).offset(-2)
        }
        
        carLicenceLbl.font = UIFont.systemFont(ofSize: 14)
        carLicenceLbl.textColor = .white
        carLicenceLbl.textAlignment = .center
        carLicenceLbl.adjustsFontSizeToFitWidth = true
        
    }
    
}
