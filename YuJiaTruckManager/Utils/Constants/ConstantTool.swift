//
//  ConstantTool.swift
//  YuJiaTruckManager
//
//  Created by mh on 2019/1/8.
//  Copyright © 2019 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import Alamofire
import SwiftyJSON
import RxSwift

extension Constants {
    
    /// 工具类
    struct Tools {
        
        /// 反向解析坐标为地址
        static func reverseGeoCode(coordinate: CLLocationCoordinate2D?, complition: @escaping ((_ address: String?) -> Void)) {
            
            guard let coorV = coordinate else {
                mLog("【百度地图】启动解析失败")
                
                complition(nil)
                return
            }
            
            mLog("【百度地图】开始解析坐标：\(coorV)")
            
            let urlStr = Constants.Url.reverseGeoCode + "&location=\(coorV.latitude),\(coorV.longitude)"
            
            Alamofire.SessionManager.default.request(urlStr, method: HTTPMethod.get).response { (rsp) in
                complition(getAddress(from: rsp.data?.yd.utf8String))
            }
            
        }
        
        /// 反向解析坐标为地址
        static func reverseGeoCodeRx(coordinate: CLLocationCoordinate2D?) -> Observable<String?> {
            
            let result = PublishSubject<String?>()
            
            reverseGeoCode(coordinate: coordinate) { (address) in
                result.onNext(address)
            }
            return result
        }
        
        /// 解析百度web api的结果
        static private func getAddress(from baiduRetunStr: String?) -> String? {
            
            guard let fullStr = baiduRetunStr else {
                return Constants.Text.reverseGeoFailed
            }
            
            // 去掉头尾js的回调部分
            var jsonStr = fullStr.replacingOccurrences(of: "renderReverse&&renderReverse(", with: "")
            if jsonStr != "" {
                jsonStr.removeLast()
            }
            
            let json = JSON(parseJSON: jsonStr)
            
            let resultStr = json["result"]["formatted_address"].stringValue + json["result"]["sematic_description"].stringValue
            
            mLog("【百度地图】json:\(jsonStr)")
            
            return resultStr
        }
        
    }
}
