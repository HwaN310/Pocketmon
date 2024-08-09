//
//  MainViewModel.swift
//  Pocketmon
//
//  Created by t2023-m0102 on 8/7/24.
//

import Foundation
import RxSwift

class MainViewModel {
  private let disposeBag = DisposeBag()
  let pocketmonListSubject = PublishSubject<[Pocketmon]>()
  private let limit = 20
  private var offset = 0 // offset을 var로 변경하여 페이지네이션 구현
  
  func fetchPocketmons() {
    // API URL
    guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)") else {
      print("Invalid URL")
      return
    }
    
    // 네트워크 요청
    NetworkManager.shared.fetch(url: url)
      .observe(on: MainScheduler.instance)
      .subscribe(onSuccess: { [weak self] (response: PocketmonListResponse) in
        // API 응답에서 포켓몬 이름과 URL을 가져와서 Pocketmon 배열 생성
        let pocketmons = response.results.compactMap { result -> Pocketmon? in
          if let id = result.pocketmonID {
            // 기본 이미지 URL 설정
            let imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
            return Pocketmon(id: id, name: result.name, imageUrl: imageUrl, types: nil, height: nil, weight: nil)
          }
          return nil
        }
        self?.pocketmonListSubject.onNext(pocketmons)
        self?.offset += self?.limit ?? 0 // 다음 요청을 위해 offset 증가
      }, onError: { error in
        print("Error fetching pocketmons: \(error)")
      })
      .disposed(by: disposeBag)
  }
}
