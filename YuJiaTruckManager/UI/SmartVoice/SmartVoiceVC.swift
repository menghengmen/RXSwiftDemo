//
//  SmartVoiceVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/12/24.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 智能语音页
class SmartVoiceVC: BaseVC {
   
    /// 音量变化视图
    private var loadingView = UIImageView()
    private var volumnChangeView = UIView()
    
    /// 语音结果
    private var voiceResult = String()
    @IBOutlet var smartBtn: UIButton!
    override func viewSetup() {
        super.viewSetup()
        /// 添加长按手势
         let longPress = UILongPressGestureRecognizer(target:self, action:#selector(longPressGesture(_:)))
         smartBtn.addGestureRecognizer(longPress)
       
    }
    
    /// 手势处理
    @objc func longPressGesture(_ longPressGesture:UILongPressGestureRecognizer){
        if longPressGesture.state == .began{
            MobClick.event("speech_recognize")
            createVolumnChangeView()
            smartVoiceRecon()
            FZSpeechRecognizer.xf_AudioRecognizerVolumeChanged { [weak self] (volumn) in
                     self?.volumnChange(volumn: Int(volumn))
                }
        } else if longPressGesture.state == .ended{
            if let vm = viewModel as? SmartVoiceVM {
                vm.smartVoiceResult.onNext(voiceResult )
                voiceResult = ""
                
            }
            volumnChangeView.removeFromSuperview()
        }
        
        
    }
   
    /// 语音识别
    private func smartVoiceRecon() {
        FZSpeechRecognizer.xf_AudioRecognizerResult { [weak self] (resultStr, error) in
            if (resultStr == "。") {
                return ;
            }
            self?.voiceResult.append(resultStr ?? "")
        }
        
    }
    
   
    private func createVolumnChangeView(){
        volumnChangeView.backgroundColor = .black
        volumnChangeView.alpha = 0.5
        view.addSubview(volumnChangeView)
        volumnChangeView.snp.makeConstraints { (maker) in
            maker.width.equalTo(120)
            maker.height.equalTo(120)
            maker.center.equalToSuperview()
        }
        
        /// 图片
        volumnChangeView.addSubview(loadingView)
        loadingView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(10)
            maker.width.equalTo(88)
            maker.height.equalTo(100)
            maker.center.equalToSuperview()
        }
        
    }
    
    /// 音量变化
    private func volumnChange(volumn: Int){
        if volumn > 0 && volumn < 7 {
            loadingView.image = UIImage.init(named: "icon_volumn1")
        } else if volumn > 6  && volumn < 13 {
            loadingView.image = UIImage.init(named: "icon_volumn2")

        }  else if volumn > 12  && volumn < 19 {
            loadingView.image = UIImage.init(named: "icon_volumn3")
            
        }  else if volumn > 18  && volumn < 25 {
            loadingView.image = UIImage.init(named: "icon_volumn4")
            
        } else if volumn > 24  && volumn < 30{
            loadingView.image = UIImage.init(named: "icon_volumn5")

        } else {
            loadingView.image = UIImage.init(named: "icon_volumn1")

        }
   }

    
    @IBAction func commonClick(_ sender: UIButton) {
        if let vm = viewModel as? SmartVoiceVM {
         vm.didClickButton.onNext(sender.tag)
       }
    }
 
}

