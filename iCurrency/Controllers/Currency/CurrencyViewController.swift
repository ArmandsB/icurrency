//
//  CurrencyViewController.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 27/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift

class CurrencyViewController: UIViewController {
    
    let currencyView = CurrencyView()
    let viewModel: CurrencyViewModelType = CurrencyViewModel(service: CurrencyService(service: ApiClient.shared),
                                                             baseCurrency: "EUR")
    
    private var reloadTimer: Timer?
    let disposeBag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = currencyView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "iCurrency"
        currencyView.tableView.tableFooterView = UIView()
        currencyView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.setupTimer()
        self.bindViewModels()
        self.viewModel.inputs.fetchDataAction.execute()
    }
    
    private func bindViewModels() {
        let outputs = viewModel.outputs
        self.bindTableView(outputs: outputs)
        
        outputs.onShowSpinner
            .drive(onNext: { [weak self] showSpinner in
                guard let self = self else { return }
                if showSpinner {
                    self.currencyView.showSpinner()
                } else {
                    self.currencyView.dismissSpinner()
                }
            })
            .disposed(by: disposeBag)
        
        outputs.onShowError
            .drive(onNext: { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.currencyView.showError(error: error)
                } else {
                    self.currencyView.dismissError()
                }
            })
            .disposed(by: disposeBag)
    }
    
    
}

private extension CurrencyViewController {
    
    func bindTableView(outputs: CurrencyViewModelOutputs) {
        let dataSource = RxTableViewSectionedAnimatedDataSource<CurrencyViewModel.TableViewSection>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
                cell.textLabel?.text = item.name
                cell.detailTextLabel?.text = "\(item.rate)"
                return cell
        })
        
        outputs.currencies.asObservable()
            .flatMap { currencies -> Observable<[CurrencyViewModel.TableViewSection]> in
                return Observable.just([CurrencyViewModel.TableViewSection(model: "Section", items: currencies)])
            }
            .bind(to: currencyView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }
}

private extension CurrencyViewController {
    
    func setupTimer() {
        self.reloadTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.inputs.fetchDataAction.execute()
        })
    }
}
