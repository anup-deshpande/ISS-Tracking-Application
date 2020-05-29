//
//  NetworkManager.swift
//  ISS-Tracking-Application
//
//  Created by Anup Deshpande on 5/19/20.
//  Copyright © 2020 Anup Deshpande. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct location{
    var lat: String
    var long: String
}

class NetworkManager{
    //singleton
    static let instance: NetworkManager = NetworkManager()
    
    func getIssCurrentLocation(_ success: @escaping (location) -> Void, _ failure: @escaping (String) -> Void) {
        AF.request("http://api.open-notify.org/iss-now.json", method: .get, parameters: nil , encoding:  URLEncoding.httpBody, headers: nil).responseJSON { (response) in
            
            switch response.result{
            case .success(let value):
                let data = JSON(value)
                let locationObject = data["iss_position"]
                let loc = location(lat: locationObject["latitude"].stringValue, long: locationObject["longitude"].stringValue)
                success(loc)
                break
                
            case .failure(let error):
                failure(error.errorDescription!)
                break
            }
        }

    }
    
    func getIssPassTime(latitude lat: Double, longitude long: Double, _ success: @escaping ([String]) -> Void, _ failure: @escaping (String) -> Void) {
        let url =  "http://api.open-notify.org/iss-pass.json?lat=\(lat)&lon=\(long)"
        AF.request(url, method: .get, encoding:  URLEncoding.httpBody, headers: nil).responseJSON { (response) in
            switch response.result{
            
            case .success(let value):
                var result = [String]()
                let data = JSON(value)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM-dd-YYYY HH:MM"
                
                for (_, object) in data["response"] {
                    if let risetime = object["risetime"].double{
                        let date = dateFormatter.string(from: Date(timeIntervalSince1970: risetime))
                        result.append(date)
                    }
                }
                
                success(result)
                break
                
            case .failure(let error):
                failure(error.errorDescription!)
                break
            }
            
        }
    }
}
