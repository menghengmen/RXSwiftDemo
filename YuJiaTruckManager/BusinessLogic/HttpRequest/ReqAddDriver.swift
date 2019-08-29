//
//  ReqAddDriver.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/26.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import HandyJSON
import YuDaoComponents
/// 添加司机
class ReqAddDriver: BaseReqModel<ReqAddDriver.Model> {
    /// 姓名
    var name = ""
    /// 手机号
    var tel = ""
    /// 登录时返回的
    var userId =  ""
    
    convenience init(name: String,tel: String,userId: String) {
        self.init()
        self.tel = tel
        self.name = name
        self.userId = userId
        
    }
    
    override func method() -> HttpRequestMethod {
        return .POST
    }
    
    override func url() -> String {
        return Constants.Url.addDriverUrl
    }
    
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "success",
                         "data" : true
            ]]
        
    }
}

extension ReqAddDriver{
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
