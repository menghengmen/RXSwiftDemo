//
//  ReqEditUser.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/10/29.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON
/// 编辑用户
class ReqEditUser: BaseReqModel<ReqEditUser.Model> {
    /// 手机号
    var tel = ""
    /// 名称
    var name = ""
    /// 旧手机号
    var oldTel = ""
    
    convenience init(tel: String,name :String,oldTel: String) {
        self.init()
        self.tel = tel
        self.name = name
        self.oldTel = oldTel
        
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.editUserUrl + "?name=\(name)&tel=\(tel)&oldTel=\(oldTel)"
    }
    
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "success",
                         "data" : true
            ]]
        
    }
}

extension ReqEditUser{
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



