//
//  MH_APIConfig.swift
//  MHTools
//
//  Created by LittleFoxiOSDeveloper on 2023/01/18.
//

import Foundation
import Alamofire
import RxSwift

/** API CONFIG **/
public protocol MH_APIConfig{
    var headers: HTTPHeaders?{get}
    var baseURL: String{get}
}
