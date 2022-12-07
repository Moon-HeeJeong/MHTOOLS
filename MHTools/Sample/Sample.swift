//
//  Sample.swift
//  MHTools
//
//  Created by LittleFoxiOSDeveloper on 2022/11/16.
//

import Foundation
import Alamofire


//케이스마다 각각 구조체로

struct VersionAPI: MH_APIInfo{
    
    typealias DataType = VersionInfo
    typealias ResponseType = APIResponse<DataType>
    
    var config: MH_APIConfig?
    
    var short: String{
        return "/app/version"
    }
    
    var method: HTTPMethod{
        .post
    }
    
    var parameters: Parameters?{
        var params: Parameters = ["device_id" : self.deviceID]
        if let _ = self.pushID{
            params["push_address"] = self.pushID
        }
        if let _ = self.isPushOn{
            params["is_push_on"] = self.isPushOn == true ? "Y" : "N"
        }
        return params
    }
    
    let deviceID: String
    let pushID: String?
    let isPushOn: Bool?
    
    init(deviceID: String, pushID: String?, isPushOn: Bool?, config: MH_APIConfig? = nil){
        self.deviceID = deviceID
        self.pushID = pushID
        self.isPushOn = isPushOn
        self.config = config
    }
}
struct APIResponse<DataType: Model_P>: Response_P{
    
    var responseType: ResponseType
    var data: DataType?
    
    enum CodingKeys: CodingKey{
        case data
        case status
        case message
    }

    public init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(Int.self, forKey: .status)
        let message = try? container.decode(String.self, forKey: .message)
        
        self.responseType = status == 200 ? .ok(message: message) : .error(code: status, message: message)
        self.data = try? container.decode(DataType.self, forKey: .data)
    }
    
    init(responseType: ResponseType, data: DataType?){
        self.responseType = responseType
        self.data = data
    }
}

class APIConfig: MH_APIConfig{
    var headers: HTTPHeaders?{
        return [
            "api-user-agent" : "LF_APP_iOS:phone/2.7.0/iPhone13,4/iOS:16.0",
            "Authorization" : "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJodHRwczpcL1wvYXBpcy5saXR0bGVmb3guY29tXC9hcGlcL3YxXC9hdXRoXC9tZSIsImlhdCI6MTY3MDI4ODE4NywiZXhwIjoxNjcyODgwMTg3LCJuYmYiOjE2NzAyODgxODcsImp0aSI6InFRVzVNWXpvSzM5QUY1a1YiLCJzdWIiOiJVMjAyMjEwMjYxMTE5ODExODU4IiwicHJ2IjoiMjNiZDVjODk0OWY2MDBhZGIzOWU3MDFjNDAwODcyZGI3YTU5NzZmNyIsImF1dGhfa2V5IjoiMTcwOTMwMDI2MTIwODU2IiwiY3VycmVudF91c2VyX2lkIjoiVTIwMjIxMDI2MTExOTgxMTg1OCIsImV4cGlyZV9kYXRlIjoxNjk4ODkxNjUzfQ.TyXN7_NcTUmW1tmnv8uYAX5dUekiRUwdkqH_ktr5BWYY4h8lXcr9qpABeHjpm6oCRwc0uNY2AhJlGiS5NdhDkg",
            "api-locale" : "ko"
        ]
    }
    var baseURL: String{
        "https://apis.littlefox.com" + "/api/v1"
    }
}

class APITest: MH_API{
    
    var sessionConfig: URLSessionConfiguration? = {
        nil
    }()

    var trustManager: ServerTrustManager? = {
        nil
    }()
    
    lazy var session: Session = {
        if let cofig = self.sessionConfig{
            if let manager = self.trustManager{
                return Session(configuration: cofig, serverTrustManager: manager)
            }else{
                return Session(configuration: cofig)
            }
        }else{
            return Session()
        }
    }()
}


public struct VersionInfo: Model_P{
    static let DefaultMinSupportVerserion: Int = 9
    let installed_version: Int
    let latest_version: String
    let store_url: String
    let is_installed_latest: Bool
    let force_update: Bool
    var isOld: Bool{
        !self.is_installed_latest
    }
}
