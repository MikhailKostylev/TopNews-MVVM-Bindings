//
//  NetworkService.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 09.06.2022.
//

import Foundation
import Alamofire

protocol NetworkServiceProtocol: AnyObject {
    var apiCall: ApiCallProtocol { get }
    func getTopNews(country: String, completion: @escaping (Result<NewsResponse, NetworkError>) -> Void)
    func searchNews(query: String, completion: @escaping (Result<NewsResponse, NetworkError>) -> Void)
    func searchTopicNews(topic: String, country: String, completion: @escaping (Result<NewsResponse, NetworkError>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
    
    var apiCall: ApiCallProtocol
    
    init(apiCall: ApiCallProtocol) {
        self.apiCall = apiCall
    }
    
    func getTopNews(country: String, completion: @escaping (Result<NewsResponse, NetworkError>) -> Void) {
        guard !country.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let urlString = apiCall.setupTopNewsUrl(country: country)
        guard let url = URL(string: urlString) else { return }
        
        AF.request(url)
            .validate()
            .responseDecodable(of: NewsResponse.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(_):
                    completion(.failure(.failedToGetData))
                }
            }
    }
    
    func searchNews(query: String, completion: @escaping (Result<NewsResponse, NetworkError>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let urlString = apiCall.setupNewsUrl(query: query)
        guard let url = URL(string: urlString) else { return }
        
        AF.request(url)
            .validate()
            .responseDecodable(of: NewsResponse.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(_):
                    completion(.failure(.failedToGetData))
                }
            }
    }
    
    func searchTopicNews(topic: String, country: String, completion: @escaping (Result<NewsResponse, NetworkError>) -> Void) {
        guard !topic.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard !country.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let urlString = apiCall.setupSpecificNewsUrl(topic: topic, country: country)
        guard let url = URL(string: urlString) else { return }
        
        AF.request(url)
            .validate()
            .responseDecodable(of: NewsResponse.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(_):
                    completion(.failure(.failedToGetData))
                }
            }
    }
}
