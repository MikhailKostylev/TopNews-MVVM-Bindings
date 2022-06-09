//
//  UIView+extensions.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 07.06.2022.
//

import UIKit

extension UIView {
    @discardableResult func prepareForAutoLayout() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}
