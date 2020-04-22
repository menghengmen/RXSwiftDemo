//
//  ReqAddUser.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/10/25.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import HandyJSON
import YuDaoComponents
///管理员添加用户
class ReqAddUser: BaseReqModel<ReqAddUser.Model> {
    /// 姓名
    var name = ""
    /// 手机号
    var tel = ""
    ///组织id
    var groupId =  ""
    
    convenience init(name: String,tel: String,groupId: String) {
        self.init()
        self.tel = tel
        self.name = name
        self.groupId = groupId
        
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.addUserUrl + "?tel=\(tel)&name=\(name)&groupId=\(groupId)"
    }
    
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "success",
                         "data" : true
            ]]
        
    }
}

extension ReqAddUser{
    /// 返回模型
    class Model: BaseRspModel {
        var data: Data?
    }
    /// data
    class Data: HandyJSON {
        
        /// true表示添加成功，false表示添加失败
        var success: Bool  = false
        required init() {
        }
    }
}
