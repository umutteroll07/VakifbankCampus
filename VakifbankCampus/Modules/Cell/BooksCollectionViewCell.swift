//
//  BooksCollectionViewCell.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 23.08.2024.
//

import UIKit

class BooksCollectionViewCell: UICollectionViewCell {
    static let identifier = "BookCVCell"
        
    lazy var imageView_book = ImageViews(imageName: "")
    lazy var label_bookName = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 15), textColorLabel: .black)
    lazy var imageview_returnStatus = ImageViews(imageName: "circle.fill")

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureWithExt()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWithExt() {
        contentView.addSubview(imageView_book)
        contentView.addSubview(label_bookName)
        contentView.addSubview(imageview_returnStatus)
        
        // Shadow
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 0.8
        contentView.layer.shadowRadius = 5
        
        // label_bookName ayarları
        label_bookName.textAlignment = .center
        label_bookName.numberOfLines = 5
        
        // imageView_book ayarları
        imageView_book.contentMode = .scaleAspectFit
        
        imageView_book.anchor(
            top: contentView.topAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            paddingLeft: 5,
            paddingRight: 5,
            width: 125,
            height: 200
        )
        
        label_bookName.anchor(
            top: imageView_book.bottomAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            paddingTop: 10,
            paddingLeft: 5,
            paddingRight: 5,
            width: 100
        )
        
        imageview_returnStatus.contentMode = .scaleAspectFit
        imageview_returnStatus.anchor(
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            bottom: contentView.bottomAnchor,
            paddingBottom: 0,
            paddingLeft: 5,
            paddingRight: 5,
            width: 10,
            height: 10
        )
    }
    
    func hiddenCompanents(bool: Bool){
        label_bookName.isHidden = bool
        imageView_book.isHidden = bool
        imageview_returnStatus.isHidden = bool
    }
    
    func setBookCell(book: [BooksModel], indexpath: Int) {
        hiddenCompanents(bool: true)
        let books = book[indexpath]
        imageview_returnStatus.image = UIImage(systemName: "circle.fill")
        imageview_returnStatus.tintColor = .systemGreen
        label_bookName.text = books.title
        
        let imageUrlString = books.imageUrl
        if var urlComponents = URLComponents(string: imageUrlString) {
            urlComponents.scheme = "https"
            if let secureUrl = urlComponents.url {
                URLSession.shared.dataTask(with: secureUrl) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Failed to load image data: \(String(describing: error))")
                        return
                    }
                    DispatchQueue.main.async {
                        if let image = UIImage(data: data) {
                            self.imageView_book.image = image
                            self.hiddenCompanents(bool: false)
                        }
                    }
                }.resume()
                
            }
        }
    }
}
extension LibraryViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionView_bookcase {
            return CGSize(width: 150, height: 275)
        }
        else if collectionView == collectionView_reserveBook{
            return CGSize(width: 150, height: 275)
        }
        else {
            return CGSize(width: 200, height: 200)
        }
    }
}
