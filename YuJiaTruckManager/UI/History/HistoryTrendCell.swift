//
//  HistoryTrendCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit

import YuDaoComponents
import RxSwift
import RxCocoa
import SnapKit
import DateToolsSwift



/// 历史统计-第三方考核cell
class HistoryTrendCellVM: BaseCellVM {
   
    // 点数据
    struct Point: Hashable {
        /// 数量
        var value: Int
        /// 时间戳（毫秒）
        var time: Int64
    }

    // 属性
    /// 是否支持左滑
    let isEnableSwipe: Bool
    /// 加载完毕（是否成功）
    let didFinishLoad = PublishSubject<Bool>()
    /// 当前数据类型，默认昨天
    let currentType = Variable<HistoryDataType?>(nil)
    
    // to view
    /// 点数据
    let points = Variable<[Point]>([])
    /// 加载中
    let isLoading = Variable<Bool>(false)
    
    // from view
    /// 左滑
    let didSwipeDate = PublishSubject<Void>()
    
    init(type: HistoryDataType?, isEnableSwipe: Bool = false) {
        
        self.isEnableSwipe = isEnableSwipe
        super.init()
        
        currentType.value = type
        
        /// 左滑刷新数据
        didSwipeDate.asObservable()
            .filter({ [weak self] (_) -> Bool in
                return self?.isEnableSwipe == true // 支持滑动加载
            })
            .map({ [weak self] (_) -> HistoryDataType in
                let currentStartDate = self?.currentType.value?.startDate ?? Date()
                let lastMonthDay = currentStartDate - 1.months
                let resultDateType = HistoryDataType(startDate: lastMonthDay, endDate: self?.currentType.value?.endDate ?? Date())
                return resultDateType
            })
            .bind(to: currentType)
            .disposed(by: disposeBag)
        
        
        /// 切换时间范围
        currentType.asObservable()
            .filter { $0 != nil }
//            .distinctUntilChanged()
            .map { $0! }
            .flatMapLatest { [weak self] (type) -> Observable<[ReqAlarmTrend.Data]> in
                return self?.getAlarmTrend(type: type) ?? .empty()
            }
            .map { [weak self] (data) -> [Point] in
                return self?.points(from: data) ?? []
            }
            .bind(to: points)
            .disposed(by: disposeBag)
        
        /// 清空
        currentType.asObservable()
            .filter { $0 == nil }
            .map { [weak self] (_) -> [Point] in
                return self?.points(from: []) ?? []
            }
            .bind(to: points)
            .disposed(by: disposeBag)
        
    }
    
    
    /// 请求报警趋势
    public func getAlarmTrend(type: HistoryDataType) ->Observable<[ReqAlarmTrend.Data]>{
       
        let reqParam = ReqAlarmTrend(startTime: type.startTimeIntervalMs, endTime: type.endTimeIntervalMs, groupId: DataCenter.shared.userInfo.value?.groupId ?? "")
        let req = reqParam.toDataReuqest()
        req.isRequesting.asObservable()
            .bind(to: isLoading)
            .disposed(by: disposeBag)
        
        let result = req.responseRx.asObservable()
        let success = result
            .filter { $0.isSuccess() }
            .map { (rsp) -> [ReqAlarmTrend.Data]? in
                return (rsp.model?.dataList ?? [])
                
            }
            .filter { $0 != nil }
            .map { $0! }
        
        /// 加载完毕
        result
            .map { $0.isSuccess() }
            .bind(to: didFinishLoad)
            .disposed(by: disposeBag)
        
        
        req.send()
        return  success
        
    }
    
    /// 取出数据
    public func points(from data :[ReqAlarmTrend.Data]) -> [Point] {
        var result = [Point]()
        for aData in data{
            result.append(HistoryTrendCellVM.Point(value: aData.totalCount ?? 0, time: aData.time ?? 0))
        }
        return result
    }
    
    
}

/// 历史统计-第三方考核cell
class HistoryTrendCell: BaseCell {
    
    
    // ui
    @IBOutlet private weak var chartsContainerView: UIView!
    @IBOutlet private weak var loadingView: UIView!
    @IBOutlet private weak var emptyView: UIView!
    
    private weak var lineChart: ZFLineChart!
    weak var viewModel: HistoryTrendCellVM?

 
    
    /// 点数据
    private var points = [HistoryTrendCellVM.Point]()
   
    
    /// 左滑的回调
    private  var swipeDateBlock: (() -> Void)?
    
