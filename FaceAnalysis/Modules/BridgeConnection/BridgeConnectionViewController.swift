//
//  BridgeConnectionViewController.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation
import UIKit

/// The view controller controls the lifecycle of views and holds also all views.
/// In the MVVM pattern the view controller is the representation of the general "View".
class BridgeConnectionViewController: UIViewController {
    
    private let log = Logger()
    var viewModel: BridgeConnectionViewModelProtocol!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem! {
        didSet {
            let icon = UIImage(named: "ic_update")
            let iconSize = CGRect(origin: .zero, size: icon!.size)
            let iconButton = UIButton(frame: iconSize)
            iconButton.imageView?.contentMode = .scaleAspectFit
            iconButton.setBackgroundImage(icon, for: .normal)
            refreshButton.customView = iconButton
            iconButton.addTarget(self, action: #selector(BridgeConnectionViewController.refreshAction(_:)), for: .touchUpInside)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(viewModel != nil)
        self.setupBindings()
    }
    
    private func setupBindings() {
        self.viewModel.viewBinding.reload = { [weak self] in
            self?.tableView.reloadData()
        }
        
        self.viewModel.viewBinding.indicateLoading = { [weak self] enabled in
            if enabled {
                self?.refreshButton.customView?.rotateView()
            } else {
                self?.refreshButton.customView?.stopRotateView()
            }
        }
        
        self.viewModel.viewBinding.showAlertView = { [weak self] in
            self?.showAlertView()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.viewDidAppear()
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        self.viewModel.refresh()
    }
    
    @IBAction func closeBridgeSelection(_ sender: Any) {
        self.viewModel.close()
    }
    
    private func showAlertView(){
        let alertController = UIAlertController(title: "Bridge Error!", message: "Philips Hue Bridge cannot found. Please make sure the bridge is online.", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    deinit {
        log.info("")
    }
}

extension BridgeConnectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        self.viewModel.switchValueChanged(isOn: sender.isOn, index: sender.tag)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BridgeCell", for: indexPath) as! BridgeSelectionTableViewCell
        let cellViewModel = self.viewModel.cellViewModelFor(indexPath: indexPath)
        cell.configure(viewModel: cellViewModel)
        return cell
    }
}
