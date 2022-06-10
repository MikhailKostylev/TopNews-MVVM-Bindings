//
//  Assembly.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 07.06.2022.
//

import UIKit

final class Assembly {
    
    func configureNewsModule() -> UIViewController {
        let model = Bindable([News]())
        let apiCall = ApiCall()
        let networkService = NetworkService(apiCall: apiCall)
        let viewModel = NewsViewModel(
            model: model,
            networkService: networkService,
            error: Bindable(nil),
            title: Bindable(""),
            isLoading: Bindable(true),
            totalData: 0,
            searchText: "",
            country: "ru",
            topic: "")
        let newsVC = NewsViewController(viewModel: viewModel)
        return newsVC
    }
}
