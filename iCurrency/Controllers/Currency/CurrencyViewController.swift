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
    
    let disposeBag = DisposeBag()
    private var reloadTimer: Timer?
    private let keyboardHandler = KeyboardHandler()
    
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
        currencyView.tableView.register(CurrencyTableViewCell.self, forCellReuseIdentifier: "Cell")
        currencyView.tableView.rowHeight = 80
        currencyView.tableView.backgroundColor = UIColor.groupTableViewBackground
        currencyView.tableView.estimatedRowHeight = 80
        currencyView.tableView.separatorStyle = .none
        currencyView.tableView.keyboardDismissMode = .onDrag
        
        self.setupTimer()
        self.keyboardHandler.delegate = self
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
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CurrencyTableViewCell else { return UITableViewCell() }
                cell.cellViewModel = item
                cell.selectionStyle = .none
                cell.didChangeInput = { [weak cell] input in
                   cell?.cellViewModel?.inputs.setInputValue(input: input)
                }
                return cell
        })
        
        outputs.currencies.asObservable()
            .flatMap { currencies -> Observable<[CurrencyViewModel.TableViewSection]> in
                return Observable.just([CurrencyViewModel.TableViewSection(model: "Section", items: currencies)])
            }
            .bind(to: currencyView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        Observable
            .zip(currencyView.tableView.rx.modelSelected(CurrencyCellViewModel.self), currencyView.tableView.rx.itemSelected)
            .flatMap { [weak self] model, indexPath -> Observable<(CurrencyCellViewModel, IndexPath, CurrencyCellViewModel?)> in
                guard let self = self else { return .empty() }
                return Observable.zip(Observable.just(model),
                                      Observable.just(indexPath),
                                      self.viewModel.outputs.activeCurrency)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] model, indexPath, activeCurrency  in
                guard let self = self else { return }
                if let activeCurrency = activeCurrency, activeCurrency.currency.value == model.currency.value {
                    if let cell = self.currencyView.tableView.cellForRow(at: indexPath) as? CurrencyTableViewCell {
                        cell.startEdit()
                    }
                }
                self.viewModel.inputs.selectCurrency.execute(model)
                self.currencyView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            })
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

extension CurrencyViewController: KeyboardHandlerDelegate {
    
    func keyboardFrameDidChange(size: CGRect, animation: UIView.AnimationCurve, duration: TimeInterval, userInfo: JSON) {
        UIView.animate(withDuration: duration, delay: 0.0, options: animation.toOptions(), animations: {
            self.currencyView.tableView.contentInset.bottom = size.height
            self.currencyView.tableView.scrollIndicatorInsets = self.currencyView.tableView.contentInset
        }) { (finished) in
            
        }
    }
}
