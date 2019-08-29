//
//  MonitorDetailVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/20.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa
import AVKit
import MBProgressHUD

/// 实时监控-监控详情
class MonitorDetailVC: BaseVC {
    
    // MARK: - Property
    
    // ui
    /// 百度地图
    @IBOutlet private weak var mapView: BMKMapView!
    /// 搜索按钮
    @IBOutlet private weak var searchContainerView: UIView!
    /// 搜索按钮
    @IBOutlet private weak var searchBtn: UIButton!
    
    /// 视频菜单view
    @IBOutlet private weak var videoMenuView: UIView!
    /// 视频容器view
    @IBOutlet private weak var videoContainerView: UIView!
    /// 视频遮盖view
    @IBOutlet private weak var videoCoverView: UIView!
    /// 播放按钮
    @IBOutlet private weak var playBtn: UIButton!
    /// 通道按钮
    @IBOutlet private weak var channelBtn: UIButton!
    /// 子码流按钮
    @IBOutlet private weak var codeStreamBtn: UIButton!
    /// 子码流按钮
    @IBOutlet private weak var countDownLbl: UILabel!
    /// 视频播放器
    private var moviePlayer: AVPlayerViewController!
    
    /// 车辆点
    fileprivate var carAnnotation: BMKPointAnnotation?
    // private
    /// 计时器
    private var playFailTimer: Timer?
    /// 监听播放状态的回收器
    private var playStautsDisposeBag = DisposeBag()

    
    // MARK: - Override
    override func viewSetup() {
        super.viewSetup()
        
        // 视频
        moviePlayer = AVPlayerViewController(nibName: nil, bundle: nil)
        videoContainerView.addSubview(moviePlayer.view)
        
        moviePlayer.view.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
        }
        moviePlayer.videoGravity = AVLayerVideoGravity.resizeAspect
        moviePlayer.showsPlaybackControls = false
        moviePlayer.player = AVPlayer(playerItem: nil)
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? MonitorDetailVM {

            vm.isEnableSearchCar.asDriver()
                .map { !$0 }
                .drive(searchContainerView.rx.isHidden)
                .disposed(by: disposeBag)
            
            /// 绘制点
            vm.currentCarInfo.gpses.asDriver()
                .drive(onNext: { [weak self] (point) in
                    self?.paintPoint(point)
                })
                .disposed(by: disposeBag)
 

            /// 车辆无通道或无vehicleId,不显示播放按钮
            Driver<Bool>.combineLatest(vm.currentCarInfo.vehicleId.asDriver(), vm.currentCarInfo.allChannels.asDriver()) { (vehicleId, channels) -> Bool in
                    return vehicleId == nil || channels.count == 0
                }
                .drive(videoMenuView.rx.isHidden)
                .disposed(by: disposeBag)
           
            
            /// 播放状态
            vm.play.asDriver()
                .map { !($0?.count > 0) }
                .drive(videoContainerView.rx.isHidden)
                .disposed(by: disposeBag)
            
            vm.play.asDriver()
                .map { $0?.count > 0 }
                .drive(videoCoverView.rx.isHidden)
                .disposed(by: disposeBag)
            
            /// 播放视频
            vm.play.asDriver()
                .distinctUntilChanged()
                .drive(onNext: { [weak self] (url) in
                    self?.restartPlay(urlStr: url ?? "")
                })
                .disposed(by: disposeBag)
            
            /// 通道和码流
            vm.currentCarInfo.channelId.asDriver()
                .replaceEmpty("--")
                .map { "通道" + $0 }
                .drive(channelBtn.rx.title())
                .disposed(by: disposeBag)
            
            vm.currentCarInfo.streamType.asDriver()
                .map { $0.typeName() }
                .drive(codeStreamBtn.rx.title())
                .disposed(by: disposeBag)
            
            /// 倒计时
            vm.countDown.asDriver()
                .map { $0 == nil ? "" : String(format: "00:%02d", $0!) }
                .drive(countDownLbl.rx.text)
                .disposed(by: disposeBag)
            
            /// 点击播放按钮
            playBtn.rx.tap.asObservable()
                .bind(to: vm.didClickPlayBtn)
                .disposed(by: disposeBag)
            
            /// 点击搜车辆
            searchBtn.rx.tap.asObservable()
                .bind(to: vm.didClickSearchCar)
                .disposed(by: disposeBag)
            
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.viewWillAppear()
        mapView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        mapView.viewWillDisappear()
        mapView.delegate = nil
        invaliTimer()
        super.viewWillDisappear(animated)
    }
    
    deinit {
        moviePlayer.player?.pause()
        moviePlayer.player = nil
    }
    
    // MARK: - Private
    
