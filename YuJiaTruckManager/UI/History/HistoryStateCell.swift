//
//  HistoryStateCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa
import SnapKit

/// 历史统计-概况cell
class HistoryStateCellVM: BaseCellVM {
    
    /// 分布统计数据
    struct DistributionData {
        /// 安全报警
        var safetyAlarm: Int?
        /// 不良驾驶习惯报警
        var badHabitAlarm: Int?
        /// 事故报警
        var accidentAlarm: Int?
        /// 违规报警
        var violationAlarm: Int?
        
        /// 总共
        var all: Int {
            var result = 0
            
            result += safetyAlarm ?? 0
            result += badHabitAlarm ?? 0
            result += accidentAlarm ?? 0
            result += violationAlarm ?? 0
            return  result
        }
        
        /// 安全报警（百分比）
        var safetyAlarmPercent: String? {
            
            if all > 0, let value = safetyAlarm {
                return String(format: "%.2f%%", (Double(value) / Double(all) * 100))
            }
            return nil
        }
        
        /// 不良驾驶习惯报警（百分比）
        var badHabitAlarmPercent: String? {
            
            if all > 0, let value = badHabitAlarm {
                return String(format: "%.2f%%", (Double(value) / Double(all) * 100))
                
                
            }
            return nil
        }
        /// 事故报警（百分比）
        var accidentAlarmPercent: String? {
            
            if all > 0, let value = accidentAlarm {
                return String(format: "%.2f%%", (Double(value) / Double(all) * 100))
                
                
            }
            return nil
        }
        /// 违规报警（百分比）
        var violationAlarmPercent: String? {
            
            if all > 0, let value = violationAlarm {
                return String(format: "%.2f%%", (Double(value) / Double(all) * 100))
                
            }
            return nil
        }
        
    }
    
    // property
    
    /// 当前数据类型，默认昨天
    let currentType = Variable<HistoryDataType?>(nil)
    /// 加载完毕（错误信息）
    let didFinishLoad = PublishSubject<Bool>()
    
    private let didFinishLoadCount = PublishSubject<Bool>()
    private let didFinishLoadOnline = PublishSubject<Bool>()
    private let didFinishLoadType = PublishSubject<Bool>()
    
    // to view
    /// 统计前缀（今日，昨日，本月...）
    
    let statusPrefix = Variable<String>("")
    
    /// 在线车辆
    let onlineCar = Variable<String?>(nil)
    /// 总车辆
    let totalCar = Variable<String?>(nil)
    
    /// 在线司机
    let onlineDriver = Variable<String?>(nil)
    /// 总司机
    let totalDriver = Variable<String?>(nil)
    
    /// 报警总数
    let alarmNum = Variable<String?>(nil)
    /// 处理率
    let processPercent = Variable<String?>(nil)
    /// 已处理
    let processNum = Variable<String?>(nil)
    /// 未处理
    let unprocessNum = Variable<String?>(nil)
    
    /// 百分比数据
    let distributionData = Variable<DistributionData?>(nil)
    /// 报警数据
    let alarmCount = Variable<ReqGetAlarmCount.Data?>(nil)
    
    
    init(type: HistoryDataType?) {
        super.init()
        
        currentType.value = type
        
        /// 前缀
        currentType.asObservable()
            .filter { $0 != nil }
            .map { $0! }
            .map { $0.prefixName }
            .bind(to: statusPrefix)
            .disposed(by: disposeBag)
        
        /// 变化
        currentType.asObservable()
            .filter { $0 != nil }
            .map { $0! }
            .flatMapLatest { [weak self] (type) -> Observable<ReqGetAlarmCount.Data?> in
                return self?.alarmTodayCountReq(type: type) ?? .empty()
            }
            .subscribe(onNext: { [weak self] (data) in
                self?.reloadAlarmCount(from: data)
            })
            .disposed(by: disposeBag)
        
        currentType.asObservable()
            .filter { $0 != nil }
            .map { $0! }
            .flatMapLatest { [weak self] (type) -> Observable<ReqGetAlarmTypesCount.Data?> in
                return self?.alarmTypeCountReq(type: type) ?? .empty()
            }
            .subscribe(onNext: { [weak self] (data) in
                self?.reloadDistribution(from: data)
            })
            .disposed(by: disposeBag)
        
        currentType.asObservable()
            .filter { $0 != nil }
            .map { $0! }
            .flatMapLatest { [weak self] (type) -> Observable<ReqGetOnlineCount.Data?> in
                return self?.onlineCountReq(type: type) ?? .empty()
            }
            .subscribe(onNext: { [weak self] (data) in
                self?.reloadOnlineCount(from: data)
            })
            .disposed(by: disposeBag)
        
        /// 清空
        currentType.asObservable()
            .filter { $0 == nil }
            .subscribe(onNext: { [weak self] (_) in
                self?.reloadAlarmCount(from: nil)
                self?.reloadOnlineCount(from: nil)
                self?.reloadDistribution(from: nil)
            })
            .disposed(by: disposeBag)
        
        /// 加载完毕
        Observable<Bool>.zip(didFinishLoadCount.asObservable(), didFinishLoadOnline.asObservable(), didFinishLoadType.asObservable()) { (v1,v2,v3) -> Bool in
            return v1 && v2 && v3
            }
            .bind(to: didFinishLoad)
            .disposed(by: disposeBag)
        
    }
    
