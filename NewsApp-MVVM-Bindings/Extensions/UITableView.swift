//
//  UITableView.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 10.06.2022.
//

import Foundation
import UIKit

extension UITableView {
    
    func animateTableView() {
        self.reloadData()
        
        let cells = self.visibleCells
        let tableViewHight = self.bounds.height
        
        var delay: Double = 0
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHight)
            
            UIView.animate(
                withDuration: 1,
                delay: delay * 0.05,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0,
                options: .curveEaseInOut) {
                    cell.transform = CGAffineTransform.identity
                }
            
            delay += 1
        }
    }
}

