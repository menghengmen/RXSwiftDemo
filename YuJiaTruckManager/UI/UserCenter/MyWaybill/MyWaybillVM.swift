//
//  MyWaybillVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2019/1/7.
//  Copyright © 2019 mh Technology. All rights reserved.
//

import Foundation

/// 我的运单
class MyWaybillVM: BaseWebVM {
    
    override init() {
        super.init()
        urlStr.value = Constants.Url.myWayBillUrl
    }
    
}
