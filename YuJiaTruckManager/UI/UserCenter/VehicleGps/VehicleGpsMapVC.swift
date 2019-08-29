//
//  VehicleGpsMapVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/12/24.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// GPS-地图页
class VehicleGpsMapVC: BaseVC {
    
    // MARK: - Property
    
    @IBOutlet private weak var filterBtn: UIBarButtonItem!
    @IBOutlet private weak var searchBtn: UIButton!
    
    @IBOutlet private weak var carLicenceLbl: UILabel!
    @IBOutlet private weak var companyNameLbl: UILabel!
    @IBOutlet private weak var speedLbl: UILabel!
    @IBOutlet private weak var addressLbl: UILabel!
    @IBOutlet private weak var monitorBtn: UIButton!
    @IBOutlet private weak var menuBottomSpeace: NSLayoutConstraint!
    
    /// 百度地图
    @IBOutlet private weak var mapView: BMKMapView!
    /// 所有车辆
    private var vehiclesDic = [String : ReqQueryAllVehiclesGps.Data]()
    /// 聚合处理器
    private var clusterManager = BMKClusterManager()
    
//    private var
    
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
    
    override func viewSetup() {
        super.viewSetup()
        
    }
   
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? VehicleGpsMapVM {
            
            filterBtn.rx.tap.asObservable()
                .bind(to: vm.clickFilter)
                .disposed(by: disposeBag)
            
            searchBtn.rx.tap.asObservable()
                .bind(to: vm.clickSearch)
                .disposed(by: disposeBag)
            
            vm.isShowVehcileDetail.asDriver()
                .debounce(0.1)
                .drive(onNext: { [weak self] (value) in
                    self?.updateMenuPosition(value)
                })
                .disposed(by: disposeBag)
            
            vm.carLicence.asDriver()
                .replaceEmpty("--")
                .drive(carLicenceLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.companyName.asDriver()
                .replaceEmpty("--")
                .drive(companyNameLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.speed.asDriver()
                .map { $0 != nil ? "\($0!)km/h" : "--km/h" }
                .drive(speedLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.address.asDriver()
                .replaceEmpty("--")
                .drive(addressLbl.rx.text)
                .disposed(by: disposeBag)
            
            monitorBtn.rx.tap.asObservable()
                .bind(to: vm.clickMonitor)
                .disposed(by: disposeBag)
            
            vm.allVehicles.asDriver()
                .delay(0.1) // 等待viewWillAppear的处理
                .drive(onNext: { [weak self] (data) in
                    var dic = [String : ReqQueryAllVehiclesGps.Data]()
                    var coors = [CLLocationCoordinate2D]()
                    self?.clusterManager.clearClusterItems()
                    
                    for aData in data {
                        
                        guard let vehicleKey = aData.getCoordinate()?.getKey() else {
                            continue
                        }
                        
                        dic[vehicleKey] = aData
                        
                        let clusterItem = BMKClusterItem()
                        if let coor = aData.getCoordinate() {
                            coors.append(coor)
                            clusterItem.coor = coor
                            clusterItem.infoDic = ["vehicleCoor": vehicleKey]
                            self?.clusterManager.add(clusterItem)
                        }
                    }
                    self?.vehiclesDic = dic
                    self?.computeMapRegion(coors)
                })
                .disposed(by: disposeBag)
        }
        
    }
    
    // MARK: - Private Method
    
    /// 过滤车辆，返回vehicleId数组
    private func filterVehciles(zoomLevel: Float, visibleMapRect: BMKMapRect) {
        mLog("【聚合】zoomLevel:\(zoomLevel), visibleMapRect:\(visibleMapRect.origin.x),\(visibleMapRect.origin.y),\(visibleMapRect.size.width),\(visibleMapRect.size.height)")
        DispatchQueue.global(qos: .default).async(execute: { [weak self] () -> Void in
            
            ///获取聚合后的标注
            if let array = self?.clusterManager.getClusters(zoomLevel, visibleMapRect: visibleMapRect) {
                
                var ids = Set<String>()
                
                let allCount = array.reduce(0, { (rs, cluster) -> Int in
                    return rs + (cluster.clusterItems?.count ?? 0)
                })
                
                /// 是否只展示聚合中部分点
                let showSomePoint = zoomLevel < 18 && allCount > 100
                
                for aCluster in array {
                    
                    guard let items = aCluster.clusterItems as? [BMKClusterItem] else {
                        continue
                    }
                    
                    for (idx, anItem) in items.enumerated() {
                        
                        if showSomePoint && idx > 1 { // 只取前两个
                            break
                        }
                        ids.insert(anItem.infoDic?["vehicleCoor"] as? String ?? "")
                    }
                }
                
                DispatchQueue.main.async(execute: { [weak self] () -> Void in
                    self?.paintVehciles(ids)
                })
            }
        })
    }
    
    
    /// 绘制所有车辆
    private func paintVehciles(_ vehicleKeys: Set<String>) {
        
        if let currnetAnnotations = mapView.annotations {
            mapView.removeAnnotations(currnetAnnotations)
        }
        
        guard vehicleKeys.count > 0 else {
            return
        }
        
        let coorAry = vehicleKeys.sorted { $0 > $1 }
        
        var AnnotationsToPaint = [VehicleGpsAnnotation]()
        
        for aCoorId in coorAry {
            
            guard let aData = vehiclesDic[aCoorId] else {
                continue
            }
            
            guard let ann = VehicleGpsAnnotation(data: aData) else {
                continue
            }
            
            AnnotationsToPaint.append(ann)
          
        }
        
        mapView.addAnnotations(AnnotationsToPaint)
    }
    
    /// 计算地图显示范围
    private func computeMapRegion(_ data: [CLLocationCoordinate2D]) {
        
        // 显示范围计算
        var minLat: CLLocationDegrees? = nil
        var maxLat: CLLocationDegrees? = nil
        var minLng: CLLocationDegrees? = nil
        var maxLng: CLLocationDegrees? = nil
    
        
        for coor in data {
 
            minLat = minLat != nil ? min(minLat!, coor.latitude) : coor.latitude
            maxLat = maxLat != nil ? max(maxLat!, coor.latitude) : coor.latitude
            minLng = minLng != nil ? min(minLng!, coor.longitude) : coor.longitude
            maxLng = maxLng != nil ? max(maxLng!, coor.longitude) : coor.longitude
        }
   
        // 显示区域
        if let minLatValue = minLat, let maxLatValue = maxLat, let minLngValue = minLng, let maxLngValue = maxLng {
            
            let center = CLLocationCoordinate2D(latitude: (minLatValue + maxLatValue) * 0.5, longitude: (minLngValue + maxLngValue) * 0.5)
            let span = BMKCoordinateSpan(latitudeDelta: (maxLatValue - minLatValue) * 1.2, longitudeDelta: (maxLngValue - minLngValue) * 1.4)
            mapView.region = BMKCoordinateRegion(center: center, span: span)
        }
        
    }
    
    /// 切换显示车辆菜单
    private func updateMenuPosition(_ isShow: Bool) {
        
        let currentShow = menuBottomSpeace.constant == 0
        
        guard isShow != currentShow else {
            return
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.menuBottomSpeace.constant = isShow ? 0 : -290
            self?.view.layoutIfNeeded()
        }
        
    }
}

// MARK: - BMKMapViewDelegate
extension VehicleGpsMapVC: BMKMapViewDelegate {
    
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        
        if let ann = annotation as? VehicleGpsAnnotation { /// 点的自定义
            
            let reuseIndetifier = "annotationReuseIndetifier"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIndetifier) as? MapCarAnnotationView
            
            if annotationView == nil {
                annotationView = MapCarAnnotationView(annotation: ann, reuseIdentifier: reuseIndetifier)
            }
            
            annotationView?.isEnabled = true
            annotationView?.canShowCallout = false
            
            annotationView?.infoDic["data"] = ann.data
            annotationView?.carLicence = ann.data.carLicense
            
            annotationView?.bgImage = Constants.Image.carGpsBgImage(from: ann.data.status)
            
            return annotationView
        }
        return nil
        
    }
    
