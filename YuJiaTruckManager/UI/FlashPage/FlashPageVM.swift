//
//  FlashPageVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/22.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift

/// 闪屏/引导页
class FlashPageVM: BaseVM {
    
    /// 结束的事件
    let finishFlashPage = PublishSubject<Void>()
    
    override init() {
        super.init()
        
        /// 显示1.5秒后结束
        viewDidLoad.asObservable()
            .delay(1.5, scheduler: MainScheduler.instance)
            .bind(to: finishFlashPage)
            .disposed(by: disposeBag)
        
        // 加载完毕事件
        finishFlashPage.asObservable()
            .bind(to: MessageCenter.shared.didLoadRootPage)
            .disposed(by: disposeBag)
    }
    
    
}
