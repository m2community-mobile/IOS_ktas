//
//  ViewController.swift
//  ktas
//
//  Created by JinGu's iMac on 2020/07/07.
//  Copyright © 2020 JinGu's iMac. All rights reserved.
//

import UIKit
import WebKit
import FontAwesome_swift

let LIMIT_TIME_KEY = "LIMIT_TIME_KEY"
var limit_time : Int? {
    get{
        return userD.object(forKey: LIMIT_TIME_KEY) as? Int
    }
    set(value){
        userD.set(value, forKey: LIMIT_TIME_KEY)
        userD.synchronize()
    }
}

class ViewController: UIViewController
    ,WKNavigationDelegate , WKUIDelegate
{
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    var wkWebView : WKWebView!
    var urlString = "http://ktas.org/app/php/"
    var currentUrl = ""
    
    var bottomBackView : UIView!
    var bottomView : BottomView!
    
    var startBaseTime : Int?
    var refreshButton : ImageButton!
    
    
//    var secureView : UIView!

    /*
     currentAnswer가 0일때는 답을 선택하지 않았다는 뜻
     ktas.org/app/php/online/page.php가 호출되면 currentAnswer는 초기화되어야 한다
     currentPage도 0에서 시작되고 ktas.org/app/php/online/page.php때 저장하면 된다
     타이머가 다 되서 post 제출을 할때 둘 다 초기화
     */
    var currentAnswer = 0
    var currentPage = 0
    
    var currentLimitTime : Int = 0
    
    var currentCycle = 0
    
//    var progressBar : UIView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        let bottomViewHeight : CGFloat = 50
        bottomBackView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN.WIDTH, height: bottomViewHeight + SAFE_AREA))
        bottomBackView.frame.origin.y = SCREEN.HEIGHT - bottomBackView.height
        bottomBackView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.6887907982, blue: 0.6862745098, alpha: 1)

        
        self.view.addSubview(bottomBackView)
        
        
        bottomView = BottomView(frame: CGRect(x: 0, y: 0, width: SCREEN.WIDTH, height: bottomViewHeight))
        bottomBackView.addSubview(bottomView)
        bottomView.submitButton.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        

        
        
        let webViewFrame = CGRect(x: 0, y: STATUS_BAR_HEIGHT, width: SCREEN.WIDTH, height: bottomBackView.minY - STATUS_BAR_HEIGHT)
//        let webViewFrame = CGRect(x: 0, y: 0, width: SCREEN.WIDTH, height: bottomBackView.minY)
        self.wkWebView = WKWebView(frame: webViewFrame)
        self.wkWebView.allowsLinkPreview = false
        self.wkWebView.uiDelegate = self
        self.wkWebView.navigationDelegate = self
        self.wkWebView.scrollView.bounces = false
        self.wkWebView.scrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(self.wkWebView)
        
        refreshButton = ImageButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50), image: UIImage.fontAwesomeIcon(name: FontAwesome.redoAlt, style: .solid, textColor: UIColor.systemGray, size: CGSize(width: 50, height: 50)), ratio: 0.7)
        refreshButton.frame.origin.y = self.wkWebView.frame.maxY - 50
        refreshButton.addTarget(self, action: #selector(refreshButtonPressed), for: .touchUpInside)
        refreshButton.layer.zPosition = 999
        
        self.view.addSubview(refreshButton)
//        refreshButton.alpha = 0 //todo remove
//        refreshButton.backgroundColor = .white
//        refreshButton.tintColor = .yellow
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (noti : Notification) in
            if self.wkWebView.scrollView.contentOffset.y > self.wkWebView.scrollView.contentSize.height - self.wkWebView.scrollView.frame.size.height  {
                print("해당됨")
                self.wkWebView.scrollView.setContentOffset(CGPoint(x: 0, y: self.wkWebView.scrollView.contentSize.height - self.wkWebView.scrollView.frame.size.height), animated: true)
            }
        }
        
        
        
        setCapture()
      
        
        
        appDel.recodingBlackView.isHidden = !UIScreen.main.isCaptured
        if UIScreen.main.isCaptured {
            
            print("이미 녹화중")
            self.didStartingRecode()
        }
        
        if let startBaseTimestartBaseTime = self.startBaseTime {
            print("시험 도중에 다시 로그인하였을때 (사실상 startBaseTime은 저장된 limitTime이어야 한다)")
            
            
            print("startBaseTime:\(startBaseTime)")
            self.currentLimitTime = startBaseTime!
            self.bottomViewChange(isOn: true)
            self.bottomView.clockLabel.text = "\(self.currentLimitTime)"
            self.startBaseTime = nil
        }else{
            print("처음 로그인이라 동의화면을 거칠때")
            self.bottomViewChange(isOn: false)
        }
        
