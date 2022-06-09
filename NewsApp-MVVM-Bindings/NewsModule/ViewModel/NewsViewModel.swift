//
//  NewsViewModel.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 07.06.2022.
//

import Foundation

final class NewsViewModel {
    
    let networkService: NetworkService
    
    var news = Bindable([News]())
    var error: Bindable<Error?> = Bindable(nil)
    var title: Bindable<String> = Bindable("")
    var isLoading = Bindable(true)
    
    var totalData = 0
    var searchText = ""
    var country = "ru" {
        didSet {
            getTopNews(counry: country)
            setCountryTitle()
        }
    }
    
    var topic = "" {
        didSet {
            searchSpecificNews(topic: topic, country: country)
            setTopicTitle()
        }
    }
    
    init(networkService: NetworkService) {
        self.networkService = networkService
        getTopNews(counry: country)
    }
    
    // MARK: - Private Methods
    
    private func setCountryTitle() {
        title.value = "News" + " - " + country.uppercased()
    }
    
    private func setTopicTitle() {
        title.value = "News" + " - " + country.uppercased() + " (\(topic))"
    }
    
    // MARK: - Network calls
    
    func getTopNews(counry: String) {
        networkService.getTopNews(country: country) { [weak self] result in
            self?.switchingCases(result: result)
        }
    }
    
    func searchNews(query: String) {
        networkService.searchNews(query: query) { [weak self] result in
            self?.switchingCases(result: result)
        }
    }
    
    func searchSpecificNews(topic: String, country: String) {
        networkService.searchSpecificNews(topic: topic, country: country) { [weak self] result in
            self?.switchingCases(result: result)
        }
    }
    
    // MARK: - Response Handlers
    
    private func switchingCases(result: Result<NewsResponse, NetworkError>) {
        switch result {
        case .success(let data):
            successHandler(for: data)
        case .failure(let error):
            errorHandler(for: error)
        }
    }
    
    private func successHandler(for result: NewsResponse) {
        news.value = result.articles
        isLoading.value = false
        totalData = result.totalResults
    }
    
    private func errorHandler(for error: NetworkError) {
        self.error.value = error
        isLoading.value = false
        debugPrint(error.localizedDescription)
    }
}
