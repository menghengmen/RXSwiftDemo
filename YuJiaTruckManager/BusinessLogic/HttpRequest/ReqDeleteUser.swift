//
//  ReqDeleteUser.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/10/27.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import HandyJSON
import YuDaoComponents
///删除用户
class ReqDeleteUser: BaseReqModel<BaseRspModel> {
    /// 手机号
    var tel = ""
    
    convenience init(tel: String) {
        self.init()
        self.tel = tel
        
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.deleteUserUrl + "?tel=\(tel)"
    }
    
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "success"]]
        
    }
}
