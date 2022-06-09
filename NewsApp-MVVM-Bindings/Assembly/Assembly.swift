//
//  Assembly.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 07.06.2022.
//

import UIKit

final class Assembly {
    
    func configureNewsModule() -> UIViewController {
        let apiCall = ApiCall()
        let networkService = NetworkService(apiCall: apiCall)
        let viewModel = NewsViewModel(networkService: networkService)
        let newsVC = NewsViewController(viewModel: viewModel)
        return newsVC
    }
}
