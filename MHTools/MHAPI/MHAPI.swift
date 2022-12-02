//
//  MHAPI.swift
//  MHTools
//
//  Created by LittleFoxiOSDeveloper on 2022/11/15.
//

import Foundation
import Alamofire
import RxSwift

public typealias Model_P = Decodable

public protocol MH_APIInfo{
    associatedtype DataType: Model_P
    
    var short: String {get}
    var method: HTTPMethod {get}
    var parameters: Parameters? {get}
    var config: MH_APIConfig? {get set}
}
public extension MH_APIInfo{
  
    var address: String{
        (self.config?.baseURL ?? "") + self.short
    }
}
public protocol MH_APIConfig{
    var headers: HTTPHeaders?{get}
    var baseURL: String{get}
}

public struct MH_Response<DataType: Model_P>: Model_P{
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


public protocol MH_API: AnyObject{
}

public extension MH_API{
    
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
    
    func callByRx<T: MH_APIInfo>(_ api: T) -> Observable<MH_Response<T.DataType>> {
        
        let observable = Observable<MH_Response<T.DataType>>.create { observer in
            let request = AF.request(URL(string: api.address)!, method: api.method, parameters: api.parameters, headers: api.config?.headers).responseData { res in
                if let data = res.value{
                    do{
                        let decodingData = try JSONDecoder().decode(MH_Response<T.DataType>.self, from: data)
                        observer.onNext(decodingData)
                    }catch{
                        observer.onError(APICallError.decodingErr)
                    }
                }else{
                    observer.onError(APICallError.noDataErr)
                }
                observer.onCompleted()
            }
            return Disposables.create {
                request.cancel()
            }
        }
        return observable
    }
}

enum APICallError: Error{
    case decodingErr
    case noDataErr
    
    var desc: String{
        switch self {
        case .decodingErr:
            return "decoding error"
        case .noDataErr:
            return "no data error"
        }
    }
}
