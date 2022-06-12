//
//  TopicViewController.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 08.06.2022.
//

import UIKit
import SnapKit

protocol TopicViewControllerDelegate: AnyObject {
    func setTopic(with topic: String)
}

final class TopicViewController: UIViewController {
    
    weak var delegate: TopicViewControllerDelegate?
    
    private var topics = [
        "Business",
        "Entertainment",
        "General",
        "Health",
        "Science",
        "Sports",
        "Technology"
    ]
    
    private lazy var topicsTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.backgroundColor = .secondarySystemBackground
        return table
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupCloseButton()
        setupTopicsTable()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topicsTableView.animateTableView()
    }
    
    // MARK: - Setups
    
    private func setupVC() {
        view.backgroundColor = .secondarySystemBackground
        navigationItem.title = "Choose a Topic"
    }
    
    private func setupTopicsTable() {
        view.addSubview(topicsTableView)
        topicsTableView.rowHeight = Constants.heightForCell/1.5
        topicsTableView.delegate = self
        topicsTableView.dataSource = self
        
        topicsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapCloseButton))
    }
    
    @objc private func didTapCloseButton() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Table Methods

extension TopicViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = topicsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = topics[indexPath.row]
        cell.textLabel?.textAlignment = .center
        return cell
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        topicsTableView.deselectRow(at: indexPath, animated: true)
        delegate?.setTopic(with: topics[indexPath.row])
        didTapCloseButton()
    }
}
