//
//  TrackReplayVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/12/28.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 轨迹回放页
class TrackReplayVM: BaseVM {
    
    // MARK: - Enum
    /// 轨迹点信息
    struct TrackPointInfo {
        /// gps数据
        var gps: ReqPlayback.Data
        /// 定位点
        var point: CLLocationCoordinate2D
        /// 时间
        var time: Date?
        /// 目前距离
        var distance: Int
        /// 目前进度
        var progress: Float
        
    }
    
    // MARK: - Property
    
    // to view
    
    /// 所有定位数据
    let allTracks = Variable<[TrackPointInfo]>([])
    /// 当前轨迹点序号
    private let currnetTrackIndex = Variable<Int>(0)
    /// 当前定位数据
    private let currnetTrackInfo = Variable<TrackPointInfo?>(nil)
    /// 当前进度
    let progress = Variable<Float>(0)
    
    /// 司机姓名
    let driverName = Variable<String?>(nil)
    /// 车牌号
    let carLicence = Variable<String?>(nil)
    /// 当前距离
    let currentDistence = Variable<Int?>(nil)
    /// 总距离
    let totalDistence = Variable<Int?>(nil)
    /// speed
    let speed = Variable<Int?>(nil)
    /// 当前车辆定位点，方向
    let carLocation = Variable<(CLLocationCoordinate2D?, Int?)>((nil,nil))
    /// 当前定位(描述)
    let address = Variable<String?>(nil)
    /// 报警gps位置
    let alarmGps = Variable<[CLLocationCoordinate2D]>([])
    
    /// 当前时间
    let currentTime = Variable<Date?>(nil)
    /// 开始时间
    let startTime = Variable<Date?>(nil)
    /// 结束时间
    let endTime = Variable<Date?>(nil)
    
    /// 快速播放模式
    let isFastPlay = Variable<Bool>(false)
    /// 正在播放/暂停
    let isPlaying = Variable<Bool>(false)
    
    /// 需要解析地址
    private let needReverseCoor = PublishSubject<Void>()
    
    // from view
    /// 点击播放按钮
    let clickPlay = PublishSubject<Void>()
    /// 拖动进度条
    let changeProgress = PublishSubject<Float>()
    /// 点击正常播放速度
    let clickNormalSpeed = PublishSubject<Void>()
    /// 点击快速播放速度
    let clickFastSpeed = PublishSubject<Void>()
    
    /// 播放定时器
    private var playTimer: Timer?
    
    // MARK: - Method
    
    /// 初始化
    init(alarmInfo: ReqAlarmDetail.Data) {
        super.init()
        
        driverName.value = alarmInfo.driveName
        carLicence.value = alarmInfo.carLicense
     
        // 开始结束
        let alarmStartTime = alarmInfo.startTime?.yd.dateByMs() ?? Date()
        
        // 取整：
        let replayStartTime = Date(year: alarmStartTime.year, month: alarmStartTime.month, day: alarmStartTime.day, hour: alarmStartTime.hour, minute: 0, second: 0).subtract(1.hours)
        let replayEndTime = replayStartTime.add(3.hours)
        
        
        allTracks.asObservable()
            .filter { $0.first != nil}
            .map { $0.first?.time }
            .bind(to: startTime)
            .disposed(by: disposeBag)
        
        allTracks.asObservable()
            .filter { $0.last != nil}
            .map { $0.last?.time }
            .bind(to: endTime)
            .disposed(by: disposeBag)
        
        // 进度改变
        progress.asObservable()
            .map { [weak self] (value) -> Int in
                for (idx, aTrack) in (self?.allTracks.value ?? []).enumerated() {
                    if aTrack.progress >= value {
                        return idx
                    }
                }
                return 0
            }
            .bind(to: currnetTrackIndex)
            .disposed(by: disposeBag)
        
        // 当前车信息：
        Observable.combineLatest(allTracks.asObservable(), currnetTrackIndex.asObservable()) { (tracks, idx) -> TrackPointInfo? in
            return tracks.yd.element(of: idx)
            }
            .bind(to: currnetTrackInfo)
            .disposed(by: disposeBag)
        
        currnetTrackInfo.asObservable()
            .map { $0?.gps.speed.yd.int }
            .bind(to: speed)
            .disposed(by: disposeBag)
        
        currnetTrackInfo.asObservable()
            .map { $0?.time }
            .bind(to: currentTime)
            .disposed(by: disposeBag)
        
        currnetTrackInfo.asObservable()
            .map { $0?.distance }
            .bind(to: currentDistence)
            .disposed(by: disposeBag)
        
        currnetTrackInfo.asObservable()
            .map { ($0?.point, $0?.gps.direction) }
            .bind(to: carLocation)
            .disposed(by: disposeBag)
        
        carLocation.asObservable()
            .filter { [weak isPlaying] (_) in isPlaying?.value == true }
            .map({ (value) -> String? in
                if let lng = value.0?.longitude.yd.string, let lat = value.0?.latitude.yd.string {
                    return lng + "," + lat
                }
                return nil
            })
            .bind(to: address)
            .disposed(by: disposeBag)
        
        isPlaying.asObservable()
            .filter { $0 == false }
            .map { _ in }
            .bind(to: needReverseCoor)
            .disposed(by: disposeBag)
        
        carLocation.asObservable()
            .filter({ [weak self]  (_) -> Bool in
                self?.isPlaying.value == true
            })
            .map({ (value) -> String? in
                if let lng = value.0?.longitude.yd.string, let lat = value.0?.latitude.yd.string {
                    return lng + "," + lat
                }
                return nil
            })
            .bind(to: address)
            .disposed(by: disposeBag)
        
        needReverseCoor.asObservable()
            .flatMapLatest { [weak self] (_) -> Observable<String?> in
                return Constants.Tools.reverseGeoCodeRx(coordinate: self?.carLocation.value.0)
            }
            .bind(to: address)
            .disposed(by: disposeBag)
        
        // 用户事件
        clickPlay.asObservable()
            .subscribe(onNext: { [weak self] () in
                if self?.isPlaying.value == true {
                    self?.pausePlay()
                } else {
                    self?.startPlay()
                }
            })
            .disposed(by: disposeBag)
        
        changeProgress.asObservable()
            .bind(to: progress)
            .disposed(by: disposeBag)
        
        changeProgress.asObservable()
            .debounce(0.5, scheduler: MainScheduler.instance)
            .map { _ in }
            .bind(to: needReverseCoor)
            .disposed(by: disposeBag)
        
        clickNormalSpeed.asObservable()
            .map { false }
            .bind(to: isFastPlay)
            .disposed(by: disposeBag)
        
        clickFastSpeed.asObservable()
            .map { true }
            .bind(to: isFastPlay)
            .disposed(by: disposeBag)
        
        viewWillDisappear.asObservable()
            .map { false }
            .bind(to: isPlaying)
            .disposed(by: disposeBag)
        
        // 发送数据请求：
        requestReplayData(vehicleId: alarmInfo.vehicleId ?? "", start: replayStartTime, end: replayEndTime)
    }
    
