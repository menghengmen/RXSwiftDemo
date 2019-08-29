//
//  AlarmDetailAlarmCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

/// 告警详情-告警信息cell
class AlarmDetailAlarmCellVM: BaseCellVM {
    
    /// 坐标
    var coordinate: CLLocationCoordinate2D?
    /// 数据缓存
    var data: ReqAlarmDetail.Data?
    
    // to view
    /// 报警类别
    let alarmType = Variable<String?>("")
    ///报警等级
    let alarmLevel = Variable<AlarmLevel?>(nil)
    
    /// 牌照信息
    let carLicense = Variable<String?>("")
    /// 报警时间
    let alarmTime = Variable<String?>("")
    /// 报警地址
    let alarmAddress = Variable<String?>("")
    
//    /// 是否可以点击图片
//    let isEnableClickImage = Variable<Bool>(false)
//    /// 是否可以点击视频
//    let isEnableClickVideo = Variable<Bool>(false)
    
    // from view
    /// 点击图片
    let didClickImage = PublishSubject<Void>()
    /// 点击视频
    let didClickVideo = PublishSubject<Void>()
    /// 点击轨迹
    let didClickTrack = PublishSubject<Void>()
    
    /// 点击
    let didTapTop = PublishSubject<Void>()
    /// 上滑
    let didSwipeUp = PublishSubject<Void>()
    /// 下滑
    let didSwipeDown = PublishSubject<Void>()
    
    /// 初始化，传入坐标就会自动解析地址，如果解析过了这里直接传地址
    init(address: String?, coordinate: CLLocationCoordinate2D?) {
        super.init()
        self.alarmAddress.value = address
        self.coordinate = coordinate
        
        if self.coordinate != nil {
            reverseGeoCode()
        }
    }
    
    /// 解析地址
    private func reverseGeoCode() {
        
        Constants.Tools.reverseGeoCode(coordinate: coordinate) { [weak self] (address) in
            self?.alarmAddress.value = address ?? Constants.Text.reverseGeoFailed
        }
        
    }
    
}


/// 告警详情-告警信息cell
class AlarmDetailAlarmCell: BaseCell {
    
    @IBOutlet private weak var alarmTypeLbl: UILabel!
    @IBOutlet private weak var alarmLevelLbl: UILabel!
    @IBOutlet private weak var carLicenceLbl: UILabel!
    @IBOutlet private weak var alarmTimeLbl: UILabel!
    @IBOutlet private weak var addressLbl: UILabel!
    @IBOutlet private weak var imageBtn: UIButton!
    @IBOutlet private weak var videoBtn: UIButton!
    @IBOutlet private weak var trackBtn: UIButton!
    
    @IBOutlet private weak var tapGes: UITapGestureRecognizer!
    @IBOutlet private weak var swipeUpGes: UISwipeGestureRecognizer!
    @IBOutlet private weak var swipeDownGes: UISwipeGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "AlarmDetailAlarmCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! AlarmDetailAlarmCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "AlarmDetailAlarmCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        
        return 346
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        if let vm =  viewModel as? AlarmDetailAlarmCellVM{
            vm.alarmType.asDriver()
                .replaceEmpty("--")
                .drive(alarmTypeLbl.rx.text)
                .disposed(by: disposeBag)
            vm.alarmLevel.asDriver()
                .map { $0?.desc }
                .map { $0 != nil ? "（\($0!)）" : nil}
                .drive(alarmLevelLbl.rx.text)
                .disposed(by: disposeBag)
            vm.carLicense.asDriver()
                .replaceEmpty("--")
                .drive(carLicenceLbl.rx.text)
                .disposed(by: disposeBag)
            vm.alarmTime.asDriver()
                .replaceEmpty("--")
                .drive(alarmTimeLbl.rx.text)
                .disposed(by: disposeBag)
            vm.alarmAddress.asDriver()
                .replaceEmpty("--")
                .drive(addressLbl.rx.text)
                .disposed(by: disposeBag)
            
//            vm.isEnableClickImage.asDriver()
//                .drive(imageBtn.rx.isEnabled)
//                .disposed(by: disposeBag)
//            vm.isEnableClickVideo.asDriver()
//                .drive(videoBtn.rx.isEnabled)
//                .disposed(by: disposeBag)
            
            imageBtn.rx.tap.asObservable()
                .bind(to: vm.didClickImage)
                .disposed(by: disposeBag)
            videoBtn.rx.tap.asObservable()
                .bind(to: vm.didClickVideo)
                .disposed(by: disposeBag)
            trackBtn.rx.tap.asObservable()
                .bind(to: vm.didClickTrack)
                .disposed(by: disposeBag)
            
            tapGes.rx.event.asObservable()
                .map({ (_) -> Void in })
                .bind(to: vm.didTapTop)
                .disposed(by: disposeBag)
            
            swipeUpGes.rx.event.asObservable()
                .map({ (_) -> Void in })
                .bind(to: vm.didSwipeUp)
                .disposed(by: disposeBag)
            
            swipeDownGes.rx.event.asObservable()
                .map({ (_) -> Void in })
                .bind(to: vm.didSwipeDown)
                .disposed(by: disposeBag)
            
        }
        
    }
    
    
}