//        if limit_time! <= 50 {
//            
//            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
//                DispatchQueue.main.async {
//                    self?.bottomView.submitButtonImageView.isHidden.toggle()
//                }
//            }
//            
//        }
        
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        
        
        self.reloading()
        
        
        
        
//        progressBar = UIView(frame: CGRect(x: 0, y: wkWebView.frame.origin.y, width: SCREEN.WIDTH * 0.05, height:2.5))
//        progressBar.backgroundColor = UIColor.systemGray
//        self.view.addSubview(progressBar)
        

        wkWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        wkWebView.makeSecure()
        
        		
        
      
        
    }
    
    
    

    
    var hud : MBProgressHUD?
    
    @objc func updateCounter() {
        
        //example functionality
        
        
        if limit_time == nil {
            self.bottomView.submitButton.isEnabled = true
            
            self.bottomView.submitButton.isHidden = false
            
            self.bottomView.submitButtonImageView.setImageWithFrameWidth(image: UIImage(named: "submit"))
            self.bottomView.submitButtonImageView.isHidden = false
        } else if limit_time! <= 0 {
            
            self.bottomView.submitButton.isHidden = true
            
//            self.bottomView.submitButtonImageView.isHidden.toggle()
            self.bottomView.submitButtonImageView.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.bottomView.submitButton.isEnabled = false
                
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                            self.bottomView.submitButton.isEnabled = true
//                self.bottomView.submitButton.isHidden = false
//                            self.bottomView.submitButtonImageView.setImageWithFrameWidth(image: UIImage(named: "submit"))
//                            self.bottomView.submitButtonImageView.isHidden = false
//                        }
        }
//        else {
//            self.bottomView.submitButton.isEnabled = true
//            self.bottomView.submitButtonImageView.isHidden = false
//        }
    }
    func progressHud() -> MBProgressHUD {
        if hud == nil {
            hud = MBProgressHUD.showAdded(to: self.wkWebView, animated: true)
            hud?.mode = .annularDeterminate
            hud?.button.setTitle("새로고침", for: .normal)
            hud?.detailsLabel.text = "Loading..."
        
            hud?.button.addTarget(self, action: #selector(refreshButtonPressed), for: .touchUpInside)
//            hud?.button.addTarget(event: .touchUpInside, buttonAction: { [weak self] _ in
//                guard let self = self else { return }
//                self.refreshButtonPressed()
//            })
        }
        return self.hud!
    }
    
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        
//        if limit_time! <= 50 {
//            
//            bottomView.submitButtonImageView.layoutIfNeeded()
//            
//            
////            bottomView.submitButtonImageView.setImageWithFrameWidth(image: UIImage(named: ""))
//            bottomView.submitButtonImageView.isHidden = true
//        } else {
//            
//            bottomView.submitButtonImageView.layoutIfNeeded()
//            bottomView.submitButtonImageView.isHidden = false
//        }
//        
//    }
    
    
    @objc func refreshButtonPressed(){
        print("check:refreshButtonPressed")
        if currentUrl.contains("end.php")
            || currentUrl.contains("set_session.php")
            || currentUrl.contains("stand_by.php")
            || currentUrl.contains("start.php")
            || currentUrl.contains("survey_proc.php")
            || currentUrl.contains("survey.php")
            || currentUrl.contains("finish.php")
            || currentUrl.contains("logout_proc.php")
            || currentUrl.contains("login.php")
        {
            self.urlString = currentUrl
            self.reloadingCurrent()
            return
            
        }
        self.reloading()
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        print("keyPath:\(keyPath)")
        if keyPath == "estimatedProgress" {
            
            let percentValue = Int(self.wkWebView.estimatedProgress * 100)
            let progressValue = Float(self.wkWebView.estimatedProgress)
            print("check===:\(percentValue)")
            let progressHud = self.progressHud()
            progressHud.label.text = "\(percentValue)%"
            progressHud.progress = Float(progressValue)
            
//            UIView.animate(withDuration: 0.1) {
//                self.progressBar.frame.size.width = CGFloat(self.wkWebView.estimatedProgress) * SCREEN.WIDTH
//            }
            
        }
    }

    
    
    func bottomViewChange(isOn : Bool) {
        if isOn {
            self.bottomBackView.isHidden = false
            self.wkWebView.frame = CGRect(x: 0, y: STATUS_BAR_HEIGHT, width: SCREEN.WIDTH, height: bottomBackView.minY - STATUS_BAR_HEIGHT)
            refreshButton.frame.origin.y = self.wkWebView.frame.maxY - 50
        }else{
            self.bottomBackView.isHidden = true
            self.wkWebView.frame = CGRect(x: 0, y: STATUS_BAR_HEIGHT, width: SCREEN.WIDTH, height: SCREEN.HEIGHT - STATUS_BAR_HEIGHT - SAFE_AREA)
            refreshButton.frame.origin.y = self.wkWebView.frame.maxY - 50
        }
        
    }
    
    
    func reloading(){

        print("check:reloading:\(self.urlString)")
        var newURLString = self.urlString.addParameterToURLString(key: "deviceid", value: deviceID)
        newURLString = newURLString.addParameterToURLString(key: "device", value: osString)
        newURLString = newURLString.addParameterToURLString(key: "test_code", value: test_code)
        newURLString = newURLString.addParameterToURLString(key: "edu_type", value: edu_type)
        newURLString = newURLString.addPercenterEncoding()
        print("check:newURLString:\(newURLString)")
        if let url = URL(string: newURLString) {
            let request = URLRequest(url: url)
            self.wkWebView.load(request)
        }else{
            print("urlErro : \(newURLString)")
            toastShow(message: "인터넷 연결을 확인하세요.")
        }
    }
    func reloadingCurrent(){

        print("check:reloadingCurrent:\(self.urlString)")
        var newURLString = self.urlString
//            .addParameterToURLString(key: "deviceid", value: deviceID)
//        newURLString = newURLString.addParameterToURLString(key: "device", value: osString)
//        newURLString = newURLString.addParameterToURLString(key: "test_code", value: test_code)
//        newURLString = newURLString.addParameterToURLString(key: "edu_type", value: edu_type)
//        newURLString = newURLString.addPercenterEncoding()
        print("check:reloadingCurrent:newURLString:\(newURLString)")
        if let url = URL(string: newURLString) {
            let request = URLRequest(url: url)
            self.wkWebView.load(request)
        }else{
            print("urlErro : \(newURLString)")
            toastShow(message: "인터넷 연결을 확인하세요.")
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        print("createWebViewWith:\(String(describing: navigationAction.request.url?.absoluteString))")
        if let absoluteString = navigationAction.request.url?.absoluteString {
            self.urlString = absoluteString
            self.reloading()
        }
        
        return nil
    }
    
    //MARK:WKUIDelegate
    var confirmPanelValue = 0
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
//        appDel.showAlert(title: "안내", message: message)
        print("runJavaScriptConfirmPanelWithMessage : \(message)")
        
        
        self.confirmPanelValue = 0
        
        let alertCon = UIAlertController(title: "안내", message: message, preferredStyle: UIAlertController.Style.alert)
        alertCon.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { (action) in
            self.confirmPanelValue = 1
        }))
        alertCon.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: { (action) in
            self.confirmPanelValue = 2
        }))
        self.present(alertCon, animated: true, completion: {})
        
        while confirmPanelValue == 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
        }
        
        if confirmPanelValue == 1 {
            completionHandler(true)
        }else{
            completionHandler(false)
        }
        
        
