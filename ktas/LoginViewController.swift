//
//  LoginViewController.swift
//  ktas
//
//  Created by JinGu's iMac on 2020/07/09.
//  Copyright © 2020 JinGu's iMac. All rights reserved.
//

import UIKit

let USER_ID = "USER_ID"
var user_id : String {
    get{
        if let value = userD.object(forKey: USER_ID) as? String {
            return value
        }else{
            return ""
        }
    }
}
var isLogin : Bool {
    get{
        if let _ = userD.object(forKey: USER_ID) as? String {
            return true
        }else{
            return false
        }
    }
}
let USER_PW = "USER_PW"
var user_pw : String {
    get{
        if let value = userD.object(forKey: USER_PW) as? String {
            return value
        }else{
            return ""
        }
    }
}
let TEST_CODE = "TEST_CODE"
var test_code : String {
    get{
        if let value = userD.object(forKey: TEST_CODE) as? String {
            return value
        }else{
            return ""
        }
    }
}

let EDU_TYPE = "EDU_TYPE"
var edu_type : String {
    get{
        if let value = userD.object(forKey: EDU_TYPE) as? String {
            return value
        }else{
            return ""
        }
    }
}


class LoginViewController: UIViewController {

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var idInputView : InPutView!
    var pwInputView : InPutView!
    
    var secureView: UIView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Server.sendLog(state: "LoginShow")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //005aaa

        secureView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
        self.view.addSubview(secureView)
        
//        setCapture()
        
//        self.view.makeSecure()
        
        self.view.backgroundColor = #colorLiteral(red: 0, green: 0.3529411765, blue: 0.6666666667, alpha: 1)

        let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN.WIDTH * 0.6, height: 0))
        logoImageView.setImageWithFrameHeight(image: UIImage(named: "login_logo"))
        logoImageView.center.x = SCREEN.WIDTH / 2
        logoImageView.center.y = SCREEN.HEIGHT * 0.2
        secureView.addSubview(logoImageView)

        let loginBox = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN.WIDTH, height: 0))
        self.view.addSubview(loginBox)
        
        let inPutViewHeight : CGFloat = 45
        let inPutViewWidth : CGFloat = SCREEN.WIDTH * 0.85
        
        idInputView = InPutView(
            frame: CGRect(x: 0, y: 0, width: inPutViewWidth, height: inPutViewHeight),
            iconImageName: "login_id", placeHolder: "아이디", isSecure: false)
        idInputView.center.x = SCREEN.WIDTH / 2
        idInputView.textField.delegate = self
        loginBox.addSubview(idInputView)
        
        
        pwInputView = InPutView(
            frame: CGRect(x: 0, y: idInputView.maxY + 20, width: inPutViewWidth, height: inPutViewHeight),
            iconImageName: "login_pw", placeHolder: "비밀번호", isSecure: true)
        pwInputView.center.x = SCREEN.WIDTH / 2
        pwInputView.textField.delegate = self
        loginBox.addSubview(pwInputView)
        
        let loginButton = UIButton(frame: CGRect(x: 0, y: pwInputView.maxY + 20, width: inPutViewWidth, height: inPutViewHeight))
        loginButton.center.x = SCREEN.WIDTH / 2
        loginButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        loginButton.layer.cornerRadius = 5
        loginBox.addSubview(loginButton)
        
        let loginButtonImageView = UIImageView(frame: loginButton.bounds)
        loginButtonImageView.frame.size.height *= 0.4
        loginButtonImageView.setImageWithFrameWidth(image: UIImage(named: "login"))
        loginButtonImageView.center = loginButton.frame.center
        loginButtonImageView.isUserInteractionEnabled = false
        loginButton.addSubview(loginButtonImageView)

        
        loginBox.frame.size.height = loginButton.maxY
        loginBox.center.y = SCREEN.HEIGHT * 0.4
        if IS_IPHONE_X {
            loginBox.center.y = SCREEN.HEIGHT * 0.45
        }
        if IS_IPHONE_N_PLUS {
            loginBox.center.y = SCREEN.HEIGHT * 0.45
        }
        if IS_IPHONE_N {
            loginBox.center.y = SCREEN.HEIGHT * 0.48
        }
        if IS_IPHONE_SE {
            loginBox.center.y = SCREEN.HEIGHT * 0.5
        }
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        
        let versionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: SCREEN.WIDTH, height: 50))
        versionLabel.frame.size.width *= 0.9
        versionLabel.center.x = SCREEN.WIDTH / 2
        versionLabel.frame.origin.y = SCREEN.HEIGHT - SAFE_AREA - versionLabel.height
        versionLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        versionLabel.text = "V \(versionString)"
        versionLabel.font = UIFont(name: NotoSansCJKkr_Regular, size: versionLabel.height * 0.35)
        versionLabel.textAlignment = .right
        self.view.addSubview(versionLabel)
        

