//
//  ConstantText.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation

extension Constants {
    
    /// 文案
    struct Text {

        // MARK: - 错误提示

        /// 身份激活提示
        static var activeNoticeMessage: String { return "您当前不是企业用户，要想使用驭驾全部功能，请激活身份" }

        /// 用验证码直接登录提示
        static var loginByCodeDirect: String { return "该手机号已绑定其他微信，请直接用验证码登录！"
        }
        /// 微信未安装
        static var unInstallwechat: String {
            return "未安装微信"
        }

        /// 其他设备登录提示
        static var tokenInvalidMessage: String { return "账号登录失效，点击确定按钮重新登录" }
        /// 新版本更新提示
        static var newVersionMessage: String { return "检测到新版本" }
        /// 手机号输入不合规
        static var phoneNotMatchMessage: String { return "请输入正确的手机号" }
        /// 未勾选隐私协议
        static var privacyNotCheckMessage: String { return "请同意隐私政策" }


        /// 暂未加入公司
        static var userNoConpany: String { return "暂未加入公司" }
        /// 功能暂未开放
        static var funcUnready: String { return "敬请期待" }
        /// 解析地址失败
        static var reverseGeoFailed: String { return "解析地址失败" }
        
        /// 暂无图片
        static var alarmNoImage: String { return "暂无图片" }
        /// 暂无视频
        static var alarmNoVideo: String { return "暂无视频" }
        /// 首页/历史数据超时
        static var statusDataNetErr: String { return "驭驾车管家正在开小差，请尝试重新刷新" }
        /// 视频无法播放
        static var loadVideoFailed: String { return "该视频无法播放" }
        
        /// 无回放数据
        static var noTrackReplay: String { return "暂无回放数据" }
        /// 当前无法实时监控
        static var noMonitor: String { return "当前无法实时监控" }
        
       
        /// 通过type id获取报警类型文字
        static func alarmTypeName(_ alarmTypeId: Int?) -> String {
            
            switch alarmTypeId {
                
            case 1:
                return "驾驶员主动报警"
            case 2:
                return "超速报警"
            case 3:
                return "超时疲劳驾驶"
            case 4:
                return "危险预警"
            case 5:
                return "GNSS 模块发生故障"
            case 6:
                return "GNSS 天线未接或被剪断"
            case 7:
                return "GNSS 天线短路"
            case 8:
                return "终端主电源欠压"
            case 9:
                return "终端主电源掉电"
            case 10:
                return "终端LCD 或显示器故障"
            case 11:
                return "TTS 模块故障"
            case 12:
                return "摄像头故障"
            case 13:
                return "道路运输证IC 卡模块故障"
            case 16:
                return "抛洒报警"
            case 17:
                return "不在指定区域卸料报警"
            case 18:
                return "非指定区域行驶报警"
            case 19:
                return "当天累计驾驶超时"
            case 20:
                return "超时停车"
            case 21:
                return "进出区域"
            case 22:
                return "进出路线"
            case 23:
                return "路段行驶时间不足/过长"
            case 24:
                return "路线偏离报警"
            case 25:
                return "车辆VSS 故障"
            case 26:
                return "车辆油量异常"
            case 27:
                return "车辆被盗"
            case 28:
                return "车辆非法点火"
            case 29:
                return "车辆非法位移"
            case 30:
                return "碰撞预警"
            case 31:
                return "侧翻预警"
            case 102:
                return "存储故障报警"
            case 180:
                return "前向碰撞报警"
            case 181:
                return "车辆偏离报警"
            case 182:
                return "车距过近报警"
            case 184:
                return "行人碰撞报警"
            case 185:
                return "频繁变道预警"
            case 186:
                return "疲劳驾驶报警"
            case 187:
                return "接打电话报警"
            case 188:
                return "抽烟报警"
            case 189:
                return "注意力分散报警"
            case 190:
                return "驾驶员异常报警"
            case 191:
                return "轮胎异常报警"
            case 192:
                return "急刹车"
            case 193:
                return "急转弯"
            case 194:
                return "异常开门"
            case 195:
                return "怠速停车"
            case 196:
                return "低挡高速"
            case 197:
                return "空挡滑行"
            case 198:
                return "脱岗预警"
            case 199:
                return "左右压线"
            case 200:
                return "遮挡摄像头预警"
            case 201:
                return "驾驶行为预警"
            case 202:
                return "故障类报警"
                
            case 10000:
                return "驾驶员认证失败"
            case 10001:
                return "驾驶员登录中间类型"
            case 10002:
                return "驾驶员认证成功"
                
            case 90001:
                return "盲区检测-后方接近报警"
            case 90002:
                return "盲区检测-左侧后方接近报警"
            case 90003:
                return "盲区检测-右侧后方接近报警"
            case 90004:
                return "胎压异常-胎压定时上报"
            case 90005:
                return "胎压异常-胎压过高报警"
            case 90006:
                return "胎压异常-胎压过低报警"
            case 90007:
                return "胎压异常-胎温过高报警"
            case 90008:
                return "胎压异常-传感器异常报警"
            case 90009:
                return "胎压异常-胎压不平衡报警"
            case 90010:
                return "胎压异常-慢漏气报警"
            case 90011:
                return "胎压异常-电池电量低报警"
                
            case 90099:
                return "凌晨2时至5时行车报警"
                
            default:
                return "其他报警"
            }
            
        }
        
        // MARK: - 网络错误
        
        /// 根据返回码返回错误信息
        static func errMessage(from code: StatusCode?) -> String? {
            
            switch (code ?? .unknow) {
                
            case .cancelled:
                return nil
            case .success:
                return nil
            case .timedOut:
                return "请求超时"
            case .noNetwork:
                return "网络连接错误"
            case .tokenInvalid:
                return "账号登录已失效"
            case .senderCodeTooMuch:
                return "验证码发送过于频繁，请稍后再试"
            case  .wechatBeenBound:
                return "该微信已经被绑定"
            case .identifyActiveNoMatch:
                return "企业用户信息不匹配，请重新输入！"
            case .identifyActiveTooPhone:
                return "驾驶员绑定手机号大于等于3个！"
            case .loginVerifyCodeErr:
                return "验证码错误！"
            case .lowerMandatoryVersion:
                return "您当前版本过于陈旧，请及时更新至最新版本"
            case .accountOrPasswordError:
                return "账号或密码错误"
            case .telBeenAdded:
                return "用户已存在"
            case .groupNameAlredyExist:
                return "分组名已存在，请换一个名称！"
                
            default:
                return "获取数据失败"
            }
            
        }
        
        // MARK: - 页面文案
        
        static var handleStateArr : Array<String> {return ["全部","已处理","未处理"]}
        static var indexTitleArr : Array<String> {
            
            return ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#"]
        }
        
        /// 提醒推送前缀
        static var remindPushPrefix: String { return "您有一条新的提醒！\n" }
        
    }
    
}
