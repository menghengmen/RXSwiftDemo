//
//  RankListSection.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/12/26.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import UIKit
import YuDaoComponents
import RxCocoa
import RxSwift
import SnapKit

/// 排行榜-列表section
class RankListSection: BaseSectionVM {
    
    /// 名字的标题
    let nameTitle = Variable<String?>(nil)
    
}



/// 排行榜-列表section header
class RankListSectionHeaderView: BaseSectionHeadView {
    
    /// 名字/车辆标题
    var nameTitleLbl = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        backgroundColor = .white
        
        // 添加标题
        
        contentView.addSubview(nameTitleLbl)
        nameTitleLbl.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(100)
            maker.centerY.equalToSuperview()
        }
        
        nameTitleLbl.textColor = Constants.Color.lightText
        nameTitleLbl.font = mFont(16)
        nameTitleLbl.text = "司机姓名"
        
        let numberTitleLbl = UILabel()
        contentView.addSubview(numberTitleLbl)
        numberTitleLbl.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview().offset(-40)
            maker.centerY.equalToSuperview()
        }
        numberTitleLbl.textColor = Constants.Color.lightText
        numberTitleLbl.font = mFont(16)
        numberTitleLbl.text = "百公里报警数"
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func createInstance(with viewModel: SectionViewModelProtocol) -> UITableViewHeaderFooterView? {
        return RankListSectionHeaderView(reuseIdentifier: RankListSectionHeaderView.reuseID(with: viewModel))
    }
    
    override class func reuseID(with viewModel: SectionViewModelProtocol) -> String {
        return "RankListSectionHeaderView"
    }
    
    /// 计算高度
    override class func height(with viewModel: SectionViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 48
    }
    
    override func updateView(with viewModel: SectionViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? RankListSection {
            vm.nameTitle.asDriver()
                .drive(nameTitleLbl.rx.text)
                .disposed(by: disposeBag)
        }
        
    }
    
    
}
