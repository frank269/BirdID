//
//  Constants.swift
//  BirdID
//
//  Created by Tien Doan on 8/26/19.
//  Copyright © 2019 TienDoan. All rights reserved.
//

import Foundation

let KeyApi = "9061f27544ec0703a50aa4a13afc63e73683fece"
let BaseUrl = "http://vnuf.tringhiatech.vn"

func getWoodApi() -> String {
  return BaseUrl + "/wood/" + "index_get?key=" + KeyApi
}

func getBirdApi() -> String {
    return BaseUrl + "/bird/" + "index_get?key=" + KeyApi
}
