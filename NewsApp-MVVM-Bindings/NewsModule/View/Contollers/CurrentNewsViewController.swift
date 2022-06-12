//
//  CurrentNewsViewController.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 12.06.2022.
//

import UIKit
import SnapKit
import Kingfisher
import SafariServices

class CurrentNewsViewController: UIViewController {
    
    var news: News
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true

        return scrollView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .natural
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let newsPageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Read more", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        return button
    }()
    
    // MARK: - Init
    
    init(news: News) {
        self.news = news
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupLabels()
        setupImageView()
        setupNewsPageButton()
        setupLayout()
    }
    
    // MARK: - Setups
    
    private func setupVC() {
        view.backgroundColor = .systemBackground
        navigationItem.title = news.source.name
    }
    
    private func setupLabels() {
        titleLabel.text = news.title
        dateLabel.text = Date.string(iso: news.publishedAt)
        authorLabel.text = news.author ?? ""
    }
    
    private func setupImageView() {
        guard let url = URL(string: news.urlToImage ?? "") else { return }
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage
            ])
    }
    
    private func setupNewsPageButton() {
        newsPageButton.addTarget(
            self,
            action: #selector(didTapNewsPageButton),
            for: .touchUpInside
        )
    }
    
    @objc private func didTapNewsPageButton() {
        guard let url = URL(string: news.url) else { return }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(authorLabel)
        containerView.addSubview(imageView)
        containerView.addSubview(newsPageButton)
        
        let padding = Constants.padding
        
        scrollView.snp.makeConstraints { make in
            make.width.equalTo(view.snp.width)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        containerView.snp.makeConstraints { make in
            make.height.equalTo(view)
            make.leading.trailing.equalTo(view).inset(padding)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.width.equalTo(containerView.snp.width)
            make.top.equalTo(containerView).inset(padding)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.width.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).inset(-padding)
        }
        
        authorLabel.snp.makeConstraints { make in
            make.width.equalTo(titleLabel)
            make.top.equalTo(dateLabel.snp.bottom).inset(-padding)
        }
        
        imageView.snp.makeConstraints { make in
            make.width.equalTo(titleLabel)
            make.top.equalTo(authorLabel.snp.bottom).inset(-padding)
            make.height.lessThanOrEqualTo(containerView.snp.width)
        }
        
        newsPageButton.snp.makeConstraints { make in
            make.width.equalTo(titleLabel)
            make.top.equalTo(imageView.snp.bottom).inset(-padding)
        }
    }
}
