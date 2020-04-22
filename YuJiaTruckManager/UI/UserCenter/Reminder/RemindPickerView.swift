//
//  RemindPickerView.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/29.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import MBProgressHUD
import DateToolsSwift

/// 提醒设置控件
class RemindPickerView: UIView {

    
    // MARK: - Public
    
    /// 选择日期的回调
    public  typealias Block = (Date, Date)->()
    public  var selectDateBlock:Block?
    
    /// 选择的s时间
    var chooseDate = Date()
    /// 选择提醒时间的回调
    public  typealias remindTimeBlock = ()->()
    public  var remindAction:remindTimeBlock?
    
    // MARK: - Private
    private let kDefaultPickerViewHeight: CGFloat = 480 ///view的高度
    /// 提前提醒的时间描述
    private var remindTimeStr = String()
    /// 提前提醒时间（分钟）
    private var aheadMinutes = 0
    private let topDatePicker  = UIDatePicker()
    private let backView  = UIView()
    /// 标题
    private let titleLabel = UILabel()
    
    
    // MARK: - Public Property
    
    public init(frame: CGRect, reminTimeDesc: String ,aheadMinutes: Int, chooseDate: Date? = nil) {
        super.init(frame: frame)
        self.remindTimeStr = reminTimeDesc
        self.aheadMinutes = aheadMinutes
        self.chooseDate = chooseDate ?? Date()
        
        setUpUI()
    }
    
    /// 从底部弹出
    public func show(){
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.frame =  CGRect(x: 0, y: UIScreen.main.bounds.size.height-(self?.kDefaultPickerViewHeight ?? 0), width:  self?.frame.size.width ?? 0, height: self?.kDefaultPickerViewHeight ?? 0)
        }) { (complete) in
            
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI(){
        
        let imageView = UIImageView(frame: CGRect(x:0, y:0, width:frame.size.width, height:kDefaultPickerViewHeight))
        imageView.image = UIImage(named:"bg_alarm_detail")
        addSubview(imageView)
        
        
        let rootVC = UIApplication.shared.delegate as! AppDelegate
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapDismiss))
        
        backView.frame =  CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width , height: UIScreen.main.bounds.size.height)
        backView.backgroundColor = UIColor.black
        backView.alpha = 0.5
        backView.addGestureRecognizer(tap)
        rootVC.window?.addSubview(backView)
        
        
        
        
        titleLabel.frame = CGRect (x: 30, y: 20, width: UIScreen.main.bounds.size.width - 60, height: 20)
        titleLabel.text = Date().yd.timeString()
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = mColor(0x333333, 1)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        //创建日期选择器
        topDatePicker.frame = CGRect(x:0, y:60, width:frame.size.width, height:240)
        topDatePicker.datePickerMode = .dateAndTime
        topDatePicker.date = chooseDate
        topDatePicker.minimumDate = Date()
        topDatePicker.addTarget(self, action: #selector(dateChanged),for: .valueChanged)
        
        addSubview(topDatePicker)
        
        let remindBtn = UIButton(frame: CGRect(x:47, y:310, width:frame.size.width - 94, height:40))
        remindBtn.setTitle("提醒", for: .normal)
        remindBtn.contentHorizontalAlignment = .left
        remindBtn.setTitleColor(mColor(0x333333), for:.normal)
        remindBtn.addTarget(self, action:#selector(back(_:)), for:.touchUpInside)
        remindBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        addSubview(remindBtn)
        
        let arrowImageView = UIImageView(frame: CGRect(x:remindBtn.frame.maxX - 9, y:310, width:9, height:16))
        arrowImageView.center = CGPoint(x: arrowImageView.center.x, y: remindBtn.center.y)
        arrowImageView.image = UIImage(named: "arrow_gray_r_9x16")
        addSubview(arrowImageView)
        
        let remindTimeLbl = UILabel(frame: CGRect(x:remindBtn.frame.maxX - 172, y:310, width:150, height:40))
        remindTimeLbl.center = CGPoint(x: remindTimeLbl.center.x, y: remindBtn.center.y)
        remindTimeLbl.textColor = Constants.Color.lightText
        remindTimeLbl.textAlignment = .right
        mLog("【提醒】：\(remindTimeStr)")
        remindTimeLbl.text = remindTimeStr
        addSubview(remindTimeLbl)
        
        let sureBtn = UIButton(frame: CGRect(x:25, y:360, width:frame.size.width-50, height:45))
        sureBtn.addTarget(self, action:#selector(sure(_:)), for:.touchUpInside)
        sureBtn.setBackgroundImage(UIImage(named:"bg_round_orange"), for: .normal)
        sureBtn.setTitle("确定", for: .normal)
        addSubview(sureBtn)
        
        let cancleBtn = UIButton(frame: CGRect(x:25, y:370 + 50, width:frame.size.width-50, height:45))
        cancleBtn.setTitle("取消", for: .normal)
        cancleBtn.backgroundColor = mColor(0xE8E8E8, 1)
        
        cancleBtn.addTarget(self, action:#selector(cancle(_:)), for:.touchUpInside)
        
        addSubview(cancleBtn)
    }
    
    ///点击背景
    @objc func tapDismiss() {
        dismiss()
    }
    
    @objc func cancle(_ button:UIButton){
        dismiss()
        
    }
    
    @objc func back(_ button:UIButton){
        
        remindAction?()
        dismiss()
    }
    
    @objc func sure(_ button:UIButton){
        let remindDate =  chooseDate - (aheadMinutes).minutes
        if remindDate.compare(Date()) == .orderedAscending {
            showMessage(message: "您设置的提醒时间必须大于当前时间")
            return
        }
        
        if selectDateBlock != nil {
            selectDateBlock?(chooseDate, remindDate)
        }
        dismiss()
    }
    
    @objc func dateChanged(datePicker : UIDatePicker){
        //更新提醒时间文本框
        let formatter = DateFormatter()
        //日期样式
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        titleLabel.text = formatter.string(from: datePicker.date)
        chooseDate = datePicker.date
    }
    
    private func dismiss(){
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.frame =  CGRect(x: 0, y: UIScreen.main.bounds.size.height, width:  self?.frame.size.width ?? 0, height: 0)
        }) { [weak self] (complete) in
            self?.removeFromSuperview()
            self?.backView.removeFromSuperview()
        }
        
        
    }
    
    private func showMessage(message :String){
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .text
        hud.bezelView.color = .black
        hud.label.textColor = .white
        hud.label.text = message
        hud.offset.y = UIScreen.main.bounds.size.height / 2
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 2.0)
    }

}
