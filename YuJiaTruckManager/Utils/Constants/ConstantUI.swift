//
//  ConstantUI.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents

extension Constants {
    
    /// 字体
    struct Font {
        /// bar item 字体 11
        static var barItem: UIFont { return mFont(11) }
        /// 一般正文字体 16
        static var contentText: UIFont { return mFont(16) }
        /// 小字体 12
        static var smallText: UIFont { return mFont(12) }
        /// 提示字体 14
        static var noticeText: UIFont { return mFont(14) }
    }
    
    /// 颜色
    struct Color {
        /// 重要文字颜色 333333
        static var mainText: UIColor { return mColor(0x404142) }
        /// 灰色文字颜色 CCCCCC
        static var grayText: UIColor { return mColor(0xBCBCBC) }
        /// 一般内容文字颜色 666666
        static var contentText: UIColor { return mColor(0x535353) }
        /// 淡色文字颜色 999999
        static var lightText: UIColor { return mColor(0x999999) }
        /// 运单色字体
        static var waybillText: UIColor { return mColor(0x156B81) }
        
        
        /// 主色调颜色
        static var  mainColor: UIColor { return mColor(0x4C8AF7) }
        
        /// 灰色背景 F3F3F3
        static var grayBg: UIColor { return mColor(0xF3F3F3) }
        /// table 背景色 F7FDFF
        static var tableBg: UIColor { return mColor(0xEDF3F5) }
        
        /// 输入框
        static var grayTextColor: UIColor { return mColor(0x6B6A74) }
        /// 电子围栏颜色
        static var railColor :UIColor {return mColor(0x3e5cff)}
        /// 电子围栏边框颜色
        static var railBoderColor :UIColor {return mColor(0x3e5cff)}
        
        /// 行程路线颜色
        static var wayColor :UIColor {return mColor(0x00bc02)}
        /// 行程路线边框颜色
        static var wayBoderColor :UIColor {return mColor(0x45946a)}
        
        /// 红色
        static var red: UIColor { return mColor(0xE9351A) }
        /// 橙色
        static var orange: UIColor { return mColor(0xEA7B04) }
        /// 蓝色
        static var blue: UIColor { return mColor(0x3E5CFF) }
        /// 绿色
        static var green: UIColor { return mColor(0x55CB1B) }
        /// 白色
        static var white: UIColor { return mColor(0xFFFFFF) }
        /// 灰色
        static var gray: UIColor { return mColor(0xE8E8E8) }
        /// 藏青色
        static var cyanColor: UIColor { return mColor(0x6158FF) }
        /// 藏青色
        static var yellow: UIColor { return mColor(0xEF9026) }
        /// 线条颜色
        static var line: UIColor { return mColor(0xF1F1F1) }
    }
    
    /// 图片
    struct Image {
        
        /// 车辆gps背景图片
        static func carGpsBgImage(from status: ReqQueryAllVehiclesGps.VehicleStatus?) -> UIImage? {
            
            var bgImage: UIImage?
            
            switch status {
            case .normal?:
                bgImage = UIImage(named: "bg_mapcar1")
            case .alarming?:
                bgImage = UIImage(named: "bg_mapcar3")
            case .shutdown?:
                bgImage = UIImage(named: "bg_mapcar4")
            case .offline?:
                bgImage = UIImage(named: "bg_mapcar2")
            default:
                bgImage = UIImage(named: "bg_mapcar")
            }
            
            return bgImage
        }
    }
    
}
