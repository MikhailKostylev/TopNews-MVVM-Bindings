//
//  Constants.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 07.06.2022.
//

import UIKit

enum Constants {
    
    /// Network
    static let baseUrl = "https://newsapi.org/v2/"
    static let topHeadlines = "top-headlines?"
    static let everything = "everything?"
    static let apiKey = "apiKey=a96e8e81f34545cab45001eca54cb78b" // a96e8e81f34545cab45001eca54cb78b
    static let country = "country="
    static let category = "category="
    static let query = "q="
    static let ampersand = "&"
    
    /// News/Topic TableView
    static let heightForHeader: CGFloat = 320
    static let heightForCell: CGFloat = 120
    static let heightForHeaderInSection: CGFloat = 50
}
