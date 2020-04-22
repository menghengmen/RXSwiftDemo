//
//  ReqGetDynamicConfig.swift
//  YuJiaTruckManager
//
//  Created by mh on 2019/1/14.
//  Copyright © 2019 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import HandyJSON

/// 检查用户是否存在
class ReqGetDynamicConfig: BaseReqModel<ReqGetDynamicConfig.Model> {
    
    /// app名
    var application = ""
    /// 版本
    var version = ""
    
    override func method() -> HttpRequestMethod {
        return .POST
    }
    
    override func url() -> String {
        return Constants.Url.dynamicConfigUrl
    }
    
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "dataList": []]]
    }
}
extension ReqGetDynamicConfig {
    
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
    }
    
    /// data
    struct Data: HandyJSON {
        
        /// id
        var id = ""
        /// key
        var key = ""
        /// value
        var value = ""
        /// application
        var application = ""
        /// version
        var version = ""
        
    }
}
