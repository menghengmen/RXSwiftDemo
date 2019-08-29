//
//  HorizontalBarItemView.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/31.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//
//  横向柱状图组件

import UIKit
import SnapKit
import YuDaoComponents

/// 横向柱状图组件
class HorizontalBarItemView: UIView {
    
    // MARK: - Public
    
    /// 标题
    var title: String = "" {
        didSet {
            titleLbl.text = title
        }
    }
    /// 数值
    var value: Int = 0
    /// 最大值
    var max: Int = 0
    
    /// 刷新柱状图
    func reload(value: Int, max: Int) {
        self.value = value
        self.max = max
        reloadValueLength()
        setNeedsLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reloadValueLength()
    }
    
    // MARK: - Private
    
    // ui
    private var titleLbl = UILabel()
    private var valueLbl = UILabel()
    private var valueView = UIView()
    private var maxView = UIView()
    
    /// 初始化
    private func setupView() {
        
        addSubview(maxView)
        maxView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(120)
            maker.right.equalToSuperview().offset(-16)
            maker.height.equalTo(16)
        }
        maxView.backgroundColor = Constants.Color.gray
        
        maxView.addSubview(valueView)
        valueView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.width.equalTo(0)
        }
        valueView.backgroundColor = Constants.Color.cyanColor
        valueView.clipsToBounds = false
        
        valueView.addSubview(valueLbl)
        valueLbl.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.right.equalToSuperview().offset(-2)
        }
        valueLbl.textColor = .white
        valueLbl.textAlignment = .right
        valueLbl.font = UIFont.systemFont(ofSize: 10)
        
        addSubview(titleLbl)
        titleLbl.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(maxView)
            maker.right.equalTo(maxView.snp.left).offset(-6)
        }
        titleLbl.font = UIFont.systemFont(ofSize: 12)
        titleLbl.textColor = Constants.Color.lightText
    }
    
    /// 更新长度
    private func reloadValueLength() {
        
        var valueViewWidth: CGFloat = 0
        var valueLblRight: CGFloat = -2
        
        if value == 0 || max == 0 {
            valueLbl.text = nil
        } else {
            let valueTxt = "\(value)"
            valueLbl.text = valueTxt
            valueViewWidth = CGFloat(value) / CGFloat(max) * maxView.frame.width
            /// 如果字太长就移到外面
            let valueTxtWidth = valueTxt.yd.size(withFont: valueLbl.font, limitWidth: CGFloat.greatestFiniteMagnitude).width
            if valueTxtWidth > valueViewWidth {
                valueLblRight = valueTxtWidth + 2
                valueLbl.textColor = valueView.backgroundColor
            } else {
                valueLbl.textColor = .white
            }
        }
        
        valueView.snp.updateConstraints { (maker) in
            maker.width.equalTo(valueViewWidth)
        }
        valueLbl.snp.updateConstraints { (maker) in
            maker.right.equalToSuperview().offset(valueLblRight)
        }
        
    }
    
}
