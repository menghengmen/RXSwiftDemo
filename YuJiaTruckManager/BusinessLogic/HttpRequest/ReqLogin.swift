//
//  ReqLogin.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/10/24.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import HandyJSON
import YuDaoComponents
/// 验证码登录
class ReqLogin: BaseReqModel<ReqLogin.Model> {
    /// 手机号
    var tel = ""
    /// 验证码
    var verifyCode = ""
    /// 登录类型 1管理员登录 2手机验证码登录
    var loginType = ""
    /// 账号
    var name = ""
    /// 密码
    var passwd = ""
   
    convenience init(tel: String, code: String,loginType: String) {
        self.init()
        if loginType == "1"{
            name = tel
            passwd = code
        } else {
            self.tel = tel
            verifyCode = code
        }
        
        self.loginType = loginType
    }
    
    override func method() -> HttpRequestMethod {
        return .POST
    }
    
    override func url() -> String {
        return Constants.Url.codeLoginUrl
    }
    
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "data":
                            ["token": Constants.DemoAccount.token,
                             "groupId":Constants.DemoAccount.groupId,
                             "accountType" :Constants.DemoAccount.accountType
                                
            ]]]
        
    }
}

extension ReqLogin {
    
    /// 返回模型
    class Model: BaseRspModel {
        var data: Data?
    }
    /// data
    class Data: HandyJSON {
        
        
        /// token  即后续接口调用时需要传递的token
        var token = ""
       
        /// 账号类型 1 管理员 2手机号
        var accountType = ""
        /// 组织id
        var groupId = ""
        /// 后续接口要用
        var userId = ""
        
        /// 是否为管理员
        func isAdmin() -> Bool {
            return accountType == "1"
        }
        
        required init() {
        }
    }
}
