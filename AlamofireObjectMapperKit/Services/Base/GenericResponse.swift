//
//  GenericResponse.swift
//  AlamofireObjectMapperKit
//
//  Created by David Bala on 10/09/2018.
//  Copyright © 2018 AXNET. All rights reserved.
//

import ObjectMapper

class GenericResponse: Mappable {
    
    var message: ErrorMesssages?
    var documentationUrl: URL?
    
    required init?(map: Map) {}
    
    // Mappable
    func mapping(map: Map) {
        documentationUrl    <- (map["documentation_url"], URLTransform())
        message             <- (map["message"], EnumTransform<ErrorMesssages>())
    }
}
