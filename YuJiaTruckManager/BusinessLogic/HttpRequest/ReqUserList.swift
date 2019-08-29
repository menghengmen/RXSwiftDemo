//
//  ReqUserList.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/10/26.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON
///用户列表
class ReqUserList: BaseReqModel<ReqUserList.Model> {
    ///组织id
    var groupId = ""
    
    convenience init(groupID: String) {
        self.init()
        self.groupId = groupID
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.userListUrl + "?groupId=\(groupId)"
    }
    
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                      "description": "aaabbb",
                      "dataList":
                        [
                            ["name": "哈哈",
                             "tel" : "17909000033"
                             ],
                            ["name": "何明明",
                             "tel" : "13523708987"
                             ],
                            ["name": "木兰道",
                             "tel" : "13783452657"
                             ],
                            ["name": "林华",
                             "tel" : "15103838929"
                             ],
                            ["name": "张淑英",
                             "tel" : "13783452657"]
                           ]]]
    }
}

extension ReqUserList {
    
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
        /// 返回查找的字符串
        var data = ""
    }
    /// data
    class Data: HandyJSON {
        
        /// 名字
        var name = ""
        /// 电话
        var tel = ""
        ///组织id
        var groupId = ""
        
        required init() {
            
        }
    }
}

