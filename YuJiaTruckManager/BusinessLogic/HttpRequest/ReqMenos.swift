//
//  ReqMenos.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/26.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON
/// 已过期的事项
class ReqMenos: BaseReqModel<ReqMenos.Model> {
    /// 页码
    var pageNo  = ""
    /// 每页条数
    var pageSize = ""
    /// 用户id
    var userId = ""
    /// 搜索词
    var keyword = ""
   
    convenience init(userId: String ,pageNo :String ,pageSize :String ,keyword :String) {
        
        
        self.init()
        self.userId = userId
        self.pageNo = pageNo
        self.pageSize = pageSize
        self.keyword = keyword
        
      
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.expireMemosUrl  + "?userId=\(userId)&pageNo=\(pageNo)&pageSize=\(pageSize)&keyword=\(keyword)"
    }
  
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "dataList":
                            [
                                ["content": "哈哈danf ds ",
                                 "remindTime" : "1543235458000"
                                ],
                                ["content": "benfds fsdfds明明",
                                 "remindTime" : "1543149058000"
                                ],
                                ["content": "木难道你是能发你的美少女方面的说明发兰道",
                                 "remindTime" : "1543127458000"
                                ],
                                ["content": "林发的什么哪方面的是你吗分内的事华",
                                 "remindTime" : "1543033858000"
                                ],
                               
                                ["content": "V 反倒是哪方面的少年是那么的英",
                                 "remindTime" : "1378345265700",
                                 "picture1" : "https://vasm-qa-public.obs.cn-east-2.myhwclouds.com/530d4bde49c64a73a5809db7bc26b23a.jpg"]
                                
            ]]]
    }

}

extension ReqMenos {
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
    }
    /// data
    class Data: HandyJSON {
        
        var fieldCondition = ""
        /// 过期事项id
        var id = ""
        
        var userId:Int?
        /// 内容
        var content = ""
        /// 图片
        var picture1 = ""
        var tag:Int?
        /// 状态
        var status:Int?
        /// 创建时间
        var createTime:Int64?
        /// 过期时间
        var expireTime:Int64?
        /// 提醒时间
        var remindTime:Int64?

       required init() {
        }
    }
    
}
