//
//  ReqRegister.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/10/27.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import HandyJSON
import YuDaoComponents
///注册接口
class ReqRegister: BaseReqModel<ReqRegister.Model> {
    /// 手机号
    var tel = ""
    /// 验证码
    var verifyCode = ""
    
    convenience init(tel: String,verifyCode: String) {
        self.init()
        self.tel = tel
        self.verifyCode = verifyCode
        
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.registerUrl + "?tel=\(tel)&verifyCode=\(verifyCode)"
    }
    
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "success",
                         "data" : true
            ]]
        
    }
}
extension ReqRegister{
    /// 返回模型
    class Model: BaseRspModel {
        var data: Data?
    }
    /// data
    class Data: HandyJSON {
        
        /// true表示注册成功，false表示注册失败
        var success: Bool  = false
        required init() {
        }
    }
}
