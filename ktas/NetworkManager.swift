//
//  dd.swift
//  ktas
//
//  Created by JinGu's iMac on 2020/07/23.
//  Copyright © 2020 JinGu's iMac. All rights reserved.
//

import UIKit
import Alamofire

class NetworkManager {
    
    //shared instance
    static let shared = NetworkManager()
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager()
    
    enum NetworkReachabilityStatus {
        case notReachable
        case unknown
        case ethernetOrWiFi
        case wwan
    }
    
    var status : NetworkReachabilityStatus = .unknown
    
    func startNetworkReachabilityObserver() {
        
        reachabilityManager?.listener = { status in
            switch status {
                
            case .notReachable:
                self.status = .notReachable
                print("The network is not reachable")
                
            case .unknown :
                self.status = .unknown
                print("It is unknown whether the network is reachable")
                
            case .reachable(.ethernetOrWiFi):
                self.status = .ethernetOrWiFi
                print("The network is reachable over the WiFi connection")
                
            case .reachable(.wwan):
                self.status = .wwan
                print("The network is reachable over the WWAN connection")
                
            }
        }
        
        // start listening
        reachabilityManager?.startListening()
    }
}
