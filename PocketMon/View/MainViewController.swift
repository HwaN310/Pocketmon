//
//  ViewController.swift
//  PocketMon
//
//  Created by t2023-m0102 on 8/6/24.
//
import UIKit
import RxSwift
import SnapKit
import Kingfisher

class MainViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let viewModel = MainViewModel()
  
  private var pocketmonList = [Pocketmon]()
  private var isLoading = false // 로딩 상태를 추적하기 위한 변수
  
  private let pokeBallImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "MonsterBall"))
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    collectionView.register(PocketmonCollectionViewCell.self, forCellWithReuseIdentifier: PocketmonCollectionViewCell.id)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = .darkRed
    return collectionView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bind()
    loadMorePocketmons() // 초기 데이터 로드
    
    let exampleImageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png"
    configureImageView(with: exampleImageUrl)
  }
  
  private func configureUI() {
    view.backgroundColor = .mainRed
    view.addSubview(pokeBallImageView)
    view.addSubview(collectionView)
    view.addSubview(imageView)
    
    pokeBallImageView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
      $0.centerX.equalToSuperview()
      $0.height.width.equalTo(80)
    }
    
    collectionView.snp.makeConstraints {
      $0.top.equalTo(pokeBallImageView.snp.bottom).offset(16)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
      $0.leading.trailing.equalToSuperview()
    }
  }
  
  private func bind() {
    viewModel.pocketmonListSubject
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] pocketmons in
        guard let self = self else { return }
        self.pocketmonList.append(contentsOf: pocketmons)
        self.collectionView.reloadData()
        self.isLoading = false // 데이터 로드 완료 후 로딩 상태 업데이트
      }, onError: { error in
        print("에러 발생: \(error)")
        self.isLoading = false // 데이터 로드 실패 후 로딩 상태 업데이트
      }).disposed(by: disposeBag)
  }
  
  private func configureImageView(with imageUrl: String?) {
    if let urlString = imageUrl, let url = URL(string: urlString) {
      imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder.png"))
    } else {
      imageView.image = UIImage(named: "placeholder.png")
    }
  }
  
  private func createLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalWidth(0.3)
    )
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitem: item,
      count: 3
    )
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 10
    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
    
    return UICollectionViewCompositionalLayout(section: section)
  }
  
  private func loadMorePocketmons() {
    guard !isLoading else { return } // 로딩 중일 때는 추가 로드 방지
    isLoading = true
    viewModel.fetchPocketmons()
  }
}

extension MainViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return pocketmonList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PocketmonCollectionViewCell.id, for: indexPath) as? PocketmonCollectionViewCell else {
      return UICollectionViewCell()
    }
    
    let pocketmon = pocketmonList[indexPath.row]
    cell.configure(with: pocketmon)
    
    return cell
  }
}

extension MainViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let pocketmon = pocketmonList[indexPath.row]
    
    let imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pocketmon.id).png"
    let imageUrl = URL(string: imageUrlString)
    
    let detailViewController = DetailViewController(pokemonID: String(pocketmon.id), imageUrl: imageUrl)
    self.navigationController?.pushViewController(detailViewController, animated: true)
  }
}

extension MainViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let contentOffsetY = scrollView.contentOffset.y
    let contentHeight = scrollView.contentSize.height
    let frameHeight = scrollView.frame.size.height
    
    if contentOffsetY > contentHeight - frameHeight * 2 {
      loadMorePocketmons() // 스크롤이 끝에 가까워지면 다음 데이터를 로드
    }
  }
}

extension UIColor {
  static let mainRed = UIColor(red: 190/255, green: 30/255, blue: 40/255, alpha: 1.0)
  static let darkRed = UIColor(red: 120/255, green: 30/255, blue: 30/255, alpha: 1.0)
  static let cellBackground = UIColor(red: 245/255, green: 245/255, blue: 235/255, alpha: 1.0)
}