    /// 拖拽中
    private var isDraging = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        /// 折线图初始化
        let aLineChart = ZFLineChart(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: 250))
        lineChart = aLineChart
        
        lineChart.genericAxis.xAxisLine.xLineSectionCount = 7
        
        lineChart.isShadow = false
        lineChart.isAnimated = false
        
        lineChart.isShowXLineSeparate = false
        lineChart.isShowYLineSeparate = true
        lineChart.isShowAxisArrows = false
        lineChart.isShowAxisLineValue = false
        
        lineChart.genericAxis.bounces = true
        
        
        lineChart.separateColor = mColor(0x999999, 0.1)
        lineChart.xAxisColor = mColor(0x999999, 0.1)
        lineChart.yAxisColor = .clear
        
        lineChart.axisLineNameColor = mColor(0x999999)
        lineChart.axisLineValueColor = mColor(0x999999)
        lineChart.axisLineNameFont = UIFont.systemFont(ofSize: 12)
        lineChart.axisLineValueFont = UIFont.systemFont(ofSize: 12)
        
        lineChart.dataSource = self
        lineChart.delegate = self
        
        chartsContainerView.addSubview(lineChart)
        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "HistoryTrendCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! HistoryTrendCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "HistoryTrendCell"
    }
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 340
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? HistoryTrendCellVM {
           self.viewModel = vm
            vm.points.asDriver()
                .distinctUntilChanged()
                .delay(0.1)
                .drive(onNext: { [weak self] (value) in
                    
                    self?.points = value
                    self?.lineChart.strokePath()
                })
                .disposed(by: disposeBag)
            
            vm.points.asDriver()
                .map { $0.count > 0 }
                .drive(emptyView.rx.isHidden)
                .disposed(by: disposeBag)
            
            vm.isLoading.asDriver()
                .map { !$0 }
                .drive(loadingView.rx.isHidden)
                .disposed(by: disposeBag)
            
            swipeDateBlock = { [weak vm] in
                vm?.didSwipeDate.onNext(())
            }
            
        }
    }
    
    
}


extension HistoryTrendCell: ZFGenericChartDataSource {
    func valueArray(in chart: ZFGenericChart!) -> [Any]! {
        return points.map { "\($0.value)" }
    }
    
    func nameArray(in chart: ZFGenericChart!) -> [Any]! {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return points.map { $0.time.yd.timeString(withFormatter: formatter) ?? "-/-"}
    }
    
    func axisLineSectionCount(in chart: ZFGenericChart!) -> UInt {
        return 4
    }
    
    func colorArray(in chart: ZFGenericChart!) -> [Any]! {
        return [mColor(0xB21EE7)]
    }
    ///滑动
    func genericChartDidScroll(_ scrollView: UIScrollView!) {
        
//        mLog("【位移】：\(scrollView.contentOffset.x)")
        if scrollView.contentOffset.x < -20 && isDraging == false {
            isDraging = true
            swipeDateBlock?()
        } else if scrollView.contentOffset.x > -20 {
            isDraging = false
        }
        
    }
    /// 自动滚动的位置
    func axisLineStartToDisplayValue(atIndex chart: ZFGenericChart!) -> Int {
        
        // 是否显示当月最后一天，而不是从头显示
        var showLastDayOfMonth = false

        let startDate = viewModel?.currentType.value?.startDate ?? Date()
        let startMonthFirstDate = Date(year: startDate.year, month: startDate.month, day: 1)
        let startMonthLastDate = (startMonthFirstDate.add(1.months) - 1.days)
//        let lastPointDate = (viewModel?.currentType.value?.endDate ?? Date())

        let sectionCount = (chart as! ZFLineChart).genericAxis.xAxisLine.xLineSectionCount
        
        if viewModel?.isEnableSwipe == true { /// 可以滑动时，默认显示最后一天
            showLastDayOfMonth = true
        }
        
        if viewModel?.currentType.value == HistoryDataType.thisMonth
            || viewModel?.currentType.value == HistoryDataType.yestodayOneWeek  { 
            showLastDayOfMonth = true
        }
        
        /// 点太少的话无法推前显示
        if points.count < sectionCount {
            showLastDayOfMonth = false
        }
        
        var startPoint = 0
        
        if showLastDayOfMonth {
            
            if startDate.isLater(than: startMonthFirstDate) // 不是完整一个月的数据
                || points.count < startMonthLastDate.day { // 当前这个月还没结束
                
                startPoint = points.count - sectionCount + 1
            } else {
                startPoint = startMonthLastDate.day - sectionCount + 1
            }
        }
        
        mLog("【折线图】：\(startPoint) in \(points.count)")
        
        return startPoint
        
    }
    
    func axisLineMaxValue(in chart: ZFGenericChart!) -> CGFloat {
        var allZero = true
        for aPoint in points {
            if aPoint.value > 0 {
                allZero = false
                break
            }
        }
        if allZero {
            return 100
        } else {
            return 0
        }
    }


}

extension HistoryTrendCell: ZFLineChartDelegate {
    
    func circleRadius(in lineChart: ZFLineChart!) -> CGFloat {
        return 5.0
    }
    
    func lineChart(_ lineChart: ZFLineChart!, didSelectCircleAtLineIndex lineIndex: Int, circleIndex: Int, circle: ZFCircle!, popoverLabel: ZFPopoverLabel!) {
        
        popoverLabel.isHidden = false
        
    }
    
}
