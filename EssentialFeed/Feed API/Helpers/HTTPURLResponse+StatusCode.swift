//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi - Home on 07/06/21.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOk: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
