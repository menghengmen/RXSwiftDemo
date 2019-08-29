//
//  ReqUploadMenosImage.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/28.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import HandyJSON
import YuDaoComponents

class ReqUploadMenosImage: BaseReqModel<BaseRspModel> {
   
    
    
    override func method() -> HttpRequestMethod {
        return .POST
    }
    
    override func url() -> String {
        return Constants.Url.uploadMenosImageUrl
    }
    
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "dataList":
                            ["https://vasm-qa-public.obs.cn-east-2.myhwclouds.com/530d4bde49c64a73a5809db7bc26b23a.jpg"]]]
        
    }
    
}
