//
//  ReminderDetailImageCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/26.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift

/// 图片数据
struct ImageInfo {
    /// 图片
    var image: UIImage?
    /// 图片url
    var imageUrl: String?
    /// 图片id
    var idStr: String?
    
    init(_ image: UIImage? = nil, imageUrl: String? = nil) {
        self.image = image
        self.imageUrl = imageUrl
    }
}

/// 管车助手-详情-图片cell
class ReminderDetailImageCellVM: BaseCellVM {
    
     // to view
   
    // MVVM To Controller
    let showMessage = PublishSubject<AlertMessage>()
    /// 图片
    let image = Variable<UIImage?>(nil)
    // from view
    /// 点击图片
    let didClickImage = PublishSubject<UIImage?>()
    
    /// 所有图片
    let images = Variable<[ImageInfo]>([])
    
    let imageUrl = Variable<String?>("")
    
    override init() {
        super.init()
        MessageCenter.shared.didFinishPickImage.asObservable()
         .map { [weak self] (value) -> [ImageInfo] in
               self?.images.value.removeAll()
               self?.image.value = value
                var temp = self?.images.value ?? []
                    temp.append(ImageInfo(value))
               return temp
            }
           
            .bind(to: images)
            .disposed(by: disposeBag)
        }
    
    /// 上传图片
    public func uploadMenosImage() {
        guard images.value.count > 0   else {
            return
        }
        
        var imageUpload = [UIImage]()
        
        for anImageInfo in images.value {
            if let img = anImageInfo.image {
                imageUpload.append(img)
            }
        }
        
        let reqParam = ReqUploadImage(images: imageUpload)
        let req = reqParam.toUploadRequest()
        
        let success = req.responseRx.asObservable()
            .filter { $0.isSuccess() && $0.model?.dataList.count > 0 }
        
        let failed = req.responseRx.asObservable()
            .filter { $0.isSuccess() == false }
        
        success
            .map { _ in return AlertMessage(message: "图片上传成功", alertType: .toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        success
            .map { [weak self] (rsp) -> [ImageInfo] in
                self?.images.value.removeAll()
                var images = self?.images.value ?? []
                let urlFromServer = rsp.model?.dataList ?? []
                for (_, anIdStr) in urlFromServer.enumerated() {
                    images.append(ImageInfo(nil,imageUrl: anIdStr))

                }

                return images
            }
           .bind(to: images)
           .disposed(by: disposeBag)
        
        
        
        failed
            .map { _ in return AlertMessage(message: "图片上传失败", alertType: .toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        HttpRequestSender.shared.sendUploadRequest(req)
    }
}

/// 管车助手-详情-图片cell
class ReminderDetailImageCell: BaseCell {
    
    @IBOutlet var attachImage: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "ReminderDetailImageCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ReminderDetailImageCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "ReminderDetailImageCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 110
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? ReminderDetailImageCellVM {
            
            vm.image.asDriver()
                .drive(attachImage.rx.backgroundImage())
                .disposed(by: disposeBag)
            attachImage.rx.tap.asObservable()
                .map({ [weak self] (_) -> UIImage? in
                    return self?.attachImage.currentBackgroundImage
                })
                .bind(to: vm.didClickImage)
                .disposed(by: disposeBag)
          
            vm.imageUrl.asDriver()
                .drive(onNext: { [weak self] (urlStr) in
                    if let url = URL(string: urlStr ?? "") {
                        self?.reloadImage(url)
                    } else {
                        
                    }
                })
                .disposed(by: disposeBag)
        
        }
        
    }
    /// 加载图片
    private func reloadImage(_ url: URL?) {
        guard let urlValue = url else {
            return
        }
       
        attachImage?.af_setBackgroundImage(for: .normal, url: urlValue, placeholderImage: UIImage(named: "holder_imageloading"),completion: {  (rsp) in
            
        })
    }

}

