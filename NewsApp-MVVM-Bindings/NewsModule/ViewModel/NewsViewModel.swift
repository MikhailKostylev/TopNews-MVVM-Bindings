//
//  NewsViewModel.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 07.06.2022.
//

import Foundation

protocol NewsViewModelProtocol: AnyObject {
    var news: Bindable<[News]> { get set }
    var error: Bindable<NetworkError?> { get set }
    var title: Bindable<String> { get set }
    var isLoading: Bindable<Bool> { get set }
    var totalData: Int { get set }
    var searchText: String { get set }
    var country: String { get set }
    var topic: String { get set }
    func setCountryTitle()
    func setTopicTitle()
    func getTopNews(counry: String)
    func searchNews(query: String)
    func searchSpecificNews(topic: String, country: String)
    func switchingCases(result: Result<NewsResponse, NetworkError>)
    func successHandler(for result: NewsResponse)
    func errorHandler(for error: NetworkError)
}

final class NewsViewModel: NewsViewModelProtocol {
    
    let networkService: NetworkServiceProtocol
    
    var news: Bindable<[News]>
    var error: Bindable<NetworkError?>
    var title: Bindable<String>
    var isLoading: Bindable<Bool>
    var totalData: Int
    var searchText: String
    var country: String {
        didSet {
            getTopNews(counry: country)
            setCountryTitle()
        }
    }
    
    var topic: String {
        didSet {
            searchSpecificNews(topic: topic, country: country)
            setTopicTitle()
        }
    }
    
    init(model: Bindable<[News]>, networkService: NetworkServiceProtocol, error: Bindable<NetworkError?>, title: Bindable<String>, isLoading: Bindable<Bool>, totalData: Int, searchText: String, country: String, topic: String) {
        self.networkService = networkService
        self.news = model
        self.error = error
        self.title = title
        self.isLoading = isLoading
        self.totalData = totalData
        self.searchText = searchText
        self.country = country
        self.topic = topic
        getTopNews(counry: country)
        defer { setCountryTitle() }
    }
    
    // MARK: - Titles
    
    func setCountryTitle() {
        title.value = "News" + " - " + country.uppercased()
    }
    
    func setTopicTitle() {
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
        networkService.searchTopicNews(topic: topic, country: country) { [weak self] result in
            self?.switchingCases(result: result)
        }
    }
    
    // MARK: - Response Handlers
    
    func switchingCases(result: Result<NewsResponse, NetworkError>) {
        switch result {
        case .success(let data):
            successHandler(for: data)
        case .failure(let error):
            errorHandler(for: error)
        }
    }
    
    func successHandler(for result: NewsResponse) {
        news.value = result.articles
        isLoading.value = false
        totalData = result.totalResults
    }
    
    func errorHandler(for error: NetworkError) {
        self.error.value = error
        isLoading.value = false
        debugPrint(error.localizedDescription)
    }
}
