//
//  AlarmImageListVC.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/5.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa
import SimpleImageViewer

/// 告警图片/视频列表页
class AlarmImageListVC: BaseTableVC {
    
    override func viewSetup() {
        super.viewSetup()
        navBarStyle = .translucentWithBlackTint
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillDisappear(animated)
    }
    
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? AlarmImageListVM {
            vm.clickImage.asDriver(onErrorJustReturn: nil)
                .drive(onNext: { [weak self] (img) in
                    self?.showImage(img)
                })
                .disposed(by: disposeBag)
        }
        
        
    }
    
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
        case is BigTitleCellVM:
            return BigTitleCell.self
        case is AlarmImageListCellVM:
            return AlarmImageListCell.self
        default:
            return nil
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscapeLeft, .landscapeRight]
    }
    
    
    private func showImage(_ image: UIImage?) {
        
        guard let img = image else {
            return
        }
        
        let configuration = ImageViewerConfiguration { config in
            config.image = img
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
        
    }
    
}
