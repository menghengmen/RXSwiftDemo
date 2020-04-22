//
//  ReqSendCode.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/10/24.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import HandyJSON
import YuDaoComponents
/// 发送验证码
class ReqSendCode: BaseReqModel<ReqSendCode.Model> {
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
        return Constants.Url.sendCodeUrl + "?tel=\(tel)"
    }
   
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "success",
                         "data" : true
            ]]
        
    }
}

extension ReqSendCode{
    /// 返回模型
    class Model: BaseRspModel {
        var data: Data?
    }
    /// data
    class Data: HandyJSON {
        
        /// true表示发送成功，false表示发送失败
        var success: Bool  = false
        required init() {
        }
    }
}
