//
//  MonitorDetailVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/20.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

// MARK: - 车辆数据封装

/// 监控视频信息封装
class MoniterCarInfo {
    
    /// 车辆号
    var vehicleId = Variable<String?>(nil)
    /// 车牌号
    var carLicense = Variable<String?>(nil)
    /// 车辆状态
    var carStatus = Variable<ReqQueryAllVehiclesGps.VehicleStatus?>(nil)
    /// 定位点信息
    let gpses = Variable<CLLocationCoordinate2D?>(nil)
    
    /// 当前所有可选通道
    var allChannels = Variable<[String]>([])
    /// 通道号
    let channelId = Variable<String?>(nil)
    /// 码流：1主码流，2子码流
    var streamType = Variable<LiveStreamType>(.sub)
    /// sim卡号
    var simCardNo = Variable<String?>(nil)
    
    /// 加载中
    let isRequesting = Variable<Bool>(false)
    
    /// 视频源已切换时间
    let videoSourceDidChange = PublishSubject<Void>()
    
    /// 监听回收袋
    private var disposeBag = DisposeBag()
    
    init() {
        
        /// 获取通道
       let channelReq = vehicleId.asObservable()
            .skipNil()
            .flatMapLatest { [weak self] (value) -> Observable<ReqGetVehicleChannel.Data?> in
                return self?.requestChannels(vehicleId: value) ?? .empty()
            }
            .share(replay: 1, scope: .whileConnected)
        
        channelReq.asObservable()
            .map { $0?.simCardNo }
            .bind(to: simCardNo)
            .disposed(by: disposeBag)
        
        channelReq
            .map { (value) -> [String] in
                var channels = value?.allChannels()
                channels?.sort(by: { (channel1, channel2) -> Bool in
                    return Int(channel2) > Int(channel1)
                })
                return channels ?? []
            }
            .bind(to: allChannels)
            .disposed(by: disposeBag)
        
        allChannels.asObservable()
            .map { $0.first }
            .bind(to: channelId)
            .disposed(by: disposeBag)
        
        
        /// 获取车辆的gps
        let getGpsReq = vehicleId.asObservable()
            .skipNil()
            .flatMapLatest { [weak self](value) -> Observable<ReqGetVehicleGps.Data?> in
                return self?.requestVehicleGps(vehicleId: value) ?? .empty()
         }
            .share(replay: 1, scope: .whileConnected)
        
        getGpsReq.asObservable()
            .map({ (data) -> CLLocationCoordinate2D in
                var nowPosition: CLLocationCoordinate2D? = nil
                if let lat = data?.latAccuracy?.yd.double, let lng = data?.lngAccuracy?.yd.double {
                    nowPosition = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                }
                return nowPosition ?? CLLocationCoordinate2D(latitude: 39.9152108931, longitude: 116.4039006839)
            })
            .bind(to: gpses)
            .disposed(by: disposeBag)


        /// 视频源切换
        Observable.merge(
            vehicleId.asObservable().map { _ in },
            channelId.asObservable().map { _ in },
            streamType.asObservable().map { _ in },
            simCardNo.asObservable().map { _ in })
            .bind(to: videoSourceDidChange)
            .disposed(by: disposeBag)
        
    }
    
    /// 请求通道
    private func requestChannels(vehicleId: String) -> Observable<ReqGetVehicleChannel.Data?> {
        
        let reqParam = ReqGetVehicleChannel(vehicleId: vehicleId)
        let req = reqParam.toDataReuqest()
        
        req.isRequesting.asObservable()
            .bind(to: isRequesting)
            .disposed(by: disposeBag)
        
        let result = req.responseRx.asObservable()
            .map { (rsp) -> ReqGetVehicleChannel.Data? in
                return rsp.model?.data
        }
        req.send()
        
        return result
    }
    
    /// 请求gps信息
    private func requestVehicleGps(vehicleId: String) -> Observable<ReqGetVehicleGps.Data?> {
        
        let reqParam = ReqGetVehicleGps(vehicleId: vehicleId)
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
            .map { (rsp) -> ReqGetVehicleGps.Data? in
                return rsp.model?.data
        }
        req.send()
        
        return result
        
    }
    
    
}

// MARK: - ViewModel

/// 实时监控-监控详情
class MonitorDetailVM: BaseVM {
    
    // MARK: - Property
    
    /// 是否支持搜索车辆
    let isEnableSearchCar = Variable<Bool>(true)
    
    // to view
    /// 当前车辆信息
    let currentCarInfo = MoniterCarInfo()
    /// 开始播放/结束播放（直播地址）
    let play = Variable<String?>(nil)
    /// 倒计时
    let countDown = Variable<Int?>(nil)
    
    // from view
    /// 点击播放按钮
    let didClickPlayBtn = PublishSubject<Void>()
    /// 切换了信号
    let didChangeChannel = PublishSubject<Int>()
    /// 切换了码流
    let didChangeType = PublishSubject<Int>()
    /// 搜搜车辆
    let didClickSearchCar = PublishSubject<Void>()
    /// 选择车完成
    let didSelectCarFinish = PublishSubject<(String,String)>()
    
