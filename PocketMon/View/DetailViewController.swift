//
//  DetailViewController.swift
//  Pocketmon
//
//  Created by t2023-m0102 on 8/9/24.
//
import UIKit
import SnapKit
import Kingfisher
import RxSwift

class DetailViewController: UIViewController {
  private let pokemonID: String
  private let imageUrl: URL?
  private let disposeBag = DisposeBag()
  
  private let infoContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .darkRed
    view.layer.cornerRadius = 12
    view.layer.masksToBounds = true
    return view
  }()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 30)
    label.textColor = .white // 텍스트 색상을 변경
    label.textAlignment = .center
    return label
  }()
  
  private let typeLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18)
    label.textColor = .white // 텍스트 색상을 변경
    label.textAlignment = .center
    return label
  }()
  
  private let heightLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18)
    label.textColor = .white // 텍스트 색상을 변경
    label.textAlignment = .center
    return label
  }()
  
  private let weightLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18)
    label.textColor = .white // 텍스트 색상을 변경
    label.textAlignment = .center
    return label
  }()
  
  init(pokemonID: String, imageUrl: URL?) {
    self.pokemonID = pokemonID
    self.imageUrl = imageUrl
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    fetchPokemonDetails()
  }
  
  private func configureUI() {
    view.backgroundColor = .mainRed
    view.addSubview(infoContainerView)
    
    infoContainerView.addSubview(imageView)
    infoContainerView.addSubview(nameLabel)
    infoContainerView.addSubview(typeLabel)
    infoContainerView.addSubview(heightLabel)
    infoContainerView.addSubview(weightLabel)
    
    // infoContainerView 레이아웃 설정
    infoContainerView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.height.equalTo(400) // 높이를 적절히 조정
    }
    
    // imageView 레이아웃 설정
    imageView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().offset(30)
      $0.height.width.equalTo(150)
    }
    
    // nameLabel 레이아웃 설정
    nameLabel.snp.makeConstraints {
      $0.top.equalTo(imageView.snp.bottom).offset(20)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    // typeLabel 레이아웃 설정
    typeLabel.snp.makeConstraints {
      $0.top.equalTo(nameLabel.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    // heightLabel 레이아웃 설정
    heightLabel.snp.makeConstraints {
      $0.top.equalTo(typeLabel.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    // weightLabel 레이아웃 설정
    weightLabel.snp.makeConstraints {
      $0.top.equalTo(heightLabel.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
  }
  
  private func fetchPokemonDetails() {
    let urlString = "https://pokeapi.co/api/v2/pokemon/\(pokemonID)"
    
    guard let url = URL(string: urlString) else {
      print("Invalid URL")
      return
    }
    
    NetworkManager.shared.fetch(url: url)
      .observe(on: MainScheduler.instance)
      .subscribe(onSuccess: { [weak self] (response: PocketmonDetailResponse) in
        guard let self = self else { return }
        self.updateUI(with: response)
      }, onError: { [weak self] error in
        guard let self = self else { return }
        self.showErrorAlert(message: "포켓몬 정보를 불러오는데 실패했습니다. 나중에 다시 시도해주세요.")
      }).disposed(by: disposeBag)
  }
  
  private func updateUI(with response: PocketmonDetailResponse) {
    // Kingfisher를 사용하여 메인 화면에서 전달된 이미지 URL을 로드
    if let imageUrl = self.imageUrl {
      imageView.kf.setImage(with: imageUrl)
    }
    // 포켓몬 이름을 한글로 변환
    nameLabel.text = "No. \(pokemonID) " + PokemonTranslator.getKoreanName(for: response.name)
    var height = response.height/10
    var weight = response.weight/10
    // 포켓몬 타입을 한글로 변환
    typeLabel.text = "타입: " + response.types.map { PokemonTypeName(rawValue: $0.type.name)?.displayName ?? $0.type.name }.joined(separator: ", ")
    heightLabel.text = "키: \(height)m"
    weightLabel.text = "몸무게: \(weight)kg"
  }
  
  private func showErrorAlert(message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
}