    func mapView(_ mapView: BMKMapView!, didSelect view: BMKAnnotationView!) {
        if let vm = viewModel as? VehicleGpsMapVM {
            let data = (view as? MapCarAnnotationView)?.infoDic["data"] as? ReqQueryAllVehiclesGps.Data
            vm.clickVehcile.onNext(data)
        }
    }
    
    func mapView(_ mapView: BMKMapView!, didDeselect view: BMKAnnotationView!) {
        if let vm = viewModel as? VehicleGpsMapVM {
            let data = (view as? MapCarAnnotationView)?.infoDic["data"] as? ReqQueryAllVehiclesGps.Data
            vm.clickVehcile.onNext(data)
        }
    }
    
    func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
//        mLog("【百度地图】：regionDidChangeAnimated")
        self.filterVehciles(zoomLevel: mapView.zoomLevel, visibleMapRect: mapView.visibleMapRect)
    }

    
}

// MARK: - VehicleGpsAnnotation

/// 车辆gps百度点封装
class VehicleGpsAnnotation: BMKPointAnnotation {
    
    /// 保存车辆数据
    var data: ReqQueryAllVehiclesGps.Data
    
    init?(data: ReqQueryAllVehiclesGps.Data) {
        
        guard let coor = data.getCoordinate() else {
            return nil
        }
        
        self.data = data
        
        super.init()
        
        title = data.carLicense
        coordinate = coor
        
    }
}

extension CLLocationCoordinate2D {
    
    func getKey() -> String {
        return String(format: "%05f,%05f", latitude, longitude)
    }
    
}
