//
//  NewsCollectionViewCell.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 21.08.2024.
//

import UIKit

class NewsCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewCVCell"
    
    lazy var imageView_news = ImageViews(imageName: "")
    lazy var label_newTitle = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 15), textColorLabel: .black)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureWithExt()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithExt() {
        contentView.addSubview(imageView_news)
        contentView.addSubview(label_newTitle)
        
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 0.8
        contentView.layer.shadowRadius = 5
        
        label_newTitle.textAlignment = .center
        label_newTitle.numberOfLines = 0
        label_newTitle.lineBreakMode = .byWordWrapping
        
        imageView_news.contentMode = .scaleToFill
        imageView_news.anchor(top: contentView.topAnchor,
            left: contentView.leftAnchor,
            right:contentView.rightAnchor,
            paddingTop: 0,
            paddingLeft: 10,
            paddingRight: 10,
            width: 125, height: 250
        )
        
        label_newTitle.anchor(top: imageView_news.bottomAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            bottom: contentView.bottomAnchor,
            paddingTop: 0,
            paddingBottom: 0,
            paddingLeft: 15,
            paddingRight: 15,
            width: 100
        )
    }
    
    

    func removeImageExtension(from string: String) -> String {
        // `.png` , `.jpeg` , '.jpg' uzantısını bulup, bu uzantılardan sonrasını silmek için
        if let range = string.range(of: ".png") {
            let substring = string[..<range.upperBound]
            return substring.trimmingCharacters(in: .whitespaces)
        } else if let range = string.range(of: ".jpeg") {
            let substring = string[..<range.upperBound]
            return substring.trimmingCharacters(in: .whitespaces)
        }
        else if let range = string.range(of: ".jpg") {
            let substring = string[..<range.upperBound]
            return substring.trimmingCharacters(in: .whitespaces)
        }
        else {
            return string
        }
    }
    
    func setCell(news: Datas) {
        label_newTitle.text = news.title
        
        let imageUrlString = news.image
        let result = removeImageExtension(from: imageUrlString)
        
        if var urlComponents = URLComponents(string: result) {
            urlComponents.scheme = "https"
            if let secureUrl = urlComponents.url {
                loadImage(from: secureUrl)
            }
        }
    }

    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("Error converting data to image")
                return
            }
            DispatchQueue.main.async {
                self?.imageView_news.image = image
            }
        }
        task.resume()
    }
}
