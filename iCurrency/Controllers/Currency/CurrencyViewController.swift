//
//  CurrencyViewController.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 27/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import UIKit
import RxDataSources
import RxKeyboard
import RxSwift

class CurrencyViewController: UIViewController {

  let currencyView = CurrencyView()
  let viewModel: CurrencyViewModelType
  let disposeBag = DisposeBag()

  init(service: CurrencyServiceEndpoints = CurrencyService(service: ApiClient.shared), baseCurrency: String = "EUR") {
    viewModel = CurrencyViewModel(service: service, baseCurrency: baseCurrency)
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
    self.setupKeyboardListener()
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
      configureCell: { _, tableView, indexPath, item in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                       for: indexPath) as? CurrencyTableViewCell else { return UITableViewCell() }
        cell.cellViewModel = item
        cell.selectionStyle = .none
        cell.didChangeInput = { [weak cell] input in
          cell?.cellViewModel?.inputs.editInputValue(input: input)
        }
        return cell
    })

    outputs.currencies.asObservable()
      .flatMap { currencies -> Observable<[CurrencyViewModel.TableViewSection]> in
        return Observable.just([CurrencyViewModel.TableViewSection(model: "Section", items: currencies)])
      }
      .bind(to: currencyView.tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)

    let zipModelAndItemSelect = Observable.zip(currencyView.tableView.rx.modelSelected(CurrencyCellViewModelType.self),
                                               currencyView.tableView.rx.itemSelected)
    zipModelAndItemSelect
      .flatMap { [weak self] model, indexPath -> Observable<(CurrencyCellViewModelType, IndexPath, CurrencyCellViewModelType?)> in
        guard let self = self else { return .empty() }
        return Observable.zip(Observable.just(model),
                              Observable.just(indexPath),
                              self.viewModel.outputs.activeCurrency)
      }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] model, indexPath, activeCurrency  in
        guard let self = self else { return }
        if let activeCurrency = activeCurrency,
          activeCurrency.outputs.currency.value == model.outputs.currency.value {

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
    #if DEBUG
    guard Constants.Tests.isUnitTesting() == false else { return }
    #endif

    _ = Observable<Int>
      .interval(1.0, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.viewModel.inputs.fetchDataAction.execute()
      })
      .disposed(by: disposeBag)
  }
}

private extension CurrencyViewController {

  func setupKeyboardListener() {
    RxKeyboard.instance.visibleHeight
      .drive(onNext: { [weak self] keyboardVisibleHeight in
        guard let self = self else { return }
        self.currencyView.tableView.contentInset.bottom = keyboardVisibleHeight
        self.currencyView.tableView.scrollIndicatorInsets = self.currencyView.tableView.contentInset
      })
      .disposed(by: disposeBag)
  }

}