    /// 数据转为view model
    private func reloadAlarmCount(from data: ReqGetAlarmCount.Data?)  {
        
        /// 今日概况
        alarmNum.value = data?.totalCount != nil ? "\(data?.totalCount ?? 0)" : nil
        processNum.value = data?.handleCount != nil ? "\(data?.handleCount ?? 0)" : nil
        unprocessNum.value = data?.noHandleCount != nil ? "\(data?.noHandleCount ?? 0)" : nil
       
        processPercent.value =  data?.totalCount > 0 ? String(format: "%.2f", Double(data?.handleCount ?? 0)/Double(data?.totalCount ?? 0) * 100) : nil
    }
    
    private func reloadOnlineCount(from data: ReqGetOnlineCount.Data?)  {
        
        onlineCar.value = data?.vehicleOnlineCount
        totalCar.value = data?.vehicleCount
        onlineDriver.value = data?.driverIcCount
        totalDriver.value = data?.driverCount
    }
    
    private func reloadDistribution(from data: ReqGetAlarmTypesCount.Data?)  {
        
        /// 环形图
        var distributionData = HistoryStateCellVM.DistributionData()
        
        distributionData.safetyAlarm = data?.securityActive
        distributionData.badHabitAlarm = data?.badDriving
        distributionData.accidentAlarm = data?.accidentAlarm
        distributionData.violationAlarm = data?.illegalAlarm
        
        self.distributionData.value = distributionData
    }
    
    
    fileprivate func extractedFunc(_ startTime: String, _ endTime: String) -> ReqGetAlarmCount {
        return ReqGetAlarmCount(startTime: startTime, endTime: endTime , groupId: DataCenter.shared.userInfo.value?.groupId ?? "")
    }
    
    /// 请求今日报警数
    private func alarmTodayCountReq(type: HistoryDataType) ->Observable<ReqGetAlarmCount.Data?>{
        
        let reqParam = ReqGetAlarmCount(startTime: type.startTimeStr, endTime: type.endTimeStr , groupId: DataCenter.shared.userInfo.value?.groupId ?? "")

       
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
            .map { (rsp) -> ReqGetAlarmCount.Data? in
                return rsp.model?.data
        }
        
        /// 加载完毕
        req.responseRx
            .map { $0.isSuccess() }
            .bind(to: didFinishLoadCount)
            .disposed(by: disposeBag)
        
        req.send()
        return result
        
    }
    
    /// 请求分类告警数
    private func alarmTypeCountReq(type: HistoryDataType) ->Observable<ReqGetAlarmTypesCount.Data?>{
        
        let reqParam = ReqGetAlarmTypesCount(startTime: type.startTimeStr, endTime: type.endTimeStr , groupId: DataCenter.shared.userInfo.value?.groupId ?? "")
        
        
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
            .map { (rsp) -> ReqGetAlarmTypesCount.Data? in
                return rsp.model?.data
        }
        
        /// 加载完毕
        req.responseRx
            .map { $0.isSuccess() }
            .bind(to: didFinishLoadType)
            .disposed(by: disposeBag)
        
        req.send()
        return result
    }
    
