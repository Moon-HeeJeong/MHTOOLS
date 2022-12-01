//
//  MHAPI.swift
//  MHTools
//
//  Created by LittleFoxiOSDeveloper on 2022/11/15.
//

import Foundation
import Alamofire


typealias Model_P = Decodable

protocol MH_APIInfo{
    associatedtype DataType: Model_P
    
    var short: String {get}
    var method: HTTPMethod {get}
    var parameters: Parameters? {get}
    var config: MH_APIConfig? {get set}
}
extension MH_APIInfo{
  
    var address: String{
        (self.config?.baseURL ?? "") + self.short
    }
}
protocol MH_APIConfig{
    var headers: HTTPHeaders?{get}
    var baseURL: String{get}
}

struct MH_Response<DataType: Model_P>: Model_P{
    var responseType: Bool
    var data: DataType?
    
    enum CodingKeys: CodingKey{
        case data
        case status
        case message
    }
    public init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(Int.self, forKey: .status)
        self.responseType = status == 200 ? true : false
        self.data = try? container.decode(DataType.self, forKey: .data)
    }
}


protocol MH_API: AnyObject{
}

extension MH_API{
    func call<T: MH_APIInfo>(api: T, completed: @escaping (MH_Response<T.DataType>?)->()){
        
        AF.request(URL(string: api.address)!, method: api.method, parameters: api.parameters, headers: api.config?.headers).responseData { res in
            if let data = res.value{
                do{
                    let decodingData = try JSONDecoder().decode(MH_Response<T.DataType>.self, from: data)
                    completed(decodingData)
                }catch{
                    completed(nil)
                }
            }else{
                completed(nil)
            }
        }
    }
}