    /// 绘制起点
    private func paintPoint(_ point: CLLocationCoordinate2D?){
        
        if let lastAnnotation = carAnnotation {
            mapView.removeAnnotation(lastAnnotation)
        }
        
        guard let pointValue = point else {
            return
        }
        
        mapView.centerCoordinate = pointValue
        
        carAnnotation = BMKPointAnnotation()
        carAnnotation?.coordinate = pointValue
        mapView.addAnnotation(carAnnotation)
        
    }
    
    /// 重置播放
    private func restartPlay(urlStr: String?) {

        mLog("【播放】：restartPlay：\(urlStr ?? "")")
        
        moviePlayer.player?.pause()
        
        invaliTimer()
        
        guard let url = URL(string: urlStr ?? "") else {
            moviePlayer.player?.replaceCurrentItem(with: nil)
            return
        }
    
        moviePlayer.player?.replaceCurrentItem(with: AVPlayerItem(url: url))
        moviePlayer.player?.play()
        
        playStautsDisposeBag = DisposeBag()
        moviePlayer.player?.currentItem?.rx.observe(AVPlayerItem.Status.self, "status")
            .subscribe(onNext: { [weak self] (status) in
                mLog("【播放】：播放状态监听：\(String(describing: status?.rawValue))")
                if status == .failed ,let aSelf = self{
                    /// 播放失败
                    UserDefaultsManager.shared.liveFailTime = Date()
                    
                    self?.playFailTimer = Timer.scheduledTimer(timeInterval: Constants.Config.playRetrytInterval, target: aSelf, selector: #selector(self?.timeFireReatart), userInfo: nil, repeats: false)
                    
                } else {
                    self?.invaliTimer()
                }
            })
            .disposed(by: playStautsDisposeBag)
        
    }
    
    /// 计时器触发
    @objc private func timeFireReatart() {
        
        mLog("【计时器】计时器启动")
        
        guard let playStartTime = UserDefaultsManager.shared.liveStartTime else {
            return
        }
        let playDuring = Date().timeIntervalSince(playStartTime)
        let secondRemain = Constants.Config.playTime - playDuring
        /// 间隔
        let failRemin = Date().timeIntervalSince(UserDefaultsManager.shared.liveFailTime ?? Date())
        if secondRemain > 0  && failRemin > 1 {
            restartPlay(urlStr: (viewModel as? MonitorDetailVM)?.play.value ?? "")
        }
        if secondRemain <= 0 {
            invaliTimer()
        }
    }
    
    /// 销毁定时器
    private func invaliTimer() {
        mLog("【计时器】：清空计时器")
        playFailTimer?.invalidate()
        playFailTimer = nil
    }

    
    /// 选择通道
    @IBAction private func showSelectChannel() {
        
        guard let vm = viewModel as? MonitorDetailVM else {
            return
        }
        
        guard vm.currentCarInfo.allChannels.value.count > 0 else {
            return
        }
        
        let sheet = UIAlertController(title: "选择通道", message: nil, preferredStyle: .actionSheet)
     
        for (idx, aChannel) in vm.currentCarInfo.allChannels.value.enumerated() {
            let action = UIAlertAction(title: "通道\(aChannel)", style: .default) { [weak vm] (_) in
                vm?.didChangeChannel.onNext(idx)
            }
            sheet.addAction(action)
        }
        
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(sheet, animated: true, completion: nil)
    }
    
    /// 选择码流
    @IBAction private func showSelectStreamType() {

        guard let vm = viewModel as? MonitorDetailVM else {
            return
        }
        
        let sheet = UIAlertController(title: "选择码流", message: nil, preferredStyle: .actionSheet)
        
        for (idx, aType) in LiveStreamType.allTypes.enumerated() {
            let action = UIAlertAction(title: aType.typeName(), style: .default) { [weak vm] (_) in
                vm?.didChangeType.onNext(idx)
            }
            sheet.addAction(action)
        }
        
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(sheet, animated: true, completion: nil)
        
    }
    
    
}


// MARK: - BMKMapViewDelegate
extension MonitorDetailVC: BMKMapViewDelegate {
    
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        
        if (annotation as! BMKPointAnnotation) == carAnnotation { ///车
            
            let reuseIndetifier = "annotationReuseIndetifier"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIndetifier) as? MapCarAnnotationView
            
            let stauts = (viewModel as? MonitorDetailVM)?.currentCarInfo.carStatus.value
            
            annotationView = MapCarAnnotationView(annotation: annotation, reuseIdentifier: reuseIndetifier, isShowCarPoint: true)
                annotationView?.bgImage = Constants.Image.carGpsBgImage(from: stauts)
            
                if let vm = viewModel as? MonitorDetailVM {
                    annotationView?.carLicence = vm.currentCarInfo.carLicense.value
                }
           

            return annotationView
        }
        
        return nil
        
    }
    
    
}

