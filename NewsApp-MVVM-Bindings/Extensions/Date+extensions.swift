//
//  Date+extensions.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 07.06.2022.
//

import Foundation

extension Date {
    
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
