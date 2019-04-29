//
//  CurrencyTableViewCell.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 28/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class CurrencyTableViewCell: UITableViewCell {

  var disposeBag = DisposeBag()

  private let contentBackgroundView = UIView()
  private let titleLabel = UILabel()
  private let rightSideStackView = UIStackView(frame: .zero)
  private let valueTextField = UITextField()
  private let rateLabel = UILabel()

  var didChangeInput: ((Double) -> Void)?

  var cellViewModel: CurrencyCellViewModelType? {
    didSet {
      guard let cellViewModel = cellViewModel else { return }
      self.bindViewModel(viewModel: cellViewModel)
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.initLayout()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func  initLayout() {
    self.contentView.backgroundColor = UIColor.groupTableViewBackground
    self.contentView.addSubview(contentBackgroundView)
    contentBackgroundView.snp.makeConstraints { make in
      make.edges.equalTo(contentView.snp.margins)
    }

    contentBackgroundView.backgroundColor = .white
    contentBackgroundView.layer.cornerRadius = 8
    contentBackgroundView.layer.borderWidth = 1
    contentBackgroundView.layer.borderColor = UIColor.lightGray.cgColor

    contentBackgroundView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(contentBackgroundView.snp.leading).inset(8)
      make.centerY.equalTo(contentBackgroundView.snp.centerY)
    }

    contentBackgroundView.addSubview(rightSideStackView)
    rightSideStackView.snp.makeConstraints { make in
      make.leading.equalTo(titleLabel.snp.trailing).inset(12)
      make.trailing.equalTo(contentBackgroundView.snp.trailing).inset(8)
      make.centerY.equalTo(contentBackgroundView.snp.centerY)
    }

    rightSideStackView.addArrangedSubview(valueTextField)
    rightSideStackView.addArrangedSubview(rateLabel)

    rightSideStackView.alignment = .trailing
    rightSideStackView.axis = .vertical
    rightSideStackView.spacing = 4

    valueTextField.textAlignment = .right
    valueTextField.clearsOnBeginEditing = true
    valueTextField.keyboardType = .decimalPad
    valueTextField.delegate = self
    valueTextField.addDoneToolbar()

    rateLabel.textAlignment = .right
  }

  private func bindViewModel(viewModel: CurrencyCellViewModelType) {
    let outputs = viewModel.outputs

    outputs.titleAttributedString
      .bind(to: titleLabel.rx.attributedText)
      .disposed(by: disposeBag)

    outputs.valueAttributedString
      .bind(to: valueTextField.rx.attributedText)
      .disposed(by: disposeBag)

    outputs.rateAttributedString
      .bind(to: rateLabel.rx.attributedText)
      .disposed(by: disposeBag)

    outputs.isActive
      .observeOn(MainScheduler.instance)
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] isActive in
        guard let self = self else { return }
        self.rateLabel.isHidden = isActive
        self.valueTextField.isUserInteractionEnabled = isActive
        self.valueTextField.resignFirstResponder()
        self.contentBackgroundView.backgroundColor = isActive ? #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1) : UIColor.white
      })
      .disposed(by: disposeBag)
  }
}

extension CurrencyTableViewCell: UITextFieldDelegate {

  func startEdit() {
    valueTextField.becomeFirstResponder()
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    let value = Double(textField.text ?? "") ?? 1000
    didChangeInput?(value)
  }
}
