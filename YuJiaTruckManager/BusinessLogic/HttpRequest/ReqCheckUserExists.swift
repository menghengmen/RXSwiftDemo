//
//  ReqCheckUserExists.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/10/23.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON
/// 检查用户是否存在
class ReqCheckUserExists: BaseReqModel<ReqCheckUserExists.Model> {
    // 检查手机号
    var tel = ""
    
    convenience init(telephone: String) {
        self.init()
        tel = telephone
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.checkUserExists + "?tel=\(tel)"
    }
    
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "data":true]]
        
    }
}
extension ReqCheckUserExists {
    
    /// 返回模型
    class Model: BaseRspModel {
        var data: Bool?
    }
    /// data
    class Data: HandyJSON {
        
      
        /// true表示注册过，false表示没有注册过
        var data: Bool  = false
        required init() {
        }
    }
}
