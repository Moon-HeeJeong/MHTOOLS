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
    var address: String{
        (self.config?.baseURL ?? "") + self.short
    }
}

/** API CONFIG **/
public protocol MH_APIConfig{
    var headers: HTTPHeaders?{get}
    var baseURL: String{get}
}

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

public protocol MH_API: AnyObject{
    
    var session: Session{get set}
    var trustManager: ServerTrustManager? {get set}
    var sessionConfig: URLSessionConfiguration?{get set}
}

public extension MH_API{
    
    func call<T: MH_APIInfo>(api: T, completed: @escaping (T.ResponseType)->()){
        
        self.session.request(URL(string: api.address)!, method: api.method, parameters: api.parameters, headers: api.config?.headers).responseData { res in
            switch res.result{
            case .success(_):
                if let data = res.value{
                    do{
                        let decodingData = try JSONDecoder().decode(T.ResponseType.self, from: data)
                        if let _ = decodingData.data{
                            completed(decodingData)
                        }else{
                            completed(T.ResponseType(responseType: .error(code: -1, message: "decoding error"), data: nil))
                        }
                    }catch(let e){
                        completed(T.ResponseType(responseType: .error(code: e.asAFError?.responseCode ?? -1, message: e.localizedDescription), data: nil))
                    }
                }else{
                    completed(T.ResponseType(responseType: .error(code: res.error?.responseCode ?? -1, message: res.error?.localizedDescription), data: nil))
                }
                break
            case .failure(_):
                completed(T.ResponseType(responseType: .error(code: res.error?.responseCode ?? -1, message: res.error?.localizedDescription), data: nil))
                break
            }
        }
    }
    
    func callByRx<T: MH_APIInfo, R: Response_P>(_ api: T) -> Observable<R> where T.ResponseType == R {
        
        return Observable<R>.create { observer in
            
            let request = self.session.request(URL(string: api.address)!, method: api.method, parameters: api.parameters, headers: api.config?.headers).responseData { res in
                switch res.result{
                case .success(_):
                    if let data = res.value{
                        do{
                            let decodingData = try JSONDecoder().decode(R.self, from: data)
                            if let _ = decodingData.data{
                                observer.onNext(decodingData)
                            }else{
                                observer.onError(APICallError.decodingErr(code: -1, message: "decoding error"))
                            }
                        }catch(let e){
                            observer.onError(APICallError.decodingErr(code: e.asAFError?.responseCode ?? -1, message: e.localizedDescription))
                        }
                    }else{
                        observer.onError(APICallError.noDataErr(code: res.error?.responseCode ?? -1, message: res.error?.localizedDescription))
                    }
                    break
                case .failure(_):
                    observer.onError(APICallError.networkingErr(code: res.error?.responseCode ?? -1, message: res.error?.localizedDescription))
                    break
                }
                observer.onCompleted()
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

public enum APICallError: Error{
    case decodingErr(code: Int, message: String?)
    case noDataErr(code: Int, message: String?)
    case networkingErr(code: Int, message: String?)
    case etcErr(code: Int, message: String?)
    
    var desc: String?{
        switch self {
        case .decodingErr(_, let message):
            return message
        case .noDataErr(_, let message):
            return message
        case .networkingErr(_, let message):
            return message
        case .etcErr(_, let message):
            return message
        }
    }
    
    var code: Int{
        switch self {
        case .decodingErr(let code, _):
            return code
        case .noDataErr(let code, _):
            return code
        case .networkingErr(let code, _):
            return code
        case .etcErr(let code, _):
            return code
        }
    }
}
