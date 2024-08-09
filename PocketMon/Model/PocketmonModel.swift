//
//  pocketmonImage.swift
//  Pocketmon
//
//  Created by t2023-m0102 on 8/7/24.
//

import Foundation

// 포켓몬 리스트 응답 모델
struct PocketmonListResponse: Codable {
  let results: [PocketmonListResult]
}

struct PocketmonListResult: Codable {
  let name: String
  let url: String
  
  var pocketmonID: Int? {
    // URL에서 ID 추출
    let components = url.split(separator: "/")
    if let lastComponent = components.last, let id = Int(lastComponent) {
      return id
    }
    return nil
  }
}

// 포켓몬 상세 응답 모델
struct PocketmonDetailResponse: Codable {
  let id: Int
  let name: String
  let types: [PokemonType]
  let height: Float
  let weight: Float
  
  struct PokemonType: Codable {
    let type: TypeDetail
    
    struct TypeDetail: Codable {
      let name: String
    }
  }
}


// Pocketmon 모델 (사용자 정의)
struct Pocketmon {
  let id: Int
  let name: String
  let imageUrl: String? // 일반적인 프로퍼티로 변경
  let types: [String]?
  let height: Float?
  let weight: Float?
  
  // 초기화 메서드
  init(id: Int, name: String, imageUrl: String? = nil, types: [String]? = nil, height: Float? = nil, weight: Float? = nil) {
    self.id = id
    self.name = name
    self.imageUrl = imageUrl
    self.types = types
    self.height = height
    self.weight = weight
  }
}
