//
//  AlarmDetailVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 告警详情页
class AlarmDetailVM: BaseTableVM {
    
    /// 告警详情id
    var alarmId: String
    /// 是否已经解析过地址了
    var address: String?
    /// 坐标（没解析过地址，在这里解析）
    var coordinate: CLLocationCoordinate2D?
    
    // to view
    /// 加载数据中
    let isLoadingDetailInfo = Variable<Bool>(true)
    /// 定位点数组
    let gpses = Variable<[CLLocationCoordinate2D]>([])
    
    // from view
    /// 点击
    let didTapTop = PublishSubject<Void>()
    /// 上滑
    let didSwipeUp = PublishSubject<Void>()
    /// 下滑
    let didSwipeDown = PublishSubject<Void>()
    
    init(alarmId: String, address: String? = nil, coordinate:  CLLocationCoordinate2D? = nil) {
        self.alarmId = alarmId
        self.address = address
        self.coordinate = coordinate
        super.init()
       
       let requestSuccess = viewDidLoad.asObservable()
            .flatMapLatest { [weak self] (_) -> Observable<ReqAlarmDetail.Data?> in
                return self?.requestDetailData(alarmId: self?.alarmId ?? "") ?? .empty()
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)

        requestSuccess
            .map { [weak self] (data) -> [BaseSectionVM]? in
                return self?.viewModel(from: data)
            }
            .bind(to: dataSource)
            .disposed(by: disposeBag)
        
        requestSuccess
            .map { (data) -> [CLLocationCoordinate2D] in
                var points = [CLLocationCoordinate2D]()
                
                for aGps in data?.gpses ?? [] {
                    if let coor = aGps.getCoordinate() {
                        points.append(coor)
                    }
                }
                return points
            }
            .bind(to: gpses)
            .disposed(by: disposeBag)

        
    }
    
    private func viewModel(from data: ReqAlarmDetail.Data?) -> [BaseSectionVM]? {
        // 报警信息
        let sectionAlarm = BaseSectionVM()
        let alarmDetailCell = AlarmDetailAlarmCellVM(address: address, coordinate: coordinate)
        alarmDetailCell.data = data
        alarmDetailCell.alarmLevel.value = AlarmLevel(intValue: data?.level)
        alarmDetailCell.alarmType.value = data?.alarmTypeName
        alarmDetailCell.alarmTime.value = data?.startTime?.yd.timeString()
        
        /// 车牌号
        alarmDetailCell.carLicense.value = data?.carLicense
        /// 图片
//        alarmDetailCell.isEnableClickImage.value = data?.getFiles(by: .image).count > 0
        
        /// 视频
//        alarmDetailCell.isEnableClickVideo.value = data?.getFiles(by: .video).count > 0
        // 点击图片
        alarmDetailCell.didClickImage.asObservable()
            .filter({ [weak alarmDetailCell] (_) -> Bool in
                alarmDetailCell?.data?.getFiles(by: .image).count > 0
            })
            .map { [weak alarmDetailCell] (_) -> RouterInfo in
                return (Router.UserCenter.goImageList, ["attachType": ReqAlarmDetail.AttachType.image, "files": alarmDetailCell?.data?.getFiles(by: .image) ?? []])
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
       
        // 点击图片（空）
        alarmDetailCell.didClickImage.asObservable()
            .filter({ [weak alarmDetailCell] (_) -> Bool in
                (alarmDetailCell?.data?.getFiles(by: .image).count > 0) == false
            })
            .map { (cellVM) -> AlertMessage in
                return AlertMessage(message: Constants.Text.alarmNoImage, alertType: .toast)
            }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        // 点击视频
        alarmDetailCell.didClickVideo.asObservable()
            .filter({ [weak alarmDetailCell] (_) -> Bool in
                alarmDetailCell?.data?.getFiles(by: .video).count > 0
            })
            .map { (cellVM) -> RouterInfo in
                return (Router.UserCenter.goImageList, ["attachType": ReqAlarmDetail.AttachType.video, "files": data?.getFiles(by: .video) ?? []])
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        // 点击视频（无）
        alarmDetailCell.didClickVideo.asObservable()
            .filter({ [weak alarmDetailCell] (_) -> Bool in
                (alarmDetailCell?.data?.getFiles(by: .video).count > 0) == false
            })
            .map { (cellVM) -> AlertMessage in
                return AlertMessage(message: Constants.Text.alarmNoVideo, alertType: .toast)
            }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        // 点击轨迹回放
        alarmDetailCell.didClickTrack.asObservable()
            .filter({ [weak alarmDetailCell] (_) -> Bool in
                MobClick.event("track_playback")

                if alarmDetailCell?.data?.vehicleId?.count > 0 && alarmDetailCell?.data?.startTime != nil {
                    return true
                } else {
                    return false
                }
            })
            .map { [weak alarmDetailCell] (cellVM) -> RouterInfo in
                return (Router.UserCenter.goTrackReplay, ["alarmDetail": alarmDetailCell?.data])
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        alarmDetailCell.didTapTop.asObservable()
            .bind(to: didTapTop)
            .disposed(by: disposeBag)
        
        alarmDetailCell.didSwipeUp.asObservable()
            .bind(to: didSwipeUp)
            .disposed(by: disposeBag)
        
        alarmDetailCell.didSwipeDown.asObservable()
            .bind(to: didSwipeDown)
            .disposed(by: disposeBag)
        
        
        sectionAlarm.cellViewModels.append(alarmDetailCell)
        
       
        /// 驾驶员信息
        let sectionDriver = BaseSectionVM()
        let alarmDetailDriver = AlarmDetailDriverCellVM()
        alarmDetailDriver.driverName.value = data?.driveName
        alarmDetailDriver.phone.value = data?.telephone
        alarmDetailDriver.company.value = data?.groupName
        sectionDriver.cellViewModels.append(alarmDetailDriver)
        
        
        return [sectionAlarm,sectionDriver]
    
    }
    /// 报警详情网路请求
    private func requestDetailData(alarmId: String) -> Observable<ReqAlarmDetail.Data?> {
        

        let reqParam = ReqAlarmDetail(alarmId: alarmId)
        let req = reqParam.toDataReuqest()
        
        req.isRequesting.asObservable()
            .bind(to: isLoadingDetailInfo)
            .disposed(by: disposeBag)
        
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
        
        let result = req.responseRx.asObservable()
            .map { (rsp) -> ReqAlarmDetail.Data? in
                return rsp.model?.data
        }
        
        #if DEBUG
        req.send()
        #else
        req.send()
        #endif
        
        return result
    }

}
