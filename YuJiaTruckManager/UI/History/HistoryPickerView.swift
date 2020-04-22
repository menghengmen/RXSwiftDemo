//
//  HistoryPickerView.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/6.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import MBProgressHUD
import DateToolsSwift

/// 自定义日期弹框
class HistoryPickerView: UIView {

    public let topDatePicker  = UIDatePicker()
    public let bottomDatePicker  = UIDatePicker()
    public let backView  = UIView()

    public var  startDate = Date()
    public var  endDate = Date()
    // MARK: - Constants
    private let kDefaultPickerViewHeight: CGFloat = 480 ///view的高度
    /// 选择日期的回调
    public  typealias Block = (Date,Date)->()
    public  var selectDateBlock:Block?
    /// 返回筛选的回调
    public  typealias backBlock = ()->()
    public  var backAction:backBlock?

    // MARK: - Public Property
    
    public init(frame: CGRect, startDate: Date, endDate: Date) {
        super.init(frame: frame)
        self.startDate = startDate
        self.endDate = endDate
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
        

        let btn = UIButton(frame: CGRect(x:10, y:20, width:140, height:20))
        btn.setTitle("  返回筛选", for: .normal)
        btn.setTitleColor(mColor(0x333333, 1), for:.normal)
        btn.addTarget(self, action:#selector(back(_:)), for:.touchUpInside)

        btn.setImage(UIImage(named:"arrow_navBack"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        addSubview(btn)
        
        //创建日期选择器
        topDatePicker.frame = CGRect(x:0, y:60, width:frame.size.width, height:150)
        topDatePicker.date = startDate
        topDatePicker.datePickerMode = .date
        topDatePicker.maximumDate = Date()
        topDatePicker.addTarget(self, action: #selector(dateChanged),for: .valueChanged)

        addSubview(topDatePicker)
        
        let label = UILabel(frame: CGRect(x:0, y:200, width:frame.size.width, height:20))
        label.text = "~"
        label.textColor = mColor(0x333333, 1)
        label.textAlignment = .center
        addSubview(label)
        
        bottomDatePicker.frame = CGRect(x:0, y:220, width:frame.size.width, height:150)
        bottomDatePicker.date = endDate
        bottomDatePicker.datePickerMode = .date
        bottomDatePicker.maximumDate = Date()
        bottomDatePicker.addTarget(self, action: #selector(dateChanged),for: .valueChanged)
        addSubview(bottomDatePicker)
        
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

        backAction?()
        dismiss()
    }
    
    @objc func sure(_ button:UIButton){
        let startStamp:Int64 = Int64(startDate.timeIntervalSince1970)
        let endStamp:Int64 = Int64(endDate.timeIntervalSince1970)
        let reduceStamp = endStamp - startStamp
        /// 大于一年
        if reduceStamp > 365 * 24 * 60 * 60{
           showMessage(message: "时间段不能大于一年")
            return
        }
        if startStamp > endStamp {
            showMessage(message: "开始时间不能晚于结束时间")
            return
        }
        
         /// 选择的是同一天
          if (startStamp == endStamp) {
            
            let now = startDate
            let nowZero = Date.init(year: now.year, month: now.month, day:now.day)
            let tomorrowZero = nowZero.add(1.days)
            startDate = nowZero
            endDate   = tomorrowZero.add(-1.seconds)
        }
        
       
   if selectDateBlock != nil {
            selectDateBlock?(startDate,endDate)
        }
        dismiss()
    }

    @objc func dateChanged(datePicker : UIDatePicker){
        //更新提醒时间文本框
        let formatter = DateFormatter()
        //日期样式
        formatter.dateFormat = "yyyy-MM-dd"
        if datePicker == topDatePicker{
            startDate = datePicker.date
        } else {
            endDate = datePicker.date
            
        }
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
