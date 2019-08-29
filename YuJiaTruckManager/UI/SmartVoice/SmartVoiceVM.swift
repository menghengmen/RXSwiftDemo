//
//  SmartVoiceVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/12/24.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa
/// 智能语音页
class SmartVoiceVM: BaseVM {
    /// 点击智能语音
    let smartVoiceResult = PublishSubject<String>()
   
    /// 点击了按钮
    let didClickButton = PublishSubject<Int>()
   
    
    
    override init() {
        super.init()
        
        /// 语音的识别结果
        smartVoiceResult.asObservable()
            .map { (text) -> RouterInfo in
                if text.contains(UserCenterRowType.myDriver.rawValue){
                    return (Router.SmartVoice.myDriver, nil)
                } else if text.contains(UserCenterRowType.reminder.rawValue){
                    return (Router.SmartVoice.reminder, nil)
                } else if text.contains(UserCenterRowType.alarm.rawValue){
                    return (Router.SmartVoice.alarm,nil)
                } else if text.contains(UserCenterRowType.moniter.rawValue){
                    return (Router.SmartVoice.monitor,nil)
                }else if text.contains(UserCenterRowType.rankList.rawValue){
                    return (Router.SmartVoice.rank,nil)
                }else if text.contains(UserCenterRowType.vehicleGps.rawValue){
                    return (Router.SmartVoice.gps,nil)
                }else if text.contains(UserCenterRowType.myWaybill.rawValue){
                    return (Router.SmartVoice.myWaybill,nil)
                } else {
                    return (nil,nil)
                }
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
  
        
        
            
        /// 点击
        didClickButton.asObservable()
            .map { (tag) -> RouterInfo in
                if tag == 100{
                    return (Router.SmartVoice.monitor, nil)
                } else if tag == 101 {
                    return (Router.SmartVoice.reminder, nil)
                }else if tag == 102 {
                    return (Router.SmartVoice.myDriver, nil)
                }else if tag == 103 {
                    return (Router.SmartVoice.alarm ,nil)
                } else if tag == 104 {
                    return (Router.SmartVoice.rank, nil)
                } else if tag == 105 {
                    return (Router.SmartVoice.gps, nil)
                } else if tag == 106 {
                    return (Router.SmartVoice.myWaybill, nil)
                } else {
                    return (nil, nil)
                }
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
    }
}
