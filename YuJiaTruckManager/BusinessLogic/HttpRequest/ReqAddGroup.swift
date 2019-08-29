//
//  ReqAddGroup.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/12/27.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON
/// 增加分组
class ReqAddGroup: BaseReqModel<BaseRspModel> {
    
    ///组织id
    var groupId = ""
    /// 分组名字
    var gpsGroupName = ""
    /// 用户id
    var userId = ""
   
    convenience init(groupId: String, gpsGroupName: String, userId: String) {
        self.init()
        self.groupId = groupId
        self.gpsGroupName = gpsGroupName
        self.userId = userId
    }
   
    override func method() -> HttpRequestMethod {
        return .POST
    }
        
    override func url() -> String {
        return Constants.Url.addGroupUrl
    }
        
    override func mockDic() -> [String : Any]? {
            return ["Demo": ["status": 0,
                             "description": "the method is success",
                             "data":nil]]
            
     }
        
        
 }

