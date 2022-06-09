//
//  Binding.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 07.06.2022.
//

import Foundation

final class Bindable<T> {
    
    typealias Listener = (T) -> Void
    
    private var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
