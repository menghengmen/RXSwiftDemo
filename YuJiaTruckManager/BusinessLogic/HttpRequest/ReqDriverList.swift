//
//  ReqDriverList.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/22.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON
/// 司机列表
class ReqDriverList: BaseReqModel<ReqDriverList.Model> {
    ///用户id
    var userId = ""
    
    convenience init(userId: String) {
        self.init()
        self.userId = userId
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.driverListUrl + "?userId=\(userId)"
    }
    
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "dataList":
                            [
                                ["name": "哈哈",
                                 "tel" : "17909000033"
                                ],
                                ["name": "ben明明",
                                 "tel" : "13523708987"
                                ],
                                ["name": "木兰道",
                                 "tel" : "3254545454"
                                ],
                                ["name": "林华",
                                 "tel" : "15103838929"
                                ],
                                ["name": "林华",
                                 "tel" : "15103838929"
                                ],
                                ["name": "林华",
                                 "tel" : "15103838929"
                                ],
                                ["name": "林华",
                                 "tel" : "15103838929"
                                ],
                                ["name": "林华",
                                 "tel" : "15103838929"
                                ],
                                ["name": "林华",
                                 "tel" : "15103838929"
                                ],
                                ["name": "A英",
                                 "tel" : "13783452657"],
                                ["name": "C英",
                                "tel" : "13783452657"],
                                ["name": "D英",
                                 "tel" : "13783452657"],
                                ["name": "E英",
                                "tel" : "13783452657"],
                                ["name": "F英",
                                "tel" : "13783452657"],
                                ["name": "G英",
                                "tel" : "13783452657"],
                                ["name": "V英",
                                "tel" : "13783452657"]
                                
            ]]]
    }

}
extension ReqDriverList {
    
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
        /// 返回查找的字符串
        var data = ""
    }
    /// data
    class Data: HandyJSON {
        ///用户id
        var userId = ""
        /// 名字
        var name = ""
        /// 电话
        var tel = ""
        /// 司机id
        var id = ""
        /// 创建用户时间戳
        var createTime = ""
        /// 更新用户信息时间戳
        var updateTime = ""
        /// 首字母
        var firstLetter = ""
        
        required init() {
            
        }
    }
}
