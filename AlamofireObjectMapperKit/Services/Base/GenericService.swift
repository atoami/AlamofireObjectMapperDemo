//
//  GenericService.swift
//  AlamofireObjectMapperKit
//
//  Created by David Bala on 09/09/2018.
//  Copyright © 2018 AXNET. All rights reserved.
//

import Alamofire
import PromiseKit
import SwiftyJSON
import ObjectMapper

class Servers {
    static let Github = "https://api.github.com"
}

enum ErrorMesssages: String {
    case NotFound = "Not Found"
}

class GenericService {
    
    /**
     Headers to be attached to api calls.
     Include access token if user was authenticated.
     */
    var headers: HTTPHeaders {
        get {
            var headers: HTTPHeaders = ["Content-Type": "application/json"]
            // if let token = AuthManager.shared.getAccessToken() {
            //    headers["Authorization"] = "Bearer " + token
            // }
            return headers
        }
    }
    
    /**
     Send api request
     Use class templates inherited by ObjectMapper to parse json responses into Swift objects.
     It makes code more robust and modular.
     - SeeAlso: ObjectMapper(https://github.com/Hearst-DD/ObjectMapper)
     */
    func sendRequest<T: Mappable>(_ url: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, headers: HTTPHeaders? = nil, responseObject: T.Type) -> Promise<T> {
        
        debugPrint("path = \(url)")
        
        // Show network indicator on status bar
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        return Promise { resolve, reject in
            Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
                .responseJSON() { response in
                    // Hide network indicator on status bar
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    switch response.result {
                    case .success(let data):
                        var json = JSON()
                        if let jsonArray = JSON(data as Any).array {
                            json["list"].arrayObject = jsonArray
                        } else {
                            json = JSON(data as Any)
                        }
                        debugPrint(json)
                        let mappableObject = Mapper<T>().map(JSONObject: json.object)
                        let genericResObj = mappableObject as? GenericResponse
                        if genericResObj?.message == ErrorMesssages.NotFound {
                            reject(self.generateError(code: 0, message: genericResObj?.message?.rawValue))
                        } else {
                            resolve(mappableObject!)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    
    /**
     If you need JSON response data, use this method
     */
    func sendRequest(_ url: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, headers: HTTPHeaders? = nil) -> Promise<Any> {
        
        return Promise { resolve, reject in
            Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
                .responseJSON() { response in
                    switch response.result {
                    case .success(let data):
                        resolve(data as Any)
                    case .failure(_):
                        reject(self.generateError(code: 0, message: nil))
                    }
            }
        }
    }
    
    func generateError(code: Int, message: String?) -> NSError {
        let errorTag = "Error"
        let errorMsg: String = message != nil ? message! : "Try again?"
        return NSError(domain: "", code: code, userInfo: ["__type": errorTag, "message": errorMsg])
    }
}

