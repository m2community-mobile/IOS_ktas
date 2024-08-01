/*

 inhibit_all_warnings!
 
 pod 'Alamofire', '~> 4.7'
 
 
 */
import UIKit
import Alamofire

class Server: NSObject {
    
  
    static func postData(urlString:String, method : HTTPMethod = .post, otherInfo : [String:String]? = nil, headers : [String: String]? = nil, completion : @escaping ( _ data  : Data? ) -> Void) -> DataRequest? {
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) else {
            completion(nil)
            return nil
        }
        
        let request = Alamofire.request(url, method: method, parameters: otherInfo, headers: headers).responseData { (dataResponse:DataResponse) in
            if let error = dataResponse.error {
                print("1")
                print("error1 : \(error.localizedDescription)")
                completion(nil)
            }else{
                if dataResponse.response?.statusCode == 200 {
                    completion(dataResponse.data)
                } else if dataResponse.response?.statusCode == 300 {
                    print("error123")
                } else if dataResponse.response?.statusCode == 400 {
                    print("error456")
                } else if dataResponse.response?.statusCode == 500 {
                    print("error789")
                } else{
                    print("error123")
                    print("httpStatusCode \(String(describing: dataResponse.response?.statusCode))")
                    completion(nil)
                }
            }
            print("2")
        }
        
        return request
    }
    
    static func sendLogTest(key : String) {
        let urlString = "https://ezv.kr:4447/voting/php/ipad/setState.php"
        let kDeviceID = UUID().uuidString.replacingOccurrences(of: "-", with: "")

        let dataDic = [
            "deviceid":kDeviceID,
            "deviceName":key
        ]
        print("\(key)")
        Server.postData(urlString: urlString, otherInfo: dataDic) { (kData : Data?) in
            if let data = kData {
                if let dataString = data.toString() {
                    print("sendLogTest:\(dataString)")
                }
            }
        }
        
        
    }
    
    static func sendLog(state:String) {
        
        let urlString = "http://ktas.org/app/php/online/log.php"

        let dataDic = [
            "deviceid":deviceID,
            "device":osString,
            "app_ver":versionString,
            "state":state
        ]
        print("sendLog:\(state)")
//        let _ = Server.postData(urlString: urlString, otherInfo: dataDic) { (kData : Data?) in
        let _ = ServerCenter.shared.backgroundPostData(urlString: urlString, method: .post, otherInfo: dataDic) { (kData : Data?) in
            if let data = kData {
                if let dataString = data.toString() {
                    print("return sendLog \(state) : \(dataString)")
                }
            }
        }
    }
    
}

class ServerCenter: NSObject, URLSessionDelegate {
   
    static let shared : ServerCenter = {
        let sharedCenter = ServerCenter()
        return sharedCenter
    }()

    var sessionManager : SessionManager?
    
    func backgroundPostData(urlString:String, method : HTTPMethod = .post, otherInfo : [String:String]? = nil, completion : @escaping ( _ data  : Data? ) -> Void) -> DataRequest? {
        
        print("postData:\(urlString)")
        guard let url = URL(string: urlString) else {
            completion(nil)
            return nil
        }
        
        // Background Session: 앱이 종료된 이후에도 통신이 이뤄지는 것을 지원하는 세션입니다.
        if self.sessionManager == nil {
            let configuration = URLSessionConfiguration.background(withIdentifier: "ktasExam.background")
            self.sessionManager = Alamofire.SessionManager(configuration: configuration)
        }
        
        let request = self.sessionManager!.request(url, method: method, parameters: otherInfo).responseData { (dataResponse:DataResponse) in
            if let error = dataResponse.error {
                print("error2: \(error.localizedDescription)")
                completion(nil)
            }else{
                if dataResponse.response?.statusCode == 200 {
                    completion(dataResponse.data)
                }else{
                    print("httpStatusCode \(String(describing: dataResponse.response?.statusCode))")
                    completion(nil)
                }
            }
        }
        return request
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("urlSessionDidFinishEvents")
        
        if let handler = appDel.backgroundSessionCompletionHandler {
            print("handler is not nil")
            appDel.backgroundSessionCompletionHandler = nil
            handler()
        }else{
            print("handler is nil")
        }
    }
}

