//
//  ReqDeleteDriver.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/26.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON

/// 删除司机
class ReqDeleteDriver: BaseReqModel<BaseRspModel> {
    /// 查询列表时返回的id字段
    var addressBookId = ""
    
    convenience init(addressBookId: String) {
        self.init()
        self.addressBookId = addressBookId
        
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.deleteDriverUrl + "?addressBookId=\(addressBookId)"
    }
    
    
}
