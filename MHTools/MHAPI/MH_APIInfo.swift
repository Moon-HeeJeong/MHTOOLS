//
//  MH_APIInfo.swift
//  MHTools
//
//  Created by LittleFoxiOSDeveloper on 2023/01/18.
//

import Foundation
import Alamofire
import RxSwift

/** API INFO **/
public protocol MH_APIInfo{
    associatedtype DataType: Model_P
    associatedtype ResponseType: Response_P
    
    var short: String {get}
    var method: HTTPMethod {get}
    var parameters: Parameters? {get}
    var config: MH_APIConfig? {get set}
}
public extension MH_APIInfo{
//    var address: String{
//        (self.config?.baseURL ?? "") + self.short
//    }
    var address: String{
        if method == .get { //get의 
            return (self.config?.baseURL ?? "") + self.short + (self.parameters?.query ?? "")
        }else{
            return (self.config?.baseURL ?? "") + self.short
        }
    }
}

extension Dictionary{
    var query: String{
        if(count == 0){
            return ""
        }
        let params = self
        let urlParams = params.compactMap({ (key, value) -> String in
                    "\(key)=\(value)"
        }).joined(separator: "&")
        var urlString = "?" + urlParams
        if let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            urlString = url
        }
        return urlString
    }
}
