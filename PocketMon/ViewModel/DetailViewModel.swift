//
//  DetailViewModel.swift
//  Pocketmon
//
//  Created by t2023-m0102 on 8/9/24.
//

import Foundation
import RxSwift

class DetailViewModel {
  private let disposeBag = DisposeBag()
  let pocketmonDetailSubject = PublishSubject<Pocketmon>()
  
  func fetchPocketmonDetails(id: Int) {
    guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)") else {
      print("Invalid URL")
      return
    }
    
    NetworkManager.shared.fetch(url: url)
      .observe(on: MainScheduler.instance)
      .subscribe(
        onSuccess: { [weak self] (response: PocketmonDetailResponse) in
          let pocketmon = Pocketmon(
            id: response.id,
            name: response.name,
            types: response.types.map { $0.type.name },
            height: response.height,
            weight: response.weight
          )
          self?.pocketmonDetailSubject.onNext(pocketmon)
        },
        onError: { error in
          print("Error fetching details: \(error)")
        }
      )
      .disposed(by: disposeBag)
  }
}
