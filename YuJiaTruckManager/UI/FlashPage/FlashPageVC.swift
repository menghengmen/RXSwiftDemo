//
//  FlashPageVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/22.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 闪屏/引导页
class FlashPageVC: BaseVC {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? FlashPageVM {
            
            vm.finishFlashPage
                .asDriver(onErrorJustReturn: ())
                .drive(onNext: { [weak self] (_) in
                    self?.view.removeFromSuperview()
                    self?.removeFromParent()
                    
                })
                .disposed(by: disposeBag)
            
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
}

