//
//  SmartVoiceView.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/12/24.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit

/// 智能语音悬浮视图
class SmartVoiceView: UIView {
    
    public let button = UIButton()
    public let imageView = UIImageView()
    /// 中心点
    public var destiPoint = CGPoint()
    /// 点击的回调
    public  typealias clickBlock = ()->()
    public  var clickAction:clickBlock?
    
    public  override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    private func configUI(){
        button.frame = bounds
        button.addTarget(self, action:#selector(click(_:)), for:.touchUpInside)
        imageView.frame = bounds
        imageView.image =  UIImage(named:"icon_robot")
        addSubview(imageView)
        addSubview(button)
        /// 添加手势
       // let swipeUp = UIPanGestureRecognizer(target:self, action:#selector(panGesture(_:)))
       // addGestureRecognizer(swipeUp)
        
    }
    /// 点击事件
    @objc func click(_ button:UIButton){
        clickAction?()
    }
  
    /// 手势处理
    @objc func panGesture(_ panGesture:UIPanGestureRecognizer){
      let point = panGesture.translation(in: self)
        if panGesture.state == .began{
            destiPoint = center
        }
        
        var spaceHeight =  CGFloat()
        spaceHeight = CGFloat(UIScreen.main.bounds.size.height) - spaceHeight
        
        let maxX = superview?.frame.size.width ?? 0 - frame.size.width/2
        let maxY = spaceHeight - frame.size.height/2
        let middleX = ((superview?.frame.size.width)!)/2
        let minX = frame.size.width/2
        let minY = frame.size.height/2
        
        var tmpCenter = CGPoint(x:destiPoint.x + point.x , y: destiPoint.y + point.y)
        if (tmpCenter.x > maxX) {
            tmpCenter.x = maxX
        }
        if (tmpCenter.y > maxY) {
            tmpCenter.y = maxY
        }
        if (tmpCenter.x < minX) {
            tmpCenter.x = minX
            
        }
        if (tmpCenter.y < minY) {
            tmpCenter.y = minY
        }

        if panGesture.state == .ended || panGesture.state == .cancelled{
            tmpCenter.x = (tmpCenter.x < middleX) ? minX : maxX
            
        }
        center = tmpCenter
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
