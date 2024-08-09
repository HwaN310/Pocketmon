//
//  pocketmonImageCell.swift
//  Pocketmon
//
//  Created by t2023-m0102 on 8/8/24.
//

import UIKit
import Kingfisher
import RxSwift

class PocketmonCollectionViewCell: UICollectionViewCell {
  static let id = "PocketmonCollectionViewCell"
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  let disposeBag = DisposeBag()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.backgroundColor = .cellBackground
    contentView.layer.cornerRadius = 10
    contentView.addSubview(imageView)
    
    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(8)  // 이미지 뷰가 셀 내부의 여백을 갖도록 설정
    }
  }
  
  
  func configure(with pocketmon: Pocketmon) {
    if let imageUrl = pocketmon.imageUrl, let url = URL(string: imageUrl) {
      imageView.kf.setImage(with: url)
    } else {
      imageView.image = UIImage(named: "placeholder")  // 기본 이미지 설정
    }
  }
  
}

