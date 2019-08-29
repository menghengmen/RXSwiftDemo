//
//  ReqAddMenos.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/27.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import HandyJSON
import YuDaoComponents
/// 新增待办事项
class ReqAddMenos: BaseReqModel<BaseRspModel> {
  
    /// 用户id 必传
    var userId  = ""
    /// -待办事项内容
    var content:String?
    /// 图片链接 (如果没有上传图片 可以不传)
    var picture1:String?
    /// -标记是否点亮 (如果没有设置 可以不传) 1点亮
    var tag:Int?
    
    /// 过期时间(如果没有设置 可以不传)
    var expireTime:Int64?
    /// 提醒时间(如果没有设置 可以不传)
    var remindTime:Int64?
    
    
    override func method() -> HttpRequestMethod {
        return .POST
    }
    
    override func url() -> String {
        return Constants.Url.addMemosUrl
    }
    
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "the method is success",
                         "data":nil]]
        
    }


}