    /// 请求在线数
    private func onlineCountReq(type: HistoryDataType) ->Observable<ReqGetOnlineCount.Data?>{
        
        let reqParam = ReqGetOnlineCount(startTime: type.startTimeStr, endTime: type.endTimeStr , groupId: DataCenter.shared.userInfo.value?.groupId ?? "")
        
        
        let req = reqParam.toDataReuqest()
        
        let result = req.responseRx.asObservable()
            .map { (rsp) -> ReqGetOnlineCount.Data? in
                return rsp.model?.data
        }
        
        /// 加载完毕
        req.responseRx
            .map { $0.isSuccess() }
            .bind(to: didFinishLoadOnline)
            .disposed(by: disposeBag)
        
        req.send()
        return result
    }
    
}

/// 历史统计-概况cell
class HistoryStateCell: BaseCell {
    
    // 概况：
    @IBOutlet private weak var summaryTitleLbl: UILabel!
    
    @IBOutlet private weak var onlineCarTitleLbl: UILabel!
    @IBOutlet private weak var onlineCarValueLbl: UILabel!
    
    @IBOutlet private weak var onlineDriverTitleLbl: UILabel!
    @IBOutlet private weak var onlineDriverValueLbl: UILabel!
    
    @IBOutlet private weak var alarmNumTitleLbl: UILabel!
    @IBOutlet private weak var alarmNumValueLbl: UILabel!
    
    @IBOutlet private weak var processPercentValueLbl: UILabel!
    @IBOutlet private weak var processNumValueLbl: UILabel!
    @IBOutlet private weak var unprocessNumValueLbl: UILabel!
    
    // 分布：
    @IBOutlet private weak var alarmDistributionTitleLbl: UILabel!
    @IBOutlet private weak var safetyAlarmPercentLbl: UILabel!
    @IBOutlet private weak var badHabitAlarmPercentLbl: UILabel!
    @IBOutlet private weak var accidentAlarmPercentLbl: UILabel!
    @IBOutlet private weak var violationAlarmPercentLbl: UILabel!
    
    // 饼图
    @IBOutlet private weak var chartsContainerView: UIView!
    private var pieChart: ZFPieChart!
    private var pieData = [(String, UIColor)]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let aPieChart = ZFPieChart(frame: chartsContainerView.bounds)
        pieChart = aPieChart
        
        chartsContainerView.addSubview(pieChart)
        pieChart.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        pieChart.isShadow = false
        pieChart.isAnimated = false
        pieChart.isShowPercent = false
        
        pieChart.delegate = self
        pieChart.dataSource = self
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "HistoryStateCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! HistoryStateCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "HistoryStateCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 720
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? HistoryStateCellVM {
            
            // 概况
            vm.statusPrefix.asDriver()
                .map { $0 + "概况" }
                .drive(summaryTitleLbl.rx.text)
                .disposed(by: disposeBag)
            
            // 车辆
            vm.statusPrefix.asDriver()
                .map { $0 + "在线车辆" }
                .drive(onlineCarTitleLbl.rx.text)
                .disposed(by: disposeBag)
            
            let onlineCarAttrTxt = vm.onlineCar.asObservable()
                .replaceEmpty("-")
                .map { $0.yd.attrString(withAttributes: [NSAttributedString.Key.foregroundColor : Constants.Color.mainText, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)]) }
            
            let totalCarAttrTxt = vm.totalCar.asObservable()
                .replaceEmpty("-")
                .map { "/\($0)".yd.attrString(withAttributes: [NSAttributedString.Key.foregroundColor : Constants.Color.lightText, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]) }
            
            Observable.zip(onlineCarAttrTxt, totalCarAttrTxt) { (v0, v1) -> NSAttributedString in
                let str = NSMutableAttributedString(attributedString: v0)
                str.append(v1)
                return str
                }
                .asDriver(onErrorJustReturn: NSAttributedString())
                .drive(onlineCarValueLbl.rx.attributedText)
                .disposed(by: disposeBag)
            
