//
//  ReqDeleteMenos.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/27.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import HandyJSON
import YuDaoComponents
/// 删除待办事项
class ReqDeleteMenos: BaseReqModel<BaseRspModel> {
    /// 待办事项id
    var memoId = ""
    
    convenience init(memoId: String) {
        self.init()
        self.memoId = memoId
        
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.deleteMenosUrl + "?memoId=\(memoId)"
    }

    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "data":nil]]
        
    }

}
