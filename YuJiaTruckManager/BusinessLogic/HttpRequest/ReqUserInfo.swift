//
//  ReqUserInfo.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/10/27.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import HandyJSON
import YuDaoComponents
///用户信息接口
class ReqUserInfo: BaseReqModel<ReqUserInfo.Model> {
    /// 账号名称 2为手机号 1 是管理员名字
    var userName = ""
    /// 账户类型 1 管理员 2 手机号
    var accountType = ""
 
    
    convenience init(userName: String, accountType: String) {
        self.init()
        self.userName = userName
        self.accountType = accountType
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.userInfoUrl + "?userName=\(userName)&accountType=\(accountType)"
    }
    
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "data":
                            [
                             "groupName" :Constants.DemoAccount.companyName,
                             "userName" :Constants.DemoAccount.name
                                
            ]]]
        
    }
}

extension ReqUserInfo{
    /// 返回模型
    class Model: BaseRspModel {
        var data: Data?
    }
    /// data
    class Data: HandyJSON {
        
       
        ///用户名
        var userName = ""
        /// 组织名
        var groupName = ""
      
      
        
        required init() {
        }
    }
    
    
}