    // private
    /// 计时器
    private var playTimer: Timer?
    
    
    // MARK: - Method
    override init() {
        super.init()
        
        /// 点击搜车两
        didClickSearchCar.asObservable()
            .map { [weak self] (_) -> RouterInfo in
                return (Router.UserCenter.searchCar,["didSelectCarFinish": self?.didSelectCarFinish ])
          }
           .bind(to: openRouter)
           .disposed(by: disposeBag)
        
        didSelectCarFinish.asObservable()
           .map{ return $0.0 }
           .bind(to: currentCarInfo.vehicleId)
           .disposed(by: disposeBag)
        
        didSelectCarFinish.asObservable()
            .map{ return $0.1 }
            .bind(to: currentCarInfo.carLicense)
            .disposed(by: disposeBag)
        
        /// 无通道信息
        currentCarInfo.allChannels.asObservable()
            .filter{  $0.count == 0 }
            .map{ _ in AlertMessage(message:"该车辆暂无视频信息", alertType: AlertMessage.AlertType.toast)
            }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        
        /// 点击播放按钮，请求播放地址并开始播放
        didClickPlayBtn.asObservable()
            .flatMapLatest { [weak self] (_) -> Observable<String> in
                return self?.requestStartPlay() ?? .empty()
            }
            .map {
                mLog("【播放地址】:\($0)")
                return $0
            }
            .bind(to: play)
            .disposed(by: disposeBag)
        
        /// 切换通道
        didChangeChannel.asObservable()
            .map({ [weak self] (idx) -> String? in
                self?.currentCarInfo.allChannels.value.yd.element(of: idx)
            })
            .bind(to: currentCarInfo.channelId)
            .disposed(by: disposeBag)
       
        /// 切换码流
        didChangeType.asObservable()
            .map({ (idx) -> LiveStreamType in
                return LiveStreamType.allTypes.yd.element(of: idx) ?? .main
            })
            .bind(to: currentCarInfo.streamType)
            .disposed(by: disposeBag)
        
        /// 视频源有变化
        currentCarInfo.videoSourceDidChange.asObservable()
            .map { _ in nil }
            .bind(to: play)
            .disposed(by: disposeBag)
        
        /// 播放
        play.asDriver()
            .distinctUntilChanged()
            .drive(onNext: { [weak self] (url) in
                mLog("【播放】：play：\(url ?? "")")
                if url?.count > 0 {
                    self?.didStartPlay()
                } else {
                    self?.didStopPlay()
                }
            })
            .disposed(by: disposeBag)
        
        viewDeinit.asObservable()
            .map { return nil }
            .bind(to: play)
            .disposed(by: disposeBag)

    }
    
    
    /// 请求开始播放
    private func requestStartPlay() -> Observable<String> {
        
        let reqParam = ReqStartVideo()
        reqParam.vehicleId = currentCarInfo.vehicleId.value ?? ""
        reqParam.channel = currentCarInfo.channelId.value ?? ""
        reqParam.type = currentCarInfo.streamType.value
        reqParam.simcard = currentCarInfo.simCardNo.value ?? ""
        
        let req = reqParam.toDataReuqest()
        
        req.isRequesting.asObservable()
            .map { LoadingState(isLoading: $0) }
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
        
        let finish = req.responseRx.asObservable()
        
        finish
            .filter { $0.isSuccess() == false || $0.model?.data == nil }
            .map { AlertMessage(message: $0.yjtm_errorMsg(), alertType: .toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        let success = finish
            .filter { $0.isSuccess() && $0.model?.data != nil }
            .map { $0.model?.data }
            .skipNil()
        req.send()
        return success
    }
    
    /// 请求心跳
    private func requestHeartBeat() {
        
        let reqParam = ReqVideoHeartbeat()
        reqParam.vehicleId = currentCarInfo.vehicleId.value ?? ""
        reqParam.channel = currentCarInfo.channelId.value ?? ""
        reqParam.type = currentCarInfo.streamType.value
        reqParam.simcard = currentCarInfo.simCardNo.value ?? ""
        
        let req = reqParam.toDataReuqest()
        
        let finish = req.responseRx.asObservable()
        
        // 成功更新心跳时间
        finish
            .filter { $0.isSuccess() }
            .map { _ in  }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak ud = UserDefaultsManager.shared] (_) in
                ud?.lastLiveHeartBeatTime = Date()
            })
            .disposed(by: disposeBag)
        
        // 失败结束播放
        finish
            .filter { $0.isSuccess() == false }
            .map { _ in nil }
            .bind(to: play)
            .disposed(by: disposeBag)

        req.send()

    }
    
    /// 开始播放
    private func didStartPlay() {
        
        playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeFire), userInfo: nil, repeats: true)
        countDown.value = Int(exactly: Constants.Config.playTime)
        UserDefaultsManager.shared.liveStartTime = Date()
        UserDefaultsManager.shared.lastLiveHeartBeatTime = Date()
        
    }
    
    /// 结束播放
    private func didStopPlay() {
        
        playTimer?.invalidate()
        playTimer = nil
        countDown.value = nil
        UserDefaultsManager.shared.liveStartTime = nil
        UserDefaultsManager.shared.lastLiveHeartBeatTime = nil
        
    }
    
    /// 计时器触发
    @objc private func timeFire() {
        
        guard let playStartTime = UserDefaultsManager.shared.liveStartTime else {
            play.value = nil
            return
        }
        
        let playDuring = Date().timeIntervalSince(playStartTime)
        let secondRemain = Constants.Config.playTime - playDuring
        
        if secondRemain > 0 {
            
            countDown.value = Int(secondRemain)
            
            // 检查心跳
            let lastHeartBeatTime = UserDefaultsManager.shared.lastLiveHeartBeatTime ?? playStartTime
            if Date().timeIntervalSince(lastHeartBeatTime) > Constants.Config.playHeartBeatInterval {
                requestHeartBeat()
            }
            
        } else {
            play.value = nil
        }
        
    }
    
}


