//
//  BridgeSelectionTableViewCell.swift
//  FaceAnalysis
//
//  Created by Darko Damjanovic on 30.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import UIKit

class BridgeSelectionTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(viewModel: BridgeSelectionTableViewCellViewModelProtocol?) {
        guard let viewModel = viewModel else { return }
        
        self.textLabel?.text = viewModel.text
        self.detailTextLabel?.text = viewModel.detailText

        let switchView = UISwitch(frame: .zero)
        switchView.tag = viewModel.switchTag
        switchView.addTarget(viewModel.selectorTarget, action: viewModel.selector, for: UIControl.Event.valueChanged)
        switchView.isOn = viewModel.switchViewIsOn
        self.accessoryView = switchView
    }
}