//        let hiddenView = UIView(frame: CGRect(x: 0, y: 0, width: versionLabel.frame.size.width, height: versionLabel.frame.size.height))
//        hiddenView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
//        versionLabel.isUserInteractionEnabled = true
//        versionLabel.addSubview(hiddenView)
//
//        let hiddenGesture = UITapGestureRecognizer(target: self, action: #selector(crashTestFunc))
//        hiddenGesture.numberOfTapsRequired = 10
//        hiddenView.addGestureRecognizer(hiddenGesture)
        
        
        
        
    }
    
    
    
//    @objc func crashTestFunc(){
//        print("crashTestFunc")
//        let values = ["A"]
//        print(values[3])
//    }
    
    @objc func loginButtonPressed(){
        print("loginButtonPressed")
        
        
//        //todo remove
//        let vc = ViewController()
//        vc.urlString = "https://www.naver.com"
//        self.navigationController?.pushViewController(vc, animated: true)
//        Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: {_ in
//            vc.bottomViewChange(isOn: true)
//            vc.bottomView.clockLabel.text = "\(1_000_000)"
//        })
//        
//        return
        
        let id = idInputView.textField.text ?? ""
        let pw = pwInputView.textField.text ?? ""
        
        if id.replacingOccurrences(of: " ", with: "") == "" {
            appDel.showAlert(title: "안내", message: "아이디를 입력해주세요")
            return
        }
        if pw.replacingOccurrences(of: " ", with: "") == "" {
            appDel.showAlert(title: "안내", message: "비밀번호를 입력해주세요")
            return
        }
        
        let urlString = "http://ktas.org/app/php/login_proc.php"
        let para = [
            "user_id":id,
            "passwd":pw,
            "deviceid":deviceID,
            "device":osString,
            "app_ver":versionString
        ]
        print("login para:\(para)")
        appDel.showHud()
        let request = Server.postData(urlString: urlString, method: .post, otherInfo: para) { (kData : Data?) in
            appDel.hideHud()
            if let data = kData {
                if let dataString = data.toString() {
                    print("login dataString:\(dataString)")
                }
                
                if let dataDic = data.toJson() as? [String:Any] {
                    print("login dataDic:\(dataDic)")
                    if let success = dataDic["success"] as? String {
                        if success.lowercased() == "y" {
                            userD.set(id, forKey: USER_ID)
                            userD.set(pw, forKey: USER_PW)
                            if let kTest_code = dataDic["test_code"] as? String {
                                if test_code != kTest_code {
                                    print("testCode가 달라졌기 때문에 카운트다운 리셋")
                                    limit_time = nil
                                }
                                userD.set(kTest_code, forKey: TEST_CODE)
                                userD.synchronize()
                            }
                            if let kEdu_type = dataDic["edu_type"] as? String {
                                userD.set(kEdu_type, forKey: EDU_TYPE)
                                userD.synchronize()
                            }
                            
                            if let url = dataDic["url"] as? String {
                                let vc = ViewController()
                                vc.urlString = url
                                
                                if let base_limit_time = readIntValueOfDic(dataDic: dataDic, key: "base_limit_time") {
                                    //base_limit_time이 있다는거는 바로 시험으로 진입한다는 뜻이다
                                    //시험 도중에 재 입장한 경우이며 사실상 저장된 limitTime이 사용되어야 한다
                                    //시홈 도중 재 입장 여부를 판단하기만 한다
                                    if limit_time == nil {
                                        print("limit_time이 nil인 경우 - 이 경우가 있을까?")
                                    }
                                    print("limit_time:\(limit_time)")
                                    vc.startBaseTime = limit_time ?? base_limit_time //not nilable하기 위한 처리
                                }
                                
                                self.sendNetworkState()
                                
                                if NetworkManager.shared.status == .ethernetOrWiFi {
                                    let alertMessage = """
                                    현재 WIFI로 접속하셨습니다.
                                    LTE, 5G 로 접속하지 않을 시 시험이 종료되지 않을 수 있습니다.

                                    시험 미완료로 인한 불합격은 본인의 책임입니다
                                    """
                                    appDel.showAlert(title: "안내", message: alertMessage, actions: [UIAlertAction(title: "확인", style: .default, handler: { (action : UIAlertAction) in
                                        DispatchQueue.main.async {
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                    })]) {
                                        
                                    }
                                }else{
                                    DispatchQueue.main.async {
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                                
                                return
                            }
                            
                        }else{
                            if let kMsg = dataDic["msg"] as? String {
                                appDel.showAlert(title: "안내", message: kMsg)
                                return
                            }
                        }
                    }
                }
            }
            appDel.showAlert(title: "안내", message: "통신이 원활하지 않습니다.\n잠시 후 다시 시도해주세요.")
        }
//        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer : Timer) in
//            request?.cancel()
//            appDel.hideHud()
//        }
        
        
    }
    
//    func setCapture(){
//        
//        NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: nil) { (fi) in
//            self.didCapture()
//            
//        }
//    }
//    func didCapture(){
//        
//        print("캡쳐")
//        let urlString = "http://ktas.org/app/php/online/capture_reg.php"
//        let para = [
//            
//            "deviceid":deviceID,
//            "test_code":test_code,
//            "edu_type":edu_type,
//            "capture_time":"\(Int(Date().timeIntervalSince1970))",
//            "type":"C",
//            "device":osString,
//            "app_ver":versionString
//        ]
//        print("didCapture")
//        print("urlString : \(urlString)")
//        print("para:\(para)")
//        let _ = Server.postData(urlString: urlString, method: .post, otherInfo: para) { (kData : Data?) in
//            if let data = kData {
//                if let dataString = data.toString() {
//                    print("dataString : \(dataString)")
//                }
//            }
//        }
//    }
    
    func sendNetworkState(){
        let urlString = "http://ktas.org/app/php/login_network_reg.php"
        
        let type = NetworkManager.shared.status == .ethernetOrWiFi ? "1":"2"
        let para = [
            "test_code":test_code,
            "edu_type":edu_type,
            "deviceid":deviceID,
            "device":osString,
            "type":type,
            "app_ver":versionString
        ]
        print("sendNetworkState urlString:\(urlString)")
        print("sendNetworkState para:\(para)")
        Server.postData(urlString: urlString, method: .post, otherInfo: para) { (kData : Data?) in
            if let data = kData {
                if let dataString = data.toString() {
                    print("dataString:\(dataString)")
                }
                
            }
        }
    }
   


    class InPutView : UIView {
        
        var textField : UITextField!
        
        init(frame: CGRect, iconImageName : String, placeHolder : String, isSecure : Bool) {
            super.init(frame: frame)
            
            self.backgroundColor = #colorLiteral(red: 0, green: 0.2392156863, blue: 0.4549019608, alpha: 1)
            self.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
            self.layer.borderWidth = 1.5
            self.layer.cornerRadius = 5
            
            let iconBackView = UIView(frame: CGRect(x: 0, y: 0, width: self.height, height: self.height))
            self.addSubview(iconBackView)
            
            let iconImageViewRatio : CGFloat = 0.55
            let iconImageView = UIImageView(frame: iconBackView.bounds)
            iconImageView.frame.size.width *= iconImageViewRatio
            iconImageView.setImageWithFrameHeight(image: UIImage(named: iconImageName))
            iconImageView.center = iconBackView.frame.center
            iconBackView.addSubview(iconImageView)
            
            textField = UITextField(frame: CGRect(x: iconBackView.maxX, y: 0, width: self.width - (iconBackView.maxX) - 10, height: self.height))
            textField.addDoneCancelToolbar()
            textField.placeholder = placeHolder
            textField.font = UIFont(name: NotoSansCJKkr_Regular, size: textField.height * 0.35)
            textField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            textField.isSecureTextEntry = isSecure
            textField.attributedPlaceholder = NSAttributedString(
                string: placeHolder,
                attributes: [
                NSAttributedString.Key.font : UIFont(name: NotoSansCJKkr_Regular, size: textField.height * 0.35)!,
                NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            ])
            self.addSubview(textField)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}
