//
//  ReqUploadImage.swift
//  YuJiaDriver
//
//  Created by mh on 2018/9/6.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import HandyJSON
import RxSwift

/// 上传请求
class ReqUploadImage: NSObject {
    
    /// 图片
    let images: [UIImage]
    
    /// 转换为请求
    func toUploadRequest() -> UploadRequest<ReqUploadImage.Model> {
        
        let req = UploadRequest<ReqUploadImage.Model>()
        
        var typeMod = UploadFileUnit()
        typeMod.name = "type"
        typeMod.uploadFileData = "picture".data(using: .utf8)
        req.multipartFormDatas.append(typeMod)
        
        for (idx, aImg) in images.enumerated() {
            
            guard let data1 = aImg.jpegData(compressionQuality: 0.2) else {
                continue
            }
            
            var uploadMod = UploadFileUnit()
            uploadMod.uploadFileData = data1
            uploadMod.fileName = "png"
            uploadMod.name = "picture"
            uploadMod.mimeType = "image/jpg"
            
            req.multipartFormDatas.append(uploadMod)
        }
    
        return req
    }
    
    /// 初始化
    init(images: [UIImage]) {
        self.images = images
        super.init()
    }
    
}

extension ReqUploadImage {
    
    /// 返回模型
    class Model: BaseRspModel {
        /// 返回图片id
        var dataList = [String]()
    }
    
}
