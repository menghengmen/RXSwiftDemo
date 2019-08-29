//
//  ReqEditGroup.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/12/27.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON
/// 编辑分组
class ReqEditGroup: BaseReqModel<BaseRspModel> {
 
    ///组织
    var groupId = ""
    /// 分组名
    var groupName = ""
    /// 车辆id
    var vehicleList: [String] = []
    
    convenience init(groupId: String,vehicleList: [String],groupName: String) {
        self.init()
        self.groupId = groupId
        self.groupName = groupName
        self.vehicleList = vehicleList
        
    }
    
    override func method() -> HttpRequestMethod {
        return .POST
    }
    
    override func url() -> String {
        return Constants.Url.editGroupUrl
    }
    
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "the method is success",
                         "data":nil]]
        
    }
}
