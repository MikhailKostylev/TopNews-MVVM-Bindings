//
//  NewsViewController.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 07.06.2022.
//

import UIKit
import SnapKit

protocol NewsViewControllerProtocol: AnyObject {
    var viewModel: NewsViewModelProtocol { get }
}

final class NewsViewController: UIViewController, NewsViewControllerProtocol {
    
    var viewModel: NewsViewModelProtocol
    
    private let sections = [CellType.header, CellType.list]
    private let searchController = UISearchController(searchResultsController: nil)
    private let refreshControl = UIRefreshControl()
    private var isSearching = false
    private var isLoaded = false
    
    // MARK: - UI elements
    
    private let newsTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        return table
    }()
    
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.tintColor = .label
        return spinner
    }()
    
    // MARK: - Init
    
    init(viewModel: NewsViewModelProtocol) {
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
        view.addSubview(spinner)
        
        newsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        spinner.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    private func setupNewsTableView() {
        newsTableView.dataSource = self
        newsTableView.delegate = self
        newsTableView.register(
            HeaderNewsTableViewCell.self,
            forCellReuseIdentifier: HeaderNewsTableViewCell.identifier)
        newsTableView.register(
            SkeletonHeaderCell.self,
            forCellReuseIdentifier: SkeletonHeaderCell.identifier)
        newsTableView.register(
            NewsTableViewCell.self,
            forCellReuseIdentifier: NewsTableViewCell.identifier)
        newsTableView.register(
            SkeletonCell.self,
            forCellReuseIdentifier: SkeletonCell.identifier)
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
        isLoaded = !isLoaded
        newsTableView.reloadData()
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
                self?.isLoaded = true
                self?.newsTableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
        
        viewModel.isLoading.bind { [weak self] isLoading in
            DispatchQueue.main.async {
                if !isLoading {
                    self?.spinner.stopAnimating()
                } else {
                    self?.isLoaded = false
                    self?.newsTableView.reloadData()
                }
            }
        }
        
        viewModel.error.bind { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    let title = "Oops.. something went wrong"
                    let message = "Error Code: \(error.localizedDescription)"
                    self?.showAlert(title: title, message: message)
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
            if isLoaded {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: HeaderNewsTableViewCell.identifier,
                    for: indexPath) as? HeaderNewsTableViewCell else { return UITableViewCell() }
                if let firstNews = viewModel.news.value.first {
                    cell.configure(with: firstNews)
                }
                return cell
                
            } else {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SkeletonHeaderCell.identifier,
                    for: indexPath) as? SkeletonHeaderCell else { return UITableViewCell() }
                if let firstNews = viewModel.news.value.first {
                    cell.configure(with: firstNews)
                }
                return cell
            }
            
        case .list:
            let news = viewModel.news.value[indexPath.row + 1]
            
            if isLoaded {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NewsTableViewCell.identifier,
                for: indexPath) as? NewsTableViewCell else { return UITableViewCell() }
                cell.configure(with: news)
                return cell
                
            } else {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SkeletonCell.identifier,
                    for: indexPath) as? SkeletonCell else { return UITableViewCell() }
                cell.configure(with: news)
                return cell
            }
            
        }
    }
}

// MARK: - Table Delegate Methods

extension NewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var news = viewModel.news.value[indexPath.row]
        
        switch indexPath.section {
        case 0:
            news = viewModel.news.value[indexPath.row]
        case 1:
            news = viewModel.news.value[indexPath.row + 1]
        default:
            break
        }
        
        let vc = CurrentNewsViewController(news: news)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
        case .header:
            return Constants.heightForHeader
        case .list:
            return Constants.heightForCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.heightForHeaderInSection
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = sections[section]
        let headerView = UIView()
        let headerLabel = UILabel(frame: CGRect(
            x: Constants.padding,
            y: 0,
            width: view.width - Constants.padding,
            height: Constants.heightForHeaderInSection))
        headerLabel.font = .systemFont(ofSize: 28, weight: .semibold)
        headerView.addSubview(headerLabel)

        switch section {
        case .header:
            headerLabel.text = "Trending"
            return headerView
        case .list:
            headerLabel.text = "Top Headlines"
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

// MARK: - Country/Topic Delegates

extension NewsViewController: CountryPickerViewControllerDelegate, TopicViewControllerDelegate {

    func setCountry(with country: String) {
        viewModel.country = country
    }
    
    func setTopic(with topic: String){
        viewModel.topic = topic
    }
}


