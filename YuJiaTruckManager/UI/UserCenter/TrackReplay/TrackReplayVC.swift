//
//  TrackReplayVC.swift
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
class TrackReplayVC: BaseVC {
    
    // MARK: - Property
    
    // 顶部信息
    @IBOutlet private weak var driverLbl: UILabel!
    @IBOutlet private weak var carLicenceLbl: UILabel!
    @IBOutlet private weak var currentDistenceLbl: UILabel!
    @IBOutlet private weak var totalDistenceLbl: UILabel!
    @IBOutlet private weak var currentTimeLbl: UILabel!
    @IBOutlet private weak var endTimeLbl: UILabel!
    @IBOutlet private weak var speedLbl: UILabel!
    @IBOutlet private weak var addressLbl: UILabel!
    
    // 底部信息
    @IBOutlet private weak var playProgessSlider: UISlider!
    @IBOutlet private weak var playStartTimeLbl: UILabel!
    @IBOutlet private weak var playEndTimeLbl: UILabel!
    @IBOutlet private weak var playBtn: UIButton!
    @IBOutlet private weak var playNormalSpeedBtn: UIButton!
    @IBOutlet private weak var playFastSpeedBtn: UIButton!
    
    /// 百度地图
    @IBOutlet private weak var mapView: BMKMapView!
    /// 总路径
    private var totalTrack: BMKPolyline?
    /// 起点
    private var trackStartPoint: BMKPointAnnotation?
    /// 终点
    private var trackEndPoint: BMKPointAnnotation?
    /// 报警路径
    private var alarmTrack: BMKPolyline?
    /// 报警点
    private var alarmPoint: BMKPointAnnotation?
    /// 当前车辆位置
    private var carPoint: BMKPointAnnotation?
    
    
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
        