//        completionHandler(true)
    }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        print("runJavaScriptAlertPanelWithMessage:\(message)")
        
        /*
         현재 문제번호와 매칭하여 답을 저장하고 있어야 함
         시간이 모두 흘렀을때 이 데이터를 기반으로 제출
        */
        if message.contains("**") {
            let removeKeyWord = message.replacingOccurrences(of: "**", with: "")
            if let page = Int(removeKeyWord, radix: 10) {
                jump(page: page)
                completionHandler()
                return
            }
        }
        
        if let answer = message.toInt() {
            print("self.currentAnswer : \(answer)")
            self.currentAnswer = answer
        }else{
            appDel.showAlert(title: "안내", message: message)
        }
        

        
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        print("runJavaScriptTextInputPanelWithPrompt:\nprompt : \(prompt)\n defaultText: \(String(describing: defaultText))")
        completionHandler(nil)
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void){
        
        print("navigationAction.request.url?.absoluteString : \(String(describing: navigationAction.request.url?.absoluteString))")
        print("osString:\(osString)")
        if let absoluteString = navigationAction.request.url?.absoluteString {
            
            self.currentUrl = absoluteString
            
            if absoluteString.contains("login.php") {
                
                limit_time = nil
                self.timer?.invalidate()
                self.navigationController?.popViewController(animated: true)
                
                decisionHandler(.cancel)
                return
            }
            
            if absoluteString.contains("start.php") {
                
                self.setStart()
                
                decisionHandler(.cancel)
                return
            }
            
            if absoluteString.contains("agree.php") {
                limit_time = nil
            }
            
            if absoluteString.contains("end.php") {
                limit_time = nil
                self.timer?.invalidate()
                self.bottomView.clockLabel.text = ""
                self.bottomViewChange(isOn: false)
            }
            
            if absoluteString.contains("fail.php") {
                print("여기가 들어올텐데")
//                limit_time = nil
//                self.timer?.invalidate()
//                self.bottomView.clockLabel.text = ""
//                self.bottomViewChange(isOn: false)
                
                limit_time = nil
                self.timer?.invalidate()
                
                
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                    DispatchQueue.main.async {
                        appDel.naviCon?.popViewController(animated: true)
                    }
                }
                
                
                
                decisionHandler(.cancel)
                return
            }
            
            
//            http://ktas.org/app/php/online/page.php?limit_time=30&user_page=2
            if absoluteString.contains("page.php") {
                let strings1 = absoluteString.components(separatedBy: "?")
                if strings1.count >= 2 {
                    let string2 = strings1[1]
                    let strings2 = string2.components(separatedBy: "&")
                    var para = [String:String]()
                    for i in 0..<strings2.count {
                        let string3 = strings2[i]
                        let strings3 = string3.components(separatedBy: "=")
                        if strings3.count == 2 {
                            let key = strings3[0]
                            let value = strings3[1]
                            para[key] = value
                        }
                        
                    }
                    print("para:\(para)")
                    
                    if let kUser_page = readIntValueOfDic(dataDic: para, key: "user_page") {

                        self.currentPage = kUser_page
                        self.currentAnswer = 0
                        print("isTimer <- true")
                        self.isTimer = true
//                        timerStart()
                    }
                }
                
                
            }
        }
        
        decisionHandler(.allow)
    }
    
    func setStart(){
//        let urlString = "http://ktas.org/app/php/online/get_start.php?test_code=\(test_code)"
        let urlString = "http://ktas.org/app/php/online/get_start.php"
        let para = [
            "test_code":test_code,
            "deviceid":deviceID,
            "device":osString,
            "app_ver":versionString
        ]
        print("setStart urlString:\(urlString)")
        let _ = Server.postData(urlString: urlString, method: .get, otherInfo: para) { (kData : Data?) in
//        Server.postData(urlString: urlString) { (kData : Data?) in
            if let data = kData {
                if let dataString = data.toString() {
                    print("setStart dataString : \(dataString)")
                }
                if let dataDic = data.toJson() as? [String:Any] {
                    print("------>\(dataDic)")
                    //{"success":"Y","url":"http:\/\/ktas.org\/app\/php\/online\/page.php?user_page=1&timer=y","limit_time":60,"ans_num":1,"cycle":1,"msg":null}
                    if let msg = dataDic["msg"] as? String {
                        appDel.showAlert(title: "안내", message: msg)
                    }
                    if let url = dataDic["url"] as? String
                        {
                            if let kimit_time = readIntValueOfDic(dataDic: dataDic, key: "limit_time") {
                                print("get_start -> limit_time 첫 로그인 -> 동의 -> 1번 문제")
                                self.timer?.invalidate()
                                self.currentLimitTime = kimit_time
                                DispatchQueue.main.async {
                                    self.bottomView.clockLabel.text = "\(self.currentLimitTime)"
                                    
                                    
                                    
                                }
                                self.bottomViewChange(isOn: true)
                                self.urlString = url
                                self.reloading()
                            }else if let kBase_limit_time = readIntValueOfDic(dataDic: dataDic, key: "base_limit_time") {
                                print("get_start -> base_limit_time 시험 도중 재 로그인 n번 문제")
                                self.timer?.invalidate()
                                self.currentLimitTime = limit_time ?? kBase_limit_time
                                DispatchQueue.main.async {
                                    self.bottomView.clockLabel.text = "\(self.currentLimitTime)"
                                }
                                self.bottomViewChange(isOn: true)
                                self.urlString = url
                                self.reloading()
                            }
                    }
                }
            }
        }
    }
    
    func setCapture(){
        
        NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: nil) { (fi) in
            self.didCapture()
            
        }
        
        NotificationCenter.default.addObserver(forName: UIScreen.capturedDidChangeNotification, object: nil, queue: nil) { (fi) in
            appDel.recodingBlackView.isHidden = !UIScreen.main.isCaptured
            if UIScreen.main.isCaptured {
                print("녹화 시작")
                self.didRecode()
            }
        }
    }
    func getDeviceUUID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
   
    
    func didCapture(){
        
        print("캡쳐")
    
        
//        let urlString = "http://ktas.org/app/php/online/capture_reg.php"
    
        let urlString = "http://ktas.org/app/php/online/capture_post.php"
        let para = [
            "capture_url":self.currentUrl,
            "uuid":getDeviceUUID(),
            "deviceid":deviceID,
            "test_code":test_code,
            "edu_type":edu_type,
            "capture_time":"\(Int(Date().timeIntervalSince1970))",
            "type":"C",
//            "device":osString,
            "device":"IOS",
            "app_ver":versionString
        ]
        print("didCapture")
        print("urlString : \(urlString)")
        print("para:\(para)")
        let _ = Server.postData(urlString: urlString, method: .post, otherInfo: para) { (kData : Data?) in
            if let data = kData {
                if let dataString = data.toString() {
                    print("dataString : \(dataString)")
                    
                
                }
            }
        }
        
    }
    
    func didRecode(){
        print("녹화")
        let urlString = "http://ktas.org/app/php/online/capture_post.php"
        
//        let urlString = "http://ktas.org/app/php/online/capture_reg.php"
        let para = [
            "capture_url":self.currentUrl,
            "uuid":getDeviceUUID(),
            "deviceid":deviceID,
            "test_code":test_code,
            "edu_type":edu_type,
            "capture_time":"\(Int(Date().timeIntervalSince1970))",
            "type":"M",
//            "device":osString,
            "device":"IOS",
            "app_ver":versionString
        ]
        print("didRecode")
        print("urlString : \(urlString)")
        print("para:\(para)")
        let _ = Server.postData(urlString: urlString, method: .post, otherInfo: para) { (kData : Data?) in
            if let data = kData {
                if let dataString = data.toString() {
                    print("dataString : \(dataString)")
                }
            }
        }
    }
    
    func didStartingRecode(){
        print("앱 시작시 이미 녹화중")
//
    
        
        let urlString = "http://ktas.org/app/php/online/capture_post.php"
//        let urlString = "http://ktas.org/app/php/online/capture_reg.php"
        let para = [
            "capture_url":self.currentUrl,
            "uuid":getDeviceUUID(),
            "deviceid":deviceID,
            "test_code":test_code,
            "edu_type":edu_type,
            "capture_time":"\(Int(Date().timeIntervalSince1970))",
            "type":"I",
//            "device":osString,
            "device":"IOS",
            "app_ver":versionString
        ]
        print("didStartingRecode")
        print("urlString : \(urlString)")
        print("para:\(para)")
        let _ = Server.postData(urlString: urlString, method: .post, otherInfo: para) { (kData : Data?) in
            if let data = kData {
                if let dataString = data.toString() {
                    print("dataString : \(dataString)")
                }
            }
        }
    }
    
    var timer : Timer?
    func timerStart(){
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in

            if !appDel.isActive { return }

            self.currentLimitTime -= 1
            DispatchQueue.main.async {
                self.bottomView.clockLabel.text = "\(self.currentLimitTime)"
            }
            limit_time = self.currentLimitTime
            print("timer - limit_time : \(limit_time)")

            
            
            
            if self.currentLimitTime <= 0 {
                timer.invalidate()

                self.goNext()
            }
        })
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    func jump(page:Int){
        print("jump:\(page)")
        
        let urlString = "http://ktas.org/app/php/online/proc.php"
        let para = [
            "ans_num":"\(self.currentPage)",
            "ans_val":"\(self.currentAnswer)",
            "test_code":test_code,
            "edu_type":edu_type,
            "sel_yn":"Y", //w제출 버튼을 눌렀을때
            //            "end_yn":"" //2회차 마지막 자동 submit
            "page_jump":"\(page)",
            "deviceid":deviceID,
            "device":osString,
            "app_ver":versionString,
            "remain_time":"\(self.currentLimitTime)"
        ]
        print("para:\(para)")
        appDel.showHud()
        let request = Server.postData(urlString: urlString, method: .post, otherInfo: para) { (kData : Data?) in
            appDel.hideHud()
            if let data = kData {
                if let dataString =      data.toString() {
                    print("submitButtonPressed dataString : \(dataString)")
                }
                if let dataDic = data.toJson() as? [String:Any] {
                    if let msg = dataDic["msg"] as? String {
                        appDel.showAlert(title: "안내", message: msg)
                    }
                    if let url = dataDic["url"] as? String
                    {
                        if let kimit_time = readIntValueOfDic(dataDic: dataDic, key: "limit_time") {
                            self.timer?.invalidate()
                            self.currentLimitTime = kimit_time
                        }
                        if let cycle = readIntValueOfDic(dataDic: dataDic, key: "cycle") {
                            self.currentCycle = cycle
                        }
                        DispatchQueue.main.async {
                            self.bottomView.clockLabel.text = "\(self.currentLimitTime)"
                        }
                        self.urlString = url
                        self.reloading()
                    }
                }
                
            }
        }
//        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
//            appDel.hideHud()
//            request?.cancel()
//        }
    }
    
    @objc func submitButtonPressed(){
        
        
//        if limit_time! <= 2 {
//            bottomView.submitButton.isEnabled = false
//            
//                bottomView.submitButtonImageView.setImageWithFrameWidth(image: UIImage(named: ""))
//            bottomView.submitButtonImageView.isHidden = true
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                self.bottomView.submitButton.isEnabled = true
//                self.bottomView.submitButtonImageView.setImageWithFrameWidth(image: UIImage(named: "submit"))
//                self.bottomView.submitButtonImageView.isHidden = false
//            }
//            
//        } else {
        
            
            print("submitButtonPressed")
            
            let urlString = "http://ktas.org/app/php/online/proc.php"
            let para = [
                "ans_num":"\(self.currentPage)",
                "ans_val":"\(self.currentAnswer)",
                "test_code":test_code,
                "edu_type":edu_type,
                "sel_yn":"Y", //w제출 버튼을 눌렀을때
                //            "end_yn":"" //2회차 마지막 자동 submit
                "deviceid":deviceID,
                "device":osString,
                "app_ver":versionString,
                "remain_time":"\(self.currentLimitTime)"
            ]
            print("para:\(para)")
            appDel.showHud()
            let request = Server.postData(urlString: urlString, method: .post, otherInfo: para) { (kData : Data?) in
                appDel.hideHud()
                if let data = kData {
                    
                    
                    
                    if let dataString = data.toString() {
                        print("submitButtonPressed dataString : \(dataString)")
                    }
                    if let dataDic = data.toJson() as? [String:Any] {
                        if let msg = dataDic["msg"] as? String {
                            appDel.showAlert(title: "안내", message: msg)
                        }
                        if let url = dataDic["url"] as? String
                        {
                            if let kimit_time = readIntValueOfDic(dataDic: dataDic, key: "limit_time") {
                                
                                self.timer?.invalidate()
                                self.currentLimitTime = kimit_time
                            }
                            if let cycle = readIntValueOfDic(dataDic: dataDic, key: "cycle") {
                                self.currentCycle = cycle
                            }
                            DispatchQueue.main.async {
                                self.bottomView.clockLabel.text = "\(self.currentLimitTime)"
                            }
                            let cycle2 = dataDic["cycle"]
                            
//                            if cycle2 as! Int == 2 {
//                                self.currentLimitTime = self.currentLimitTime - 1
//                            }
                            
                            self.urlString = url
                            self.reloading()
                        }
                    }
                    
                }
            }
        
        
        
        
            //        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
            //            appDel.hideHud()
            //            request?.cancel()
            //        }
            
//        }
        
        
        
    }
    
    func goNext(){
        print("goNext")
        print("self.currentPage:\(self.currentPage)")
        print("self.currentAnswer:\(self.currentAnswer)")
        
        if self.currentPage == 0 {
           print("self.currentPage == 0 error")
        }
        if self.currentAnswer == 0 {
            print("답변을 선택하지 않음")
        }
        
        let urlString = "http://ktas.org/app/php/online/proc.php"
        var para = [
            "ans_num":"\(self.currentPage)",
            "ans_val":"\(self.currentAnswer)",
            "test_code":test_code,
            "edu_type":edu_type,
//            "sel_yn":"Y", //w제출 버튼을 눌렀을때
//            "end_yn":"" //2회차 마지막 자동 submit
            "deviceid":deviceID,
            "device":osString,
            "app_ver":versionString,
            "remain_time":"\(self.currentLimitTime)"
        ]
        if self.currentCycle == 2 {
            para["end_yn"] = "Y"
        }
        print("goNext para : \(para)")
        appDel.showHud()
        let request = Server.postData(urlString: urlString, method: .post, otherInfo: para) { (kData : Data?) in
            appDel.hideHud()
            print("3")
            if let data = kData {
                if let dataString = data.toString() {
                    print("goNext dataString : \(dataString)")
                }
                if let dataDic = data.toJson() as? [String:Any] {
                    if let msg = dataDic["msg"] as? String {
                        appDel.showAlert(title: "안내", message: msg)
                    }
                    if let url = dataDic["url"] as? String
                    {
                        if let kimit_time = readIntValueOfDic(dataDic: dataDic, key: "limit_time") {
                            self.timer?.invalidate()
                            self.currentLimitTime = kimit_time
                        }
                        if let cycle = readIntValueOfDic(dataDic: dataDic, key: "cycle") {
                            self.currentCycle = cycle
                        }
                        DispatchQueue.main.async {
                            self.bottomView.clockLabel.text = "\(self.currentLimitTime)"
                        }
                        self.urlString = url
                        self.reloading()
                    }
                }
                
            }
            print("4")
        }
        
        self.bottomView.submitButtonImageView.isHidden = true
        
//        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
//            appDel.hideHud()
//            request?.cancel()
//        }
    }
    
    
    
    func webViewDidClose(_ webView: WKWebView){
        print(#function)
        print("11")
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView){
        print(#function)
        print("12")
    }
    
    
    //MARK:WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        print(#function)
        print("13")
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!){
        print(#function)
        print("14")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error){
        print(#function,"error:\(error.localizedDescription)")
        
        
        
        
        
        print("15")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        print(#function)
        print("16")
    }
    
    var isTimer = false
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        print("완료시점??")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.bottomView.submitButton.isEnabled = true
            self.bottomView.submitButton.isHidden = false
                        self.bottomView.submitButtonImageView.setImageWithFrameWidth(image: UIImage(named: "submit"))
                        self.bottomView.submitButtonImageView.isHidden = false
                    }
        
        print(#function)
        print("isTimer : \(isTimer)")
        if isTimer {
            print("isTimer == true -> timerStart")
            timerStart()
            isTimer = false
        }
//        self.progressBar.frame.size.width = 0
        self.hud?.hide(animated: true)
        self.hud = nil
        //?/
        print("check===:didFinish navigation")
    }
    
    
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        print(#function,"error:\(error.localizedDescription)")
        print("18")
//        self.progressBar.frame.size.width = 0
        self.hud?.hide(animated: true)
        self.hud = nil
        //?/
        print("check===:didFail navigation")
        
    }
    
}


class BottomView : UIView {
    
    var clockLabel : UILabel!
    
    var submitButton : UIButton!
    var submitButtonImageView : UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let imageView = UIImageView(frame: CGRect(x: 20, y: 0, width: self.height, height: self.height))
        imageView.frame.size.width *= 0.5
        imageView.frame.size.height *= 0.5
        imageView.image = UIImage(named: "clock")
        imageView.center.y = self.height / 2
        self.addSubview(imageView)
        
        
         submitButtonImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: self.height))
        submitButtonImageView.frame.size.height *= 0.7
        submitButtonImageView.setImageWithFrameWidth(image: UIImage(named: "submit"))
        submitButtonImageView.frame.origin.x = self.width - submitButtonImageView.width - 10
        submitButtonImageView.center.y = self.height / 2
        self.addSubview(submitButtonImageView)
        
        
        clockLabel = UILabel(frame: CGRect(x: imageView.maxX + 15, y: 0, width: 0, height: self.height))
        clockLabel.frame.size.width = (submitButtonImageView.minX - 15) - clockLabel.frame.origin.x
        clockLabel.textAlignment = .left
        clockLabel.font = UIFont(name: Nanum_Barun_Gothic_OTF_Bold, size: clockLabel.height * 0.5)
        clockLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        clockLabel.frame.origin.x = imageView.maxX + 15
        clockLabel.center.y = self.height / 2
        self.addSubview(clockLabel)
        
        submitButton = UIButton(frame: CGRect(x: submitButtonImageView.minX, y: 0, width: self.width - submitButtonImageView.minX, height: self.height))
        self.addSubview(submitButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



func readIntValueOfDic(dataDic : [String:Any], key : String) -> Int?{
    var intValue : Int? = nil
    if let valueInt = dataDic[key] as? Int {
        intValue = valueInt
    }
    if let valueString = dataDic[key] as? String {
        if let valueInt = Int(valueString, radix: 10) {
            intValue = valueInt
        }
    }
    return intValue
}


//extension UIView {
//    func makeSecure() {
//        DispatchQueue.main.async {
//
//
//            let field = UITextField()
//
//            field.isSecureTextEntry = true
//            self.addSubview(field)
//            field.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//            field.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//            self.layer.superlayer?.addSublayer(field.layer)
//            field.layer.sublayers?.first?.addSublayer(self.layer)
//
//        }
//    }
//}
