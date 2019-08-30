//
//  StoreCommonImageCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2019/8/7.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

class StoreCommonImageCellVM: BaseCellVM{
    
   let didClickLeftBtn  = PublishSubject<Void>()
   let didClickRightBtn = PublishSubject<Void>()
    
    let images = Variable<[UIImage]?>([])// 图片数据

    override init() {
        super.init()

        Observable.of(didClickLeftBtn,didClickRightBtn)
           .merge()
           .bind(to: MessageCenter.shared.needShowImagePick)
           .disposed(by: disposeBag)
        
        MessageCenter.shared.didFinishPickImage.asObservable()
            .map { [weak self] (value) ->[UIImage]  in
                var tem = self?.images.value
                tem?.append((value ?? nil)!)
                return tem!
           }
          .bind(to: images)
          .disposed(by: disposeBag)

    }
}



class StoreCommonImageCell: BaseCell {

    @IBOutlet var leftBtn: UIButton!
    @IBOutlet var rightBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "StoreCommonImageCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! StoreCommonImageCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "StoreCommonImageCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 184+14+20
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        if  let vm = viewModel as? StoreCommonImageCellVM {
            
            vm.images.asDriver()
                .drive(onNext: { [weak self] (value) in
                    if let firstChooseImage = value?.first{
                        self?.leftBtn.setBackgroundImage(firstChooseImage, for: .normal)
                        
                    } else {
                       self?.leftBtn.setBackgroundImage(UIImage.init(named: "store_placeHolder_icon"), for: .normal)
                    }
                    
                    if let secondChooseImage = value?.yd.element(of: 1){
                       self?.rightBtn.setBackgroundImage(secondChooseImage, for: .normal)

                    } else {
                      self?.rightBtn.setBackgroundImage(UIImage.init(named: "store_placeHolder_icon"), for: .normal)

                    }
                
                
                })
               .disposed(by: disposeBag)
            
            
            
            leftBtn.rx.tap.asObservable()
               .bind(to: vm.didClickLeftBtn)
               .disposed(by: disposeBag)
           
            rightBtn.rx.tap.asObservable()
               .bind(to: vm.didClickRightBtn)
               .disposed(by: disposeBag)
        
        }
    
    
    
    }
}
