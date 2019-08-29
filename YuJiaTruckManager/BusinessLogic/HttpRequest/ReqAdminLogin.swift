//
//  ReqAdminLogin.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/10/23.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON
/// 管理员登录
class ReqAdminLogin: BaseReqModel<ReqAdminLogin.Model> {
    /// 账号
    var name = ""
    /// 密码
    var passwd = ""
    ///登录类型
    var loginType = "1"
    
    convenience init(account: String, password: String) {
        self.init()
        name = account
        self.passwd = password
    }
    
    override func method() -> HttpRequestMethod {
        return .POST
    }
    
    override func url() -> String {
        return Constants.Url.adminLoginUrl
    }
    
//    override func mockDic() -> [String : Any]? {
//        return ["Demo": ["status": 20009,
//                         "description": "aaabbb",
//                         "data":
//                            ["token": Constants.DemoAccount.token,
//                             "tel": Constants.DemoAccount.phoneNumber,
//                             "driverId" :Constants.DemoAccount.driverId
//                                
//            ]]]
//        
//    }
}
extension ReqAdminLogin {
    
    /// 返回模型
    class Model: BaseRspModel {
        var data: Data?
    }
    /// data
    class Data: HandyJSON {
        
       
        /// token  即后续接口调用时需要传递的token
        var token = ""
        required init() {
        }
    }
}
