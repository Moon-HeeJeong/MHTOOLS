//
//  Response.swift
//  MHTools
//
//  Created by LittleFoxiOSDeveloper on 2023/01/18.
//

import Foundation
import Alamofire
import RxSwift

/** Response **/
public protocol Response_P: Model_P{
    associatedtype DataType: Model_P
    
    var responseType: ResponseType {get set}
    var data: DataType? {get set}
    
    init(responseType: ResponseType, data: DataType?)
}

public enum ResponseType{
    case ok(message: String?)
    case error(code: Int, message: String?)
    
    var message: String?{
        switch self {
        case .ok(let message):
            return message
        case .error(_, let message):
            return message
        }
    }
}