        if let vm = viewModel as? TrackReplayVM {
            
            // 顶部：
            
            vm.driverName.asDriver()
                .replaceEmpty("--")
                .drive(driverLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.carLicence.asDriver()
                .replaceEmpty("--")
                .drive(carLicenceLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.currentDistence.asDriver()
                .map { $0 != nil ? "\($0!)公里" : "--公里" }
                .drive(currentDistenceLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.totalDistence.asDriver()
                .map { $0 != nil ? "/ \($0!)公里" : "/ --公里" }
                .drive(totalDistenceLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.currentTime.asDriver()
                .map { $0?.yd.timeString(with: "HH:mm") }
                .replaceEmpty("--")
                .drive(currentTimeLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.endTime.asDriver()
                .map { $0?.yd.timeString(with: "/ HH:mm") }
                .replaceEmpty("/ --")
                .drive(endTimeLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.speed.asDriver()
                .map { $0 != nil ? "\($0!)KM/H" : "--KM/H" }
                .drive(speedLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.address.asDriver()
                .replaceEmpty("--")
                .drive(addressLbl.rx.text)
                .disposed(by: disposeBag)
            
            // 底部：
            
            vm.progress.asDriver()
                .drive(playProgessSlider.rx.value)
                .disposed(by: disposeBag)
            
            vm.startTime.asDriver()
                .map { $0?.yd.timeString(with: "HH:mm") }
                .replaceEmpty("--:--")
                .drive(playStartTimeLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.endTime.asDriver()
                .map { $0?.yd.timeString(with: "HH:mm") }
                .replaceEmpty("--:--")
                .drive(playEndTimeLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.isFastPlay.asDriver()
                .map { !$0 }
                .drive(playNormalSpeedBtn.rx.isSelected)
                .disposed(by: disposeBag)
            
            vm.isFastPlay.asDriver()
                .drive(playFastSpeedBtn.rx.isSelected)
                .disposed(by: disposeBag)
            
            vm.isPlaying.asDriver()
                .drive(playBtn.rx.isSelected)
                .disposed(by: disposeBag)
            
            vm.isPlaying.asDriver()
                .map { !$0 }
                .drive(playProgessSlider.rx.isUserInteractionEnabled)
                .disposed(by: disposeBag)
            
            // 事件:
            
            playBtn.rx.tap.asObservable()
                .bind(to: vm.clickPlay)
                .disposed(by: disposeBag)
            
            playProgessSlider.rx.value.asObservable()
                .bind(to: vm.changeProgress)
                .disposed(by: disposeBag)
            
            playNormalSpeedBtn.rx.tap.asObservable()
                .bind(to: vm.clickNormalSpeed)
                .disposed(by: disposeBag)
            
            playFastSpeedBtn.rx.tap.asObservable()
                .bind(to: vm.clickFastSpeed)
                .disposed(by: disposeBag)
            
            // 绘制轨迹：
            
            Observable.combineLatest(vm.allTracks.asObservable(), vm.alarmGps.asObservable()) { (tracks, alarmGps) -> ([CLLocationCoordinate2D], [CLLocationCoordinate2D]) in
                return (tracks.map { $0.point }, alarmGps)
                }
                .asDriver(onErrorJustReturn: ([], []))
                .drive(onNext: { [weak self] (value) in
                    self?.paintTracks(value.0, alarmPoints: value.1)
                })
                .disposed(by: disposeBag)
            
            // 绘制车辆
            vm.carLocation.asDriver()
                .drive(onNext: { [weak self] (value) in
                    self?.paintCurrentTrack(value.0)
                })
                .disposed(by: disposeBag)
            
        }
        
    }
    
    // MARK: - Private
    
    /// 绘制总路径
    private func paintTracks(_ trackPoints: [CLLocationCoordinate2D], alarmPoints: [CLLocationCoordinate2D]) {
        
        if let paintedLine = totalTrack {
            mapView.remove(paintedLine)
            totalTrack = nil
        }
        
        if let paintedPoint = trackStartPoint {
            mapView.removeAnnotation(paintedPoint)
            trackStartPoint = nil
        }
        
        if let paintedPoint = trackEndPoint {
            mapView.removeAnnotation(paintedPoint)
            trackEndPoint = nil
        }
        
        if let paintedLine = alarmTrack {
            mapView.remove(paintedLine)
            alarmTrack = nil
        }
        
        if let paintedPoint = alarmPoint {
            mapView.removeAnnotation(paintedPoint)
            alarmPoint = nil
        }
        
        if trackPoints.count > 1 {
            
            guard let start = trackPoints.first, let end = trackPoints.last else {
                return
            }
            
            // 显示范围计算
            var minLat: CLLocationDegrees? = nil
            var maxLat: CLLocationDegrees? = nil
            var minLng: CLLocationDegrees? = nil
            var maxLng: CLLocationDegrees? = nil
            
            // 总轨迹
            let linePointsBuf = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: trackPoints.count)
            for (idx,coor) in trackPoints.enumerated() {
                linePointsBuf[idx] = coor
                minLat = minLat != nil ? min(minLat!, coor.latitude) : coor.latitude
                maxLat = maxLat != nil ? max(maxLat!, coor.latitude) : coor.latitude
                minLng = minLng != nil ? min(minLng!, coor.longitude) : coor.longitude
                maxLng = maxLng != nil ? max(maxLng!, coor.longitude) : coor.longitude
            }
            
            let polyline = BMKPolyline(coordinates: linePointsBuf, count: UInt(trackPoints.count))
            totalTrack = polyline
            mapView.add(polyline)
            linePointsBuf.deallocate()
            
            // 起点
            let startAn = BMKPointAnnotation()
            startAn.coordinate = start
            trackStartPoint = startAn
            mapView.addAnnotation(startAn)
            
            
            // 终点
            let endAn = BMKPointAnnotation()
            endAn.coordinate = end
            trackEndPoint = endAn
            mapView.addAnnotation(endAn)
            
            // 显示区域
            if let minLatValue = minLat, let maxLatValue = maxLat, let minLngValue = minLng, let maxLngValue = maxLng {
                
                let center = CLLocationCoordinate2D(latitude: (minLatValue + maxLatValue) * 0.5, longitude: (minLngValue + maxLngValue) * 0.5)
                let span = BMKCoordinateSpan(latitudeDelta: (maxLatValue - minLatValue) * 1.2, longitudeDelta: (maxLngValue - minLngValue) * 1.4)
                mapView.region = BMKCoordinateRegion(center: center, span: span)
            }
        }
        
        
        if alarmPoints.count == 1, let alarmPointValue = alarmPoints.first {
            // 报警点
            let alarmAn = BMKPointAnnotation()
            alarmAn.coordinate = alarmPointValue
            alarmPoint = alarmAn
            mapView.addAnnotation(alarmAn)
            
        } else if alarmPoints.count > 0 {
            // 报警轨迹
            let linePointsBuf = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: alarmPoints.count)
            for (idx,aPoint) in alarmPoints.enumerated() {
                linePointsBuf[idx] = aPoint
            }
            
            let polyline = BMKPolyline(coordinates: linePointsBuf, count: UInt(alarmPoints.count))
            alarmTrack = polyline
            mapView.add(polyline)
            linePointsBuf.deallocate()
        }
        
    }
    
    /// 绘制当前车辆位置
    private func paintCurrentTrack(_ point: CLLocationCoordinate2D?) {
        
        if let paintedCar = carPoint {
            mapView.removeAnnotation(paintedCar)
            carPoint = nil
        }
        
        guard let pointValue = point else {
            return
        }
        
        let carAn = BMKPointAnnotation()
        carAn.coordinate = pointValue
        carPoint = carAn
        mapView.addAnnotation(carAn)
        
    }
    
    
}

// MARK: - BMKMapViewDelegate
extension TrackReplayVC: BMKMapViewDelegate {
    
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        
        if annotation is BMKPointAnnotation { /// 点的自定义
            
            if annotation === carPoint {
                let reuseIndetifier = "carPoint"
                
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIndetifier)
                
                if annotationView == nil {
                    annotationView = PlaybackCarAnnotationView(annotation: annotation, reuseIdentifier: reuseIndetifier)
                }
                
                (annotationView as? PlaybackCarAnnotationView)?.direction = (self.viewModel as? TrackReplayVM)?.carLocation.value.1
                
                return annotationView
            } else if annotation === trackStartPoint {
                let reuseIndetifier = "trackStartPoint"
                
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIndetifier)
                
                if annotationView == nil {
                    annotationView = BMKAnnotationView(annotation: annotation, reuseIdentifier: reuseIndetifier)
                    annotationView?.image = UIImage(named: "icon_start")
                    
                }
                
                return annotationView
            } else if annotation === trackEndPoint {
                let reuseIndetifier = "trackEndPoint"
                
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIndetifier)
                
                if annotationView == nil {
                    annotationView = BMKAnnotationView(annotation: annotation, reuseIdentifier: reuseIndetifier)
                    annotationView?.image = UIImage(named: "icon_end")
                }
                
                return annotationView
            }
            
            
        }
        return nil
        
    }
    
    func mapView(_ mapView: BMKMapView!, viewFor overlay: BMKOverlay!) -> BMKOverlayView! {
        
        if overlay is BMKPolyline {
            
            let polylineView = BMKPolylineView(overlay: overlay)
            
            polylineView?.lineWidth = 4
            
            if overlay === totalTrack {
                polylineView?.strokeColor = Constants.Color.blue
            }
            return polylineView
        }
        
        return nil
    }
    
}


/// 回放车辆标记view
class PlaybackCarAnnotationView: BMKAnnotationView {
    
    /// 方向
    var direction: Int? {
        didSet {
            bgImageView.transform = CGAffineTransform(rotationAngle: CGFloat((direction ?? 225) - 225) * CGFloat.pi / 180.0)
        }
    }
    
    // ui
    private var bgImageView = UIImageView()
    
    override init!(annotation: BMKAnnotation!, reuseIdentifier: String!) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        bounds = CGRect(x: 0, y: 0, width: 44, height: 44)
        bgImageView.image = UIImage(named: "icon_routecar")
        addSubview(bgImageView)
        
        bgImageView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
    }
    
}

