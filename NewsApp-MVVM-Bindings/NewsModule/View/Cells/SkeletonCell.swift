//
//  SkeletonCell.swift
//  NewsApp-MVVM-Bindings
//
//  Created by Mikhail Kostylev on 12.06.2022.
//

import UIKit
import SnapKit
import Kingfisher

final class SkeletonCell: UITableViewCell, SkeletonLoadable {
    
    static let identifier = "SkeletonCell"
    
    private var iconImageLayer = CAGradientLayer()
    private var titleLayer = CAGradientLayer()
    private var dateLayer = CAGradientLayer()
    private var publisherLayer = CAGradientLayer()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private let publisherLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageLayer.frame = iconImageView.bounds
        iconImageLayer.cornerRadius = 5
        
        titleLayer.frame = titleLabel.bounds
        titleLayer.cornerRadius = 3
        
        dateLayer.frame = dateLabel.bounds
        dateLayer.cornerRadius = 3
        
        publisherLayer.frame = publisherLabel.bounds
        publisherLayer.cornerRadius = 3
    }
    
    private func setup() {
        iconImageLayer.startPoint = CGPoint(x: 0, y: 0)
        iconImageLayer.endPoint = CGPoint(x: 1, y: 1)
        iconImageView.layer.addSublayer(iconImageLayer)
        
        titleLayer.startPoint = CGPoint(x: 0, y: 0)
        titleLayer.endPoint = CGPoint(x: 1, y: 0.5)
        titleLabel.layer.addSublayer(titleLayer)
        
        dateLayer.startPoint = CGPoint(x: 0, y: 0)
        dateLayer.endPoint = CGPoint(x: 1, y: 0.5)
        dateLabel.layer.addSublayer(dateLayer)
        
        publisherLayer.startPoint = CGPoint(x: 0, y: 0)
        publisherLayer.endPoint = CGPoint(x: 1, y: 0.5)
        publisherLabel.layer.addSublayer(publisherLayer)
        
        let imageGroup = makeAnimationGroup()
        imageGroup.beginTime = 0.0
        iconImageLayer.add(imageGroup, forKey: "backgroundColor")
        
        let titleGroup = makeAnimationGroup(previousGroup: imageGroup)
        titleLayer.add(titleGroup, forKey: "backgroundColor")
        
        let dateGroup = makeAnimationGroup(previousGroup: titleGroup)
        dateLayer.add(dateGroup, forKey: "backgroundColor")
        
        let publisherGroup = makeAnimationGroup(previousGroup: dateGroup)
        publisherLayer.add(publisherGroup, forKey: "backgroundColor")
    }
    
    private func layout() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(publisherLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(80)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.top)
            make.leading.equalTo(iconImageView.snp.trailing).inset(-10)
            make.trailing.equalToSuperview().inset(20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(-10)
            make.leading.equalTo(titleLabel.snp.leading)
            make.width.equalTo(100)
        }
        
        publisherLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(-10)
            make.leading.equalTo(dateLabel.snp.trailing).inset(-10)
            make.trailing.equalTo(titleLabel.snp.trailing)
        }
    }
    
    func configure(with model: News) {
        guard let url = URL(string: model.urlToImage ?? "") else { return }
        
        iconImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage
            ])
        
        dateLabel.text = model.publishedAt.toDate()?.timeAgoDisplay()
        titleLabel.text = model.title
        publisherLabel.text = model.source.name
    }
}

