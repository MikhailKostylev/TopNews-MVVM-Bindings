//
//  NewsModel.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 07.06.2022.
//

import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [News]
}

struct News: Codable {
    let source: Source
    let author: String?
    let title: String
    let articleDescription: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

struct Source: Codable {
    let id: String?
    let name: String
}
