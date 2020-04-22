//
//  ReqDeleteGroup.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/12/27.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON
/// 删除分组
class ReqDeleteGroup: BaseReqModel<BaseRspModel> {
    ///分组id
    var gpsGroupIdList = [Int64]()
    
    convenience init(gpsGroupIdList: [String]) {
        self.init()
        self.gpsGroupIdList = gpsGroupIdList.map { $0.yd.int64Value }
        
    }
    
    override func method() -> HttpRequestMethod {
        return .POST
    }
    
    override func url() -> String {
        return Constants.Url.deleteGroupUrl
    }
    
    override func customHttpBody() -> Data? {
        
        do {
            return try JSONEncoder().encode(gpsGroupIdList)
        } catch {
            return nil
        }
    }
    
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "the method is success",
                         "data":nil]]
        
    }
    
}
