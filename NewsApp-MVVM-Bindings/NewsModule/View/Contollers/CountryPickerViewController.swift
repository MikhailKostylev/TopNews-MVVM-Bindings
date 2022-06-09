//
//  CountryPickerViewController.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 08.06.2022.
//

import UIKit
import SnapKit

protocol CountryPickerViewControllerDelegate: AnyObject {
    func setCountry(with country: String)
}

final class CountryPickerViewController: UIViewController {
    
    weak var delegate: CountryPickerViewControllerDelegate?
    
    private var allCountries = [
        (abbreviation: "ar", country: "Argentina"),
        (abbreviation: "au", country: "Australia"),
        (abbreviation: "br", country: "Brazil"),
        (abbreviation: "ca", country: "Canada"),
        (abbreviation: "cn", country: "China"),
        (abbreviation: "fr", country: "France"),
        (abbreviation: "de", country: "Germany"),
        (abbreviation: "gb", country: "Great Britain"),
        (abbreviation: "it", country: "Italy"),
        (abbreviation: "in", country: "India"),
        (abbreviation: "jp", country: "Japan"),
        (abbreviation: "kr", country: "Korea"),
        (abbreviation: "mx", country: "Mexico"),
        (abbreviation: "no", country: "Norway"),
        (abbreviation: "ru", country: "Russia"),
        (abbreviation: "se", country: "Sweden"),
        (abbreviation: "us", country: "United States")
    ]

    private lazy var countryPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .secondarySystemBackground
        return picker
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupCloseButton()
        setupCounrtyPicker()
    }
    
    // MARK: - Setups
    
    private func setupVC() {
        view.backgroundColor = .secondarySystemBackground
        navigationItem.title = "Choose a Country"
    }
    
    private func setupCounrtyPicker() {
        view.addSubview(countryPickerView)
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        
        countryPickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapCloseButton))
    }
    
    @objc private func didTapCloseButton() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Picker Methods

extension CountryPickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allCountries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allCountries[row].country
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.setCountry(with: allCountries[row].abbreviation)
        didTapCloseButton()
    }
}



