//
//  AlarmImageListCell.swift
//  YuJia
//
//  Created by mh on 2018/8/3.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift
import AlamofireImage
import AVKit
import MBProgressHUD

/// 图片/视频cell-viewmodel
class AlarmImageListCellVM: BaseCellVM {
    
    /// 类型，初始化时设置
    let type = Variable<ReqAlarmDetail.AttachType>(.image)
    /// 附件地址
    let fileUrl = Variable<String>("")
    
    /// 点击图片事件
    let clickImage = PublishSubject<UIImage?>()
    
    init(type: ReqAlarmDetail.AttachType) {
        self.type.value = type
        super.init()
    }
    
    deinit {
//        mLog("【Cell VM析构】\(self)")
    }
    
}

/// 图片/视频cell
class AlarmImageListCell: BaseCell {
    
    // ui
    @IBOutlet private weak var contentImageView: UIImageView!
    @IBOutlet private weak var tapImage: UITapGestureRecognizer!
    
    var playerView: UIView!
    var moviePlayer: AVPlayerViewController!
    
    /// 播放视频失败
    let cantPlayVideo = PublishSubject<Void>()
    
    /// 是否为加载错误的URL
    var loadErrUrl: URL? {
        didSet {
            if loadErrUrl != nil {
            contentImageView.image = UIImage(named: "holder_reload")
            }
        }
    }
    
    deinit {
//        mLog("【Cell 析构】\(self)")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 图片
        contentImageView.layer.masksToBounds = true
        contentImageView.layer.cornerRadius = 5

        // 视频
        moviePlayer = AVPlayerViewController(nibName: nil, bundle: nil)
        playerView = moviePlayer.view
        
        contentView.addSubview(moviePlayer.view)

        moviePlayer.view.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(7)
            maker.bottom.equalToSuperview().offset(-7)
            maker.left.equalToSuperview().offset(0)
            maker.right.equalToSuperview().offset(0)
        }
        moviePlayer.videoGravity = AVLayerVideoGravity.resizeAspect
        moviePlayer.showsPlaybackControls = true
        
        playerView.layer.masksToBounds = true
        playerView.layer.cornerRadius = 5
        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "AlarmImageListCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! AlarmImageListCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "AlarmImageListCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return (tableSize.width - 30) * (212 / 345) + 14
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? AlarmImageListCellVM {
            
            vm.type.asDriver()
                .map { !($0 == .image) }
                .asDriver(onErrorJustReturn: true)
                .drive(contentImageView.rx.isHidden)
                .disposed(by: disposeBag)
            
            vm.type.asDriver()
                .map { !($0 == .video) }
                .asDriver(onErrorJustReturn: false)
                .drive(playerView.rx.isHidden)
                .disposed(by: disposeBag)
            
            vm.fileUrl.asDriver()
                .filter { [weak vm] (_) -> Bool in
                    return vm?.type.value == .image
                }
                .drive(onNext: { [weak self] (urlStr) in
                    self?.loadErrUrl = nil
                    if let url = URL(string: urlStr) {
                        self?.reloadImage(url)
                    } else {
                        self?.contentImageView.image = UIImage(named: "holder_noImage")
                    }
                })
                .disposed(by: disposeBag)
            
            vm.fileUrl.asDriver()
                .filter { [weak vm] (_) -> Bool in
                    return vm?.type.value == .video
                }
                .distinctUntilChanged()
                .drive(onNext: { [weak self] (urlStr) in
                    
                    if let url = URL(string: urlStr) {
                        self?.reloadVideo(url)
                    } else {
                        
                    }
                })
                .disposed(by: disposeBag)
            
            tapImage.rx.event
                .filter { [weak self] (_) -> Bool in
                    self?.loadErrUrl != nil
                }
                .subscribe(onNext: { [weak self] (_) in
                    self?.reloadImage(self?.loadErrUrl)
                })
                .disposed(by: disposeBag)
            
            tapImage.rx.event
                .filter { [weak self] (_) -> Bool in
                    self?.loadErrUrl == nil
                }
                .map { [weak self] (_) -> UIImage? in
                    return self?.contentImageView.image
                }
                .bind(to: vm.clickImage)
                .disposed(by: disposeBag)
        }
        
    }
    
    /// 刷新图片
    private func reloadImage(_ url: URL?) {
        
        guard let urlValue = url else {
            return
        }
        
        contentImageView.af_setImage(withURL: urlValue, placeholderImage: UIImage(named: "holder_noImage"), completion: { [weak self] (rsp) in
            
            if let nsErr = rsp.error as NSError? {
                if Constants.StatusCode(rawValue: nsErr.code) == .noNetwork {
                    self?.loadErrUrl = url
                } else {
                    self?.loadErrUrl = nil
                }
            } else {
                self?.loadErrUrl = nil
            }
        })
    }
    
    /// 刷新视频
    private func reloadVideo(_ url: URL?) {
        
        guard let urlValue = url else {
            return
        }
        
        let avPlayer = AVPlayer(url: urlValue)
        moviePlayer.player = avPlayer
        
        avPlayer.rx.observe(AVPlayerItem.Status.self, "currentItem.status")
            .subscribe(onNext: { [weak self] (status) in
                if status == .failed, let sSelf = self {
                    
                    let hud = MBProgressHUD.showAdded(to: sSelf, animated: true)
                    hud.mode = .text
                    hud.bezelView.color = .black
                    hud.label.textColor = .white
                    hud.label.text = "该视频无法播放"
                    hud.removeFromSuperViewOnHide = true
                    hud.hide(animated: true, afterDelay: 2.0)
                }
            })
            .disposed(by: disposeBag)
        
    }

}
