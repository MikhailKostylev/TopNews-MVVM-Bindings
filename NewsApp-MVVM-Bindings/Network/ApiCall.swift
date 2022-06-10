//
//  ApiCall.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 09.06.2022.
//

import Foundation

protocol ApiCallProtocol {
    func setupTopNewsUrl(country: String) -> String
    func setupNewsUrl(query: String) -> String
    func setupSpecificNewsUrl(topic: String, country: String) -> String
}

struct ApiCall: ApiCallProtocol {
    
    /// example: "https://newsapi.org/v2/top-headlines?apiKey=53b50c107ff04fab932893969fd0974e&country=ru"
    func setupTopNewsUrl(country: String) -> String {
        return Constants.baseUrl + Constants.topHeadlines + Constants.apiKey + Constants.ampersand + Constants.country + country
    }
    
    /// example: "https://newsapi.org/v2/everything?apiKey=53b50c107ff04fab932893969fd0974e&q=Apple"
    func setupNewsUrl(query: String) -> String {
        return Constants.baseUrl + Constants.everything + Constants.apiKey + Constants.ampersand + Constants.query + query
    }
    
    /// example: "https://newsapi.org/v2/top-headlines?category=health&country=ru&apiKey=53b50c107ff04fab932893969fd0974e"
    func setupSpecificNewsUrl(topic: String, country: String) -> String {
        return Constants.baseUrl + Constants.topHeadlines + Constants.category + topic + Constants.ampersand + Constants.country + country + Constants.ampersand + Constants.apiKey
    }
}