    /// 请求轨迹数据
    private func requestReplayData(vehicleId: String, start: Date, end: Date) {
        
        let reqParam = ReqPlayback(vehicleId: vehicleId, startTime: start.yd.timeString(with: "yyyy-MM-dd HH:mm:ss") ?? "", endTime: end.yd.timeString(with: "yyyy-MM-dd HH:mm:ss") ?? "")
        let req = reqParam.toDataReuqest()
        
        req.isRequesting.asObservable()
            .map { (value) -> LoadingState in
                return LoadingState(isLoading: value, loadingText: nil)
            }
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
        
        req.responseRx.asObservable()
            .filter { $0.isSuccess() == false }
            .map { (rsp) -> AlertMessage in
                return AlertMessage(message: rsp.yjtm_errorMsg(), alertType: AlertMessage.AlertType.toast)
            }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        req.responseRx.asObservable()
            .filter { $0.isSuccess() && ($0.model?.dataList.count > 0) == false }
            .map { (_) -> AlertMessage in
                return AlertMessage(message: Constants.Text.noTrackReplay, alertType: AlertMessage.AlertType.toast)
            }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        req.responseRx.asObservable()
            .filter { $0.isSuccess() }
            .map { $0.model?.dataList ?? [] }
            .subscribe(onNext: { [weak self] (data) in
                self?.processGpsInfo(data)
            })
            .disposed(by: disposeBag)
        
        #if DEBUG
        req.send()
        #else
        req.send()
        #endif
        
    }
    
    /// 整理数据
    private func processGpsInfo(_ data: [ReqPlayback.Data]) {
        
        guard let start = data.first?.getDate() ?? startTime.value, let end = data.last?.getDate() ?? endTime.value else {
            return
        }
        
        var resultAry = [TrackPointInfo]()
        
        let fullTime = end.timeIntervalSince(start)
        var distance = 0
        let firstMilage: Int? = data.first?.mileage
        
        for aData in data {
            
            guard let currentCoor = aData.getCoordinate(), let time = aData.getDate() else {
                continue
            }
            
            let timePassed = time.timeIntervalSince(start)
            let progress: Float = Float(timePassed / fullTime)
            
            if let mileage = aData.mileage, let first = firstMilage {
                distance = mileage - first
            }
            
            resultAry.append(TrackPointInfo(gps: aData, point: currentCoor, time: time, distance: distance, progress: progress))
        }
        
        allTracks.value = resultAry
        totalDistence.value = distance
    }
    
    private func startPlay() {
        
        guard allTracks.value.count > 0 else {
            return
        }
        
        if progress.value == 1 { // 播放完毕重新播放
            progress.value = 0
        }
        
        playTimer?.invalidate()
        playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeFire), userInfo: nil, repeats: true)
        
        isPlaying.value = true
    }
    
    private func pausePlay() {
        
        playTimer?.invalidate()
        playTimer = nil
        isPlaying.value = false
        
    }
    
    
    @objc private func timeFire() {
        
        var idx = currnetTrackIndex.value
        
        if isFastPlay.value {
            idx += 10
        } else {
            idx += 2
        }
        
        if idx >= allTracks.value.count - 1 {
            idx = allTracks.value.count - 1
            pausePlay()
        }
        
        let targetTrack = allTracks.value.yd[idx]
        progress.value = targetTrack?.progress ?? 0
        
    }
    
}