            // 插卡人数
            vm.statusPrefix.asDriver()
                .map { $0 + "插卡人数" }
                .drive(onlineDriverTitleLbl.rx.text)
                .disposed(by: disposeBag)
            
            let onlineDriverAttrTxt = vm.onlineDriver.asObservable()
                .replaceEmpty("-")
                .map { $0.yd.attrString(withAttributes: [NSAttributedString.Key.foregroundColor : Constants.Color.mainText, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)]) }
            
            let totalDriverAttrTxt = vm.totalDriver.asObservable()
                .replaceEmpty("-")
                .map { "/\($0)".yd.attrString(withAttributes: [NSAttributedString.Key.foregroundColor : Constants.Color.lightText, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]) }
            
            Observable.zip(onlineDriverAttrTxt, totalDriverAttrTxt) { (v0, v1) -> NSAttributedString in
                let str = NSMutableAttributedString(attributedString: v0)
                str.append(v1)
                return str
                }
                .asDriver(onErrorJustReturn: NSAttributedString())
                .drive(onlineDriverValueLbl.rx.attributedText)
                .disposed(by: disposeBag)
            
            // 报警
            vm.statusPrefix.asDriver()
                .map { $0 + "报警总数" }
                .drive(alarmNumTitleLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.alarmNum.asDriver()
                .replaceEmpty("--")
                .drive(alarmNumValueLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.processPercent.asDriver()
                .replaceEmpty("--")
                .drive(processPercentValueLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.processNum.asDriver()
                .replaceEmpty("--")
                .drive(processNumValueLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.unprocessNum.asDriver()
                .replaceEmpty("--")
                .drive(unprocessNumValueLbl.rx.text)
                .disposed(by: disposeBag)
            
            // 分布
            vm.distributionData.asDriver()
                .drive(onNext: { [weak self] (data) in
                    self?.reloadPieView(data: data)
                })
                .disposed(by: disposeBag)
            
            
            vm.statusPrefix.asDriver()
                .map { $0 + "报警分布" }
                .drive(alarmDistributionTitleLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.distributionData.asDriver()
                .map { $0?.safetyAlarmPercent }
                .replaceEmpty("--")
                .drive(safetyAlarmPercentLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.distributionData.asDriver()
                .map { $0?.badHabitAlarmPercent}
                .replaceEmpty("--")
                .drive(badHabitAlarmPercentLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.distributionData.asDriver()
                .map { $0?.accidentAlarmPercent}
                .replaceEmpty("--")
                .drive(accidentAlarmPercentLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.distributionData.asDriver()
                .map { $0?.violationAlarmPercent}
                .replaceEmpty("--")
                .drive(violationAlarmPercentLbl.rx.text)
                .disposed(by: disposeBag)
            
        }
        
        
    }
    
    private func reloadPieView(data: HistoryStateCellVM.DistributionData?) {
        pieData.removeAll()
        if let value = data?.safetyAlarm {
            pieData.append(("\(value)", mColor(0xF98F1D)))
        }
        if let value = data?.badHabitAlarm {
            pieData.append(("\(value)", mColor(0x47476A)))
        }
        if let value = data?.accidentAlarm {
            pieData.append(("\(value)", mColor(0x675FF2)))
        }
        if let value = data?.violationAlarm {
            pieData.append(("\(value)", mColor(0xEA3D04)))
        }
        
        var allZero = true
        for aData in pieData {
            if aData.0.yd.intValue > 0 {
                allZero = false
            }
        }
        
        if allZero {
            pieData.append(("1", mColor(0xE8E8E8)))
        }
        
        mLog("【绘制点】:value\(pieData)")
        
        pieChart.strokePath()
    }
}


extension HistoryStateCell: ZFPieChartDataSource {
    
    func valueArray(in pieChart: ZFPieChart!) -> [Any]! {
        return pieData.map { $0.0 }
    }
    
    func colorArray(in pieChart: ZFPieChart!) -> [Any]! {
        return pieData.map { $0.1 }
    }
}

extension HistoryStateCell: ZFPieChartDelegate {
    
    func radius(for pieChart: ZFPieChart!) -> CGFloat {
        return 80
    }
    
    func radiusAverageNumber(ofSegments pieChart: ZFPieChart!) -> CGFloat {
        return 4
    }
}



