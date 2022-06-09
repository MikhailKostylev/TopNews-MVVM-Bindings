//
//  NewsViewController.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 07.06.2022.
//

import UIKit
import SnapKit
import SafariServices

final class NewsViewController: UIViewController {
    
    private let viewModel: NewsViewModel
    private let sections = [CellType.header, CellType.list]
    private let searchController = UISearchController(searchResultsController: nil)
    private let refreshControl = UIRefreshControl()
    private var isSearching = false
    
    // MARK: - UI elements
    
    private let newsTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        return table
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        spinner.tintColor = .label
        return spinner
    }()
    
    // MARK: - Init
    
    init(viewModel: NewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupLayout()
        setupNewsTableView()
        setupSearchController()
        setupBarButtons()
        setupRefreshControl()
        setupBindings()
    }
    
    // MARK: - Setups
    
    private func setupVC() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationItem.title = "News"
        navigationController?.navigationBar.tintColor = .label
        navigationItem.backButtonTitle = ""
        spinner.startAnimating()
    }
    
    private func setupLayout() {
        view.addSubview(newsTableView)
        view.addSubview(errorLabel)
        view.addSubview(spinner)
        
        newsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        errorLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        spinner.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    private func setupNewsTableView() {
        newsTableView.dataSource = self
        newsTableView.delegate = self
        newsTableView.register(
            NewsTableViewCell.self,
            forCellReuseIdentifier: NewsTableViewCell.identifier)
        newsTableView.register(
            HeaderNewsTableViewCell.self,
            forCellReuseIdentifier: HeaderNewsTableViewCell.identifier)
    }
    
    private func setupSearchController() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Topic"
        navigationItem.searchController = searchController
    }
    
    private func setupBarButtons() {
        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .done,
            target: self,
            action: #selector(didTapSearchButton)
        )
        
        let countryButton = UIBarButtonItem(
            image: UIImage(systemName: "globe.europe.africa"),
            style: .done,
            target: self,
            action: #selector(didTapCountryButton)
        )
        
        let topicButton = UIBarButtonItem(
            image: UIImage(systemName: "list.dash"),
            style: .done,
            target: self,
            action: #selector(didTapTopicButton)
        )
        
        navigationItem.leftBarButtonItem = searchButton
        navigationItem.rightBarButtonItems = [countryButton, topicButton]
    }
    
    private func setupRefreshControl() {
        newsTableView.refreshControl = refreshControl
        refreshControl.addTarget(
            self,
            action: #selector(refreshNewsData),
            for: .valueChanged
        )
    }
    
    // MARK: - Actions
    
    @objc private func didTapSearchButton() {
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
    }
    
    @objc private func didTapCountryButton() {
        let countryPickerVC = CountryPickerViewController()
        countryPickerVC.delegate = self
        navigationController?.pushViewController(countryPickerVC, animated: true)
    }
    
    @objc private func didTapTopicButton() {
        let topicVC = TopicViewController()
        topicVC.delegate = self
        navigationController?.pushViewController(topicVC, animated: true)
    }
    
    @objc private func refreshNewsData() {
        viewModel.getTopNews(counry: viewModel.country)
        isSearching = false
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        
        viewModel.title.bind { [weak self] title in
            DispatchQueue.main.async {
                self?.title = title
            }
        }
        
        viewModel.news.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.newsTableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
        
        viewModel.isLoading.bind { [weak self] isLoading in
            DispatchQueue.main.async {
                if !isLoading {
                    self?.spinner.stopAnimating()
                }
            }
        }
        
        viewModel.error.bind { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorLabel.isHidden = false
                    self?.errorLabel.text = "Oops.. Something Went Wrong\nError Code: \(error.localizedDescription)"
                } else {
                    self?.errorLabel.isHidden = true
                }
            }
        }
    }
}

enum CellType {
    case header
    case list
}

// MARK: - Table Data Source Methods

extension NewsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .header: return 1
        case .list: return viewModel.news.value.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .header:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: HeaderNewsTableViewCell.identifier,
                for: indexPath
            ) as? HeaderNewsTableViewCell
            if let firstNews = viewModel.news.value.first {
                cell?.configure(with: firstNews)
            }
            return cell ?? UITableViewCell()
            
        case .list:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: NewsTableViewCell.identifier,
                for: indexPath
            ) as? NewsTableViewCell
            cell?.configure(with: viewModel.news.value[indexPath.row + 1])
            return cell ?? UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
        case .header:
            return Constants.heightForHeader
        case .list:
            return Constants.heightForCell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section] {
        case .header:
            return "Trending"
        case .list:
            return "Top Headlines"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.heightForHeaderInSection
    }
}

// MARK: - Table Delegate Methods

extension NewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = SFSafariViewController(url: URL(string: viewModel.news.value[indexPath.row].url)!)
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = sections[section]
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 16, y: 5, width: 320, height: 30)
        myLabel.font = UIFont.boldSystemFont(ofSize: 28)

        let headerView = UIView()
        headerView.addSubview(myLabel)

        switch section {
        case .header:
            myLabel.text = "Trending"
            return headerView
        case .list:
            myLabel.text = "Top Headlines"
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .header: return
        case .list:
            if indexPath.row == viewModel.news.value.count - 2 && viewModel.news.value.count < viewModel.totalData {
                if isSearching {
                    viewModel.searchNews(query: viewModel.searchText)
                } else {
                    viewModel.getTopNews(counry: viewModel.country)
                }
            }
        }
    }
}

// MARK: - Country/Topic Delegates

extension NewsViewController: CountryPickerViewControllerDelegate, TopicViewControllerDelegate {

    func setCountry(with country: String) {
        viewModel.country = country
    }
    
    func setTopic(with topic: String){
        viewModel.topic = topic
    }
}

// MARK: - Search Bar Methods

extension NewsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        spinner.startAnimating()
        viewModel.searchText = searchText
        
        if searchText == "" {
            isSearching = false
            viewModel.getTopNews(counry: viewModel.country)
        } else {
            isSearching = true
            viewModel.searchNews(query: searchText)
        }
    }
}


