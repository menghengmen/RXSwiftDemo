//
//  SettingsVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2019/1/8.
//  Copyright © 2019 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxCocoa
import RxSwift

/// 设置页
class SettingsVM: BaseTableVM {
    
    override init() {
        super.init()
        
        let section = BaseSectionVM()
        
        section.cellViewModels.append(BigTitleCellVM(title: "我的设置"))
        
        let voiceCell = SettingsSwitchCellVM()
        voiceCell.title.value = "智能语音"
        voiceCell.isOn.value = UserDefaultsManager.shared.isEnableOpenSmartVoice
        
        voiceCell.didChangeValue.asObservable()
            .subscribe(onNext: { [weak ud = UserDefaultsManager.shared] (value) in
                if value == true {
                    MobClick.event("setting_speech_on")
                    
                } else {
                    MobClick.event("setting_speech_off")

                }

                ud?.isEnableOpenSmartVoice = value
            })
            .disposed(by: disposeBag)
        
        section.cellViewModels.append(voiceCell)
        
        dataSource.value = [section]
        
    }
    
    
    
    
}
