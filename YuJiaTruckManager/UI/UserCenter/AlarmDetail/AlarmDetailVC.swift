//
//  AlarmDetailVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 告警详情页
class AlarmDetailVC: BaseTableVC {
    
    /// 百度地图
    @IBOutlet private weak var mapView: BMKMapView!
    /// 菜单view
    @IBOutlet private weak var menuView: UIView!
    /// 菜单顶部的距离
    @IBOutlet private weak var menuTopSpace: NSLayoutConstraint!
    
    /// 菜单的高度
    private var menuFullHeight: CGFloat?
    /// 菜单的当前位置
    private var currentPostion: MenuPossion?
    /// 上次滑动位置
    private var lastPanPostion: CGPoint?
    
    /// 最大需要展示
    private var menuMaxHeight: CGFloat = 554
    /// 底部需要展示
    private var menuMinHeight: CGFloat = 224
    
    
    /// 菜单的位置
    enum MenuPossion {
        case top
        case bottom
    }
    
    // MARK: - Override
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.viewWillAppear()
        mapView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        mapView.viewWillDisappear()
        mapView.delegate = nil
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if menuFullHeight != menuView.frame.size.height {
            menuFullHeight = menuView.frame.size.height
            
            if menuFullHeight < menuMaxHeight {
                menuMaxHeight = menuFullHeight ?? 0
            }
            updateMenu(to: .bottom, animated: false)
        }
        
    }
    
    
    override func viewSetup() {
        super.viewSetup()
        
        navBarStyle = .translucentWithBlackTint
        tableView?.separatorColor = .white
        mapView.maxZoomLevel = 21
        
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? AlarmDetailVM {
            
            vm.isLoadingDetailInfo
                .asDriver()
                .drive(menuView.rx.isHidden)
                .disposed(by: disposeBag)

            vm.gpses.asDriver()
                .drive(onNext: { [weak self] (points) in
                    
                    self?.paintPoints(points)
                })
                .disposed(by: disposeBag)
            
            vm.didTapTop.asDriver(onErrorJustReturn: ())
                .drive(onNext: { [weak self] (_) in
                    if self?.currentPostion == .top {
                        self?.updateMenu(to: .bottom, animated: true)
                    } else {
                        self?.updateMenu(to: .top, animated: true)
                    }
                })
                .disposed(by: disposeBag)
            
            vm.didSwipeUp.asDriver(onErrorJustReturn: ())
                .drive(onNext: { [weak self] (_) in
                    if self?.currentPostion == .bottom {
                        self?.updateMenu(to: .top, animated: true)
                    }
                })
                .disposed(by: disposeBag)
            
            vm.didSwipeDown.asDriver(onErrorJustReturn: ())
                .drive(onNext: { [weak self] (_) in
                    if self?.currentPostion == .top {
                        self?.updateMenu(to: .bottom, animated: true)
                    }
                })
                .disposed(by: disposeBag)
        }
        
    }
    
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
        case is AlarmDetailAlarmCellVM:
            return AlarmDetailAlarmCell.self
        case is AlarmDetailDriverCellVM:
            return AlarmDetailDriverCell.self
        default:
            return nil
        }
    }
    
    
    
    // MARK: - Private
    
    /// 滑动菜单到某个位置
    private func updateMenu(to postion: MenuPossion, animated: Bool) {
        
        guard postion != currentPostion else {
            return
        }
        
        var topSapce: CGFloat = 0
        
        switch postion {
        case .top:
            topSapce = ((menuFullHeight ?? 0) - menuMaxHeight) > 0 ? ((menuFullHeight ?? 0) - menuMaxHeight) : 0
        case .bottom:
            topSapce = ((menuFullHeight ?? 0) - menuMinHeight) > 0 ? ((menuFullHeight ?? 0) - menuMinHeight) : 0
        }
        
        currentPostion = postion
        
        if animated {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.menuTopSpace.constant = topSapce
                self?.view.layoutIfNeeded()
            }
            
        } else {
            menuTopSpace.constant = topSapce
            view.layoutIfNeeded()
        }
        
    }
    
    
    /// 绘制点
    private func paintPoints(_ points: [CLLocationCoordinate2D]) {
        
        guard points.isEmpty == false else {
            return
        }
        
        if let centerPoint = points.first {
            // 起点作为显示中心
            mapView.centerCoordinate = centerPoint
        }
        
        if points.count == 1 { // 只有一个
            
            if let point = points.first {
                let an = BMKPointAnnotation()
                an.coordinate = point
                mapView.addAnnotation(an)
                
                mapView.zoomLevel = 20
            }
            
        } else { // 多个点
            
            mapView.zoomLevel = 19
            
            // 划线
            let linePointsBuf = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: points.count)
            for (idx,aPoint) in points.enumerated() {
                linePointsBuf[idx] = aPoint
            }
            
            let polyline = BMKPolyline(coordinates: linePointsBuf, count: UInt(points.count))
            mapView.add(polyline)
            linePointsBuf.deallocate()
            
            // 头尾加一个点
            if let firstPoint = points.first, let lastPoint = points.last {
                let firstAn = BMKPointAnnotation()
                firstAn.coordinate = firstPoint
                mapView.addAnnotation(firstAn)
                
                let lastAn = BMKPointAnnotation()
                lastAn.coordinate = lastPoint
                mapView.addAnnotation(lastAn)
            }
            
        }
        
    }
    
}

// MARK: - BMKMapViewDelegate
extension AlarmDetailVC: BMKMapViewDelegate {
    
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        
        if annotation is BMKPointAnnotation { /// 点的自定义
            
            let reuseIndetifier = "annotationReuseIndetifier"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIndetifier)
            
            if annotationView == nil {
                annotationView = BMKAnnotationView(annotation: annotation, reuseIdentifier: reuseIndetifier)
                annotationView?.image = UIImage(named: "icon_redPoint")
            }
            
            return annotationView
        }
        return nil
        
    }
    
    func mapView(_ mapView: BMKMapView!, viewFor overlay: BMKOverlay!) -> BMKOverlayView! {
        
        if overlay is BMKPolyline {
            let polylineView = BMKPolylineView(overlay: overlay)
            polylineView?.strokeColor = Constants.Color.red
            polylineView?.lineWidth = 4
            
            return polylineView
        }
        
        return nil
    }
    
}


