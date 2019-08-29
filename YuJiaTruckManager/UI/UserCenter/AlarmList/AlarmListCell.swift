//
//  AlarmListCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa
import SwiftyJSON
import Alamofire

/// 告警列表cell
class AlarmListCellVM: BaseCellVM {
    
    
    /// 缓存id
    var alarmId = ""
    /// 坐标
    var coordinate: CLLocationCoordinate2D?
    // to view
    
    /// 是否点开
    let isOpen = Variable<Bool>(false)
    
    /// 告警名字
    let alarmName = Variable<String?>(nil)
    /// 牌照信息
    let carLicense = Variable<String?>(nil)
    /// 驾驶员姓名
    let driverName = Variable<String?>(nil)
    /// 报警状态
    let alarmStatus = Variable<String?>(nil)
    /// 处理时长
    let processTime = Variable<String?>(nil)
    /// 处理人
    let processName = Variable<String?>(nil)
    /// 报警等级
    let alarmLevel = Variable<AlarmLevel?>(nil)
    /// 报警地点
    let address = Variable<String?>(nil)
    
    // from view
    /// 点击展开地址
    let clickShowAddress = PublishSubject<Void>()
    
     init(data :ReqAlarmList.Data) {
        super.init()
            alarmId = data.alarmId
            alarmName.value = data.alarmTypeName
            alarmLevel.value = AlarmLevel(intValue: data.level)
            driverName.value = data.driveName
            carLicense.value = data.carLicense.count > 0 ? "（\(data.carLicense)）" : nil
            processName.value = data.userName == "" ? "暂无" :data.userName
            alarmStatus.value = data.handleStatus == "0" ? "未处理" : "已处理"
            processTime.value =  data.handleSpendTime == nil ? "暂无"  :  timePeriodFromTime(time: data.handleSpendTime  ?? 0)
        
        coordinate = CLLocationCoordinate2D(latitude: data.gpsLat.yd.double ?? 0, longitude:data.gpsLng.yd.double ?? 0)
        
        clickShowAddress.asObservable()
            .map {[weak self] (_) ->  Bool in
                return !(self?.isOpen.value ?? false)
            }
            .bind(to: isOpen)
            .disposed(by: disposeBag)
        
        /// 是否需要解析
        isOpen.asObservable()
            .distinctUntilChanged()
            .filter { [weak self] (value) -> Bool in
                return value == true && (self?.address.value == nil)
            }
            .subscribe(onNext: { [weak self] (_) in
                self?.reverseGeoCode()
            })
            .disposed(by: disposeBag)
        
        
        clickShowAddress.asObservable()
            .map {}
            .bind(to: reload)
            .disposed(by: disposeBag)
        
        
    }
    
    /// 时间转时间段
    private func timePeriodFromTime(time :Double) -> String?{
        //时间戳为毫秒级要 ／ 1000
        let timeStamp:Int = Int(time / 1000)
        
        var periodStr = ""
     
        let days  =  Int(timeStamp / 3600 / 24)
        
        let hours =  Int((timeStamp - days * 60 * 60 * 24) / 3600)
        let mins  =  Int((timeStamp - days * 60 * 60 * 24 - hours * 60 * 60 ) / 60)
        
        let second = timeStamp - days * 60 * 60 * 24 - hours * 60 * 60 - mins * 60

        if  days > 0 {
            periodStr.append("\(days)天")
            
        }
        
        if  hours > 0 {
            periodStr.append("\(hours)时")

        }
        if  mins > 0{
            periodStr.append("\(mins)分")

        }
        if   second > 0 {
            periodStr.append("\(second)秒")
        }
        return periodStr
    }
    
    /// 解析地址
    private func reverseGeoCode() {
        
        Constants.Tools.reverseGeoCode(coordinate: coordinate) { [weak self] (address) in
            self?.address.value = address ?? Constants.Text.reverseGeoFailed
        }
    }

}

/// 告警列表cell
class AlarmListCell: BaseCell {
    
    // ui
    @IBOutlet private weak var alarmNameLbl: UILabel!
    @IBOutlet private weak var driverNameLbl: UILabel!
    @IBOutlet private weak var alarmStatusLbl: UILabel!
    @IBOutlet private weak var processTimeLbl: UILabel!
    @IBOutlet private weak var processNameLbl: UILabel!
    @IBOutlet private weak var alarmLevelBtn: UIButton!
    @IBOutlet private weak var showAddressBtn: UIButton!
    @IBOutlet private weak var addressLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "AlarmListCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! AlarmListCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "AlarmListCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        
        if let vm = viewModel as? AlarmListCellVM {
            if vm.isOpen.value == true {
                return 290
            } else {
                return 240
            }
        }
        
        return 240
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? AlarmListCellVM {
            
            vm.isOpen.asDriver()
                .drive(showAddressBtn.rx.isSelected)
                .disposed(by: disposeBag)
            
            vm.isOpen.asDriver()
                .map{!$0 }
                .drive(addressLbl.rx.isHidden)
                .disposed(by: disposeBag)
            
            /// 名字+拍照
            let nameAttr = vm.alarmName.asObservable()
                .map { ($0 ?? "--").yd.attrString(withAttributes: [NSAttributedString.Key.foregroundColor : Constants.Color.mainText, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]) }
                .share(replay: 1, scope: .whileConnected)
            
            let carLicenseAttr = vm.carLicense.asObservable()
                .map { ($0 ?? "").yd.attrString(withAttributes: [NSAttributedString.Key.foregroundColor : Constants.Color.lightText, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]) }
                .share(replay: 1, scope: .whileConnected)
            
            Observable<NSAttributedString?>.combineLatest(nameAttr, carLicenseAttr) { (v0, v1) -> NSAttributedString? in
                let str = NSMutableAttributedString(attributedString: v0)
                str.append(v1)
                return str
                }
                .asDriver(onErrorJustReturn: nil)
                .drive(alarmNameLbl.rx.attributedText)
                .disposed(by: disposeBag)

            
            vm.driverName.asDriver()
                .map { $0 ?? "--" }
                .drive(driverNameLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.alarmStatus.asDriver()
                .drive(alarmStatusLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.alarmStatus.asDriver()
                .drive(alarmStatusLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.processTime.asDriver()
                .drive(processTimeLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.processName.asDriver()
                .drive(processNameLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.alarmLevel.asDriver()
                .map { $0?.desc }
                .replaceEmpty("--")
                .drive(alarmLevelBtn.rx.title(for: .normal))
                .disposed(by: disposeBag)
            
            vm.alarmLevel.asDriver()
                .map { (value) -> UIImage? in
                    
                    switch value {
                    case AlarmLevel.one:
                        return UIImage(named: "bg_levelone")
                    case AlarmLevel.two:
                        return UIImage(named: "bg_leveltwo")
                    case AlarmLevel.three:
                        return UIImage(named: "bg_levelthree")
                    case AlarmLevel.four:
                        return UIImage(named: "bg_levelfour")
                    default:
                        return UIImage(named: "bg_levelfour")
                    }
                }
                .drive(alarmLevelBtn.rx.backgroundImage(for: .normal))
                .disposed(by: disposeBag)
            
            vm.address.asDriver()
                .drive(addressLbl.rx.text)
                .disposed(by: disposeBag)
            
            showAddressBtn.rx.tap.asObservable()
                .bind(to: vm.clickShowAddress)
                .disposed(by: disposeBag)
            
        }
        
        
    }
    
    
}
