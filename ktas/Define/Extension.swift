
import UIKit


extension UIView {
    
    func uiCheck(){
        self.backgroundColor = UIColor.random.withAlphaComponent(0.3)
        
        let subViewCount = self.subviews.count
        if subViewCount > 0 {
            for i in 0..<subViewCount {
                let targetView = self.subviews[i]
                targetView.uiCheck()
            }
        }else{
            return
        }
    }
}


extension UIView {
    var height : CGFloat {
        get{
            return self.frame.size.height
        }
    }
    var width : CGFloat {
        get{
            return self.frame.size.width
        }
    }
    var x : CGFloat {
        get{
            return self.frame.origin.x
        }
    }
    var y : CGFloat {
        get{
            return self.frame.origin.y
        }
    }
    var maxX : CGFloat {
        get{
            return self.frame.maxX
        }
    }
    var maxY : CGFloat {
        get{
            return self.frame.maxY
        }
    }
    var minX : CGFloat {
        get{
            return self.frame.minX
        }
    }
    var minY : CGFloat {
        get{
            return self.frame.minY
        }
    }
}

typealias UINavigationController = _FullScreenModalNavigationController
class _FullScreenModalNavigationController: UIKit.UINavigationController {
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.modalPresentationStyle = .fullScreen
  }
  override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)
    self.modalPresentationStyle = .fullScreen
  }
  convenience init() {
    self.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.modalPresentationStyle = .fullScreen
  }
}





//MARK:AppDelegate ================================================================================================================================================

extension AppDelegate {
    //MARK:about AlertCon
    
    struct UIAlertController_AssociatedKeys {
        static var UIAlertController: UInt8 = 0
    }
    
    var alertCon : UIAlertController? {
        get {
            guard let value = objc_getAssociatedObject(self, &UIAlertController_AssociatedKeys.UIAlertController) as? UIAlertController else { return nil }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &UIAlertController_AssociatedKeys.UIAlertController, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func showAlert(title : String?, message : String?, actions:[UIAlertAction] = [UIAlertAction(title: "확인", style: .cancel, handler: nil)], complete:(()->Void)? = nil){
        self.alertCon?.dismiss(animated: false, completion: {})
        self.alertCon = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            self.alertCon?.addAction(action)
        }
        
        DispatchQueue.main.async {
            appDel.topVC?.present(self.alertCon!, animated: true, completion: {
                complete?()
            })
        }
        
    }
}

extension AppDelegate {
    //MARK:about MBProgressHUD
    
    struct MBProgressHUD_AssociatedKeys {
        static var MBProgressHUD: UInt8 = 0
    }
    
    var hud : MBProgressHUD? {
        get {
            guard let value = objc_getAssociatedObject(self, &MBProgressHUD_AssociatedKeys.MBProgressHUD) as? MBProgressHUD else { return nil }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &MBProgressHUD_AssociatedKeys.MBProgressHUD, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func showHud(){
        DispatchQueue.main.async {
            self.hud?.hide(animated: false)
            self.hud = MBProgressHUD.showAdded(to: self.window!, animated: true)
        }
        
    }
    public func hideHud(){
        DispatchQueue.main.async {
            self.hud?.hide(animated: true)
        }
    }
    
}

extension AppDelegate {
    //MARK:about topVC, allDismiss

    var topVC : UIViewController? {
        get{
            if var kTopVC = self.window?.rootViewController {
                while let presentedViewController = kTopVC.presentedViewController {
                    kTopVC = presentedViewController
                }
                return kTopVC
            }
            return nil
        }
    }
    func allDismiss(complete:@escaping ()->Void) {
        var topVCs = [UIViewController]()
        if let rootVC = appDel.window?.rootViewController {
            var topVC = rootVC
            while let presentedViewController = topVC.presentedViewController {
                topVC = presentedViewController
                topVCs.append(topVC)
            }
            if topVCs.count == 0{
                complete()
                return
            }
            for _ in 0..<topVCs.count {
                topVCs.popLast()?.dismiss(animated: true, completion: {
                    if topVCs.count == 0 {
                        complete()
                    }
                })
            }
        }
    }
}

//MARK:UIApplication ================================================================================================================================================
extension UIApplication {
    //MARK:about topViewController

    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

//MARK:String ================================================================================================================================================
extension String {
    //MARK:about read parameter from webURL

    func parameterFromURL() -> [String:String] {
        if let urlString = self.removingPercentEncoding {
            let urlComponnents = urlString.components(separatedBy: "?")
            if urlComponnents.count == 2 {
                let parameterString = urlComponnents[1]
                let parameterComponents = parameterString.components(separatedBy: "&")
                var parameterDic = [String:String]()
                for i in 0..<parameterComponents.count {
                    let parameters = parameterComponents[i].components(separatedBy: "=")
                    if parameters.count >= 2{
                        let key = parameters[0]
                        let value = parameterComponents[i].replacingOccurrences(of: "\(key)=", with: "")
                        parameterDic[key] = value
                    }
                }
                print("parameterFromURL:\(parameterDic)")
                return parameterDic
            }
        }
        print("parameterFromURL is empty")
        return [String:String]()
    }
    
    //old version
    func parameterFromURL2() -> [String:String] {
        if let urlString = self.removingPercentEncoding {
            let urlComponnents = urlString.components(separatedBy: "?")
            if urlComponnents.count == 2 {
                let parameterString = urlComponnents[1]
                let parameterComponents = parameterString.components(separatedBy: "&")
                var parameterDic = [String:String]()
                for i in 0..<parameterComponents.count {
                    let parameters = parameterComponents[i].components(separatedBy: "=")
                    if parameters.count == 2{
                        parameterDic[parameters[0]] = parameters[1]
                    }
                }
                print("parameterFromURL:\(parameterDic)")
                return parameterDic
            }
        }
        print("parameterFromURL is empty")
        return [String:String]()
    }
}

extension String {
    //MARK:about write parameter to webURL

    func addParameterToURLString(key : String, value : String ) -> String{
        var newURLString = self
        if !newURLString.contains("\(key)=") {
            if newURLString.contains("?") {
                newURLString.append("&\(key)=\(value)")
            }else{
                newURLString.append("?\(key)=\(value)")
            }
        }
        return newURLString
    }
    
    func addPercenterEncoding() -> String {
        var newURLString = self
        if let removingURL = newURLString.removingPercentEncoding {
            newURLString = removingURL
        }
        if let addURL = newURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            newURLString = addURL
        }
        return newURLString
    }
}

//MARK:NSMutableAttributedString ================================================================================================================================================
extension NSMutableAttributedString {
    
    /*
     //이미지 추가
     let attributedString = NSMutableAttributedString(string: "like after")
     let textAttachment = NSTextAttachment()
     textAttachment.image = #imageLiteral(resourceName: "btn_d_fav_on")
     let attrStringWithImage = NSAttributedString(attachment: textAttachment)
     textAttachment.bounds = CGRect(origin: CGPoint(x: 0, y: (heartInfoLabel.font.capHeight - fontAwesomeImage.size.height).rounded() / 2), size: fontAwesomeImage.size)
     attributedString.replaceCharacters(in: NSMakeRange(4, 1), with: attrStringWithImage)
     textView.attributedText = attributedString
     */
    
    typealias StringInfo = (String,[NSAttributedString.Key:NSObject])
    
    convenience init(stringsInfos : [StringInfo]) {
        
        var targetString = ""
        for i in 0..<stringsInfos.count {
            targetString = "\(targetString)\(stringsInfos[i].0)"
        }
        
        self.init(string: targetString)
        
        for i in 0..<stringsInfos.count {
            var startIndex = 0
            if (i) > 0 {
                for j in 0..<i {
                    startIndex += stringsInfos[j].0.count
                }
                
            }
            self.setAttributes(stringsInfos[i].1, range: NSMakeRange(startIndex, stringsInfos[i].0.count))
        }
    }
}


//MARK:WebKit ================================================================================================================================================
import WebKit
final class WebCacheCleaner {
    class func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("[WebCacheCleaner] All cookies deleted")
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("[WebCacheCleaner] Record \(record) deleted")
            }
        }
    }
}


//MARK:UINavigationController ================================================================================================================================================
extension UINavigationController {
    override open var shouldAutorotate: Bool {
        return true
    }
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    override open var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
}

class NotRotatableNavigationController : UINavigationController {
    override open var shouldAutorotate: Bool {
        return true
    }
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
}

class RotatableNavigationController : UINavigationController {
    
    override open var shouldAutorotate: Bool {
        return true
    }
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait,.landscape]
    }
}

//MARK:UIView ================================================================================================================================================

extension UIView {
    
    func setShadow(){
        self.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.7
        self.layer.cornerRadius = 10
    }
    
}

extension UIView {
    func setCornerRadius( cornerRadius : CGFloat , byRoundingCorners roundingCorners : UIRectCorner){
        let maskPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height),
                                    byRoundingCorners: roundingCorners,
                                    cornerRadii: CGSize(width: cornerRadius, height: 0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    
        
    func addCornerLayer(cornerRadius: CGFloat, byRoundingCorners roundingCorners: UIRectCorner, complete:@escaping(_ layer : CAShapeLayer) -> Void) {
        let cornerPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height),
                                      byRoundingCorners: roundingCorners,
                                      cornerRadii: CGSize(width: cornerRadius, height: 0))
        let cornerLayer = CAShapeLayer()
        cornerLayer.path = cornerPath.cgPath
        self.layer.addSublayer(cornerLayer)
        
        complete(cornerLayer)
    }
    

}

extension UIView {
    
    struct AssociatedKeys {
        static var gradientLayer: UInt8 = 0
    }
    
    var gradientLayer : CAGradientLayer? {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.gradientLayer) as? CAGradientLayer? else { return nil }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.gradientLayer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setGradientBackgroundColor( colors : [UIColor]) {
        
        gradientLayer?.removeFromSuperlayer()
        
        gradientLayer = CAGradientLayer()
        gradientLayer?.frame = self.bounds
        gradientLayer?.colors = colors.map { (color) -> CGColor in
            return color.cgColor
        }
        self.layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    func setGradientBackgroundColor( colors : [UIColor], widthOption:(_ gradientLayer : CAGradientLayer)->Void) {
        
        gradientLayer?.removeFromSuperlayer()
        
        gradientLayer = CAGradientLayer()
        gradientLayer?.frame = self.bounds
        gradientLayer?.colors = colors.map { (color) -> CGColor in
            return color.cgColor
        }
        self.layer.insertSublayer(gradientLayer!, at: 0)
        
        widthOption(gradientLayer!)
    }
    
    func gradientBackgroundColor(colors : [UIColor], startPoint : CGPoint, endPoint : CGPoint ) -> UIColor? {
        let cgColors = colors.map { (color) -> CGColor in
            return color.cgColor
        }
        
        let size = self.frame.size
        let gradientLayer =  CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = cgColors
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        UIGraphicsBeginImageContext(size)
        
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = image {
            return UIColor(patternImage: image)
        }
        
        return nil
    }
}

//MARK: CGRect
extension CGRect {
    init(center : CGPoint, size : CGSize) {
        let originX = center.x - (size.width / 2)
        let originY = center.y - (size.height / 2)
        self.init(origin: CGPoint(x: originX, y: originY), size: size)
    }
    
    var center : CGPoint {
        return CGPoint(x: self.size.width / 2, y: self.size.height / 2)
    }
}


//MARK:roundToPlaces
extension Double {
    func roundToPlaces(places : Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        let multiplierValue = (self * multiplier)
        return multiplierValue.rounded(.toNearestOrAwayFromZero) / multiplier
    }
}

extension CGFloat {
    func roundToPlaces(places : Int) -> CGFloat {
        let multiplier = pow(10.0, CGFloat(places))
        let multiplierValue = (self * multiplier)
        return multiplierValue.rounded(.toNearestOrAwayFromZero) / multiplier
    }
}




//MRRK:UIButton
extension UIButton {
    
    //addTarget Clsure ========================================================================================================//
    struct AssociatedKeys {
        static var buttonAction: UInt8 = 0
    }
    
    var buttonAction : ((_ button : UIButton) -> Void)? {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.buttonAction) as? ((_ button : UIButton) -> Void)? else { return nil }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.buttonAction, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func setTarget ( event : UIControl.Event, buttonAction kButtonAction:@escaping (_ button : UIButton) -> Void) {
        self.buttonAction = kButtonAction
        self.addTarget(self, action: #selector(buttonPressed(button:)), for: event)
    }
    public func addTarget ( event : UIControl.Event, buttonAction kButtonAction:@escaping (_ button : UIButton) -> Void) {
        self.buttonAction = kButtonAction
        self.addTarget(self, action: #selector(buttonPressed(button:)), for: event)
    }
    
    @objc private func buttonPressed(button : UIButton){
        self.buttonAction?(self)
    }
    //======================================================================================================== addTarget Clsure//
    
    
}

extension UIButton {
    func setGradientColorImage( colors : [UIColor], for state : UIControl.State ){
        
        let cgColors = colors.map { (color) -> CGColor in
            return color.cgColor
        }
        
        let size = self.frame.size
        let gradientLayer =  CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = cgColors
        
        UIGraphicsBeginImageContext(size)
        
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setImage(image, for: state)
    }
}

//MARK:UIImageView
extension UIImageView {
    
    //이미지를 세팅함과 동시에 비율 맞춰 높이 또는 너비 맞추기
    @objc func setImageWithFrameHeight( image kImage : UIImage?){
        if let image = kImage {
            self.image = image
            let frameHeight = self.frame.size.width * (image.size.height / image.size.width)
            self.frame.size.height = frameHeight
        }
    }
    func setImageWithFrameWidth( image kImage : UIImage?){
        if let image = kImage {
            self.image = image
            let frameWidth = self.frame.size.height * (image.size.width / image.size.height)
            self.frame.size.width = frameWidth
        }
    }
    
    func setGradientColorImage( colors : [UIColor] ){
        
        let cgColors = colors.map { (color) -> CGColor in
            return color.cgColor
        }
        
        let size = self.frame.size
        let gradientLayer =  CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = cgColors
        
        UIGraphicsBeginImageContext(size)
        
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.image = image
    }
}

//MARK:UIImage ================================================================================================================================================
extension UIImage {
    
    enum FileExtensionType : String {
        case png = "png"
        case jpg = "jpg"
    }
    
    static func removeImageFromDocument(fileName : String, fileExtension : FileExtensionType = .png) {
        
        let documentPathURL : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let fileName : String     = "\(fileName).\(fileExtension.rawValue)"
        let fileURL : URL         = documentPathURL.appendingPathComponent(fileName)
        
        try? FileManager.default.removeItem(at: fileURL)
        
    }
    
    //이미지가 돌아가는 문제 -> png->jpg로 해결
    func saveImageToDocuments(fileName : String, fileExtension : FileExtensionType = .png) -> URL?{
        
        // 사진 저장
        let documentPathURL : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let fileName : String     = "\(fileName).\(fileExtension.rawValue)"
        let fileURL : URL         = documentPathURL.appendingPathComponent(fileName)
        
        let imageData : Data? = {
            if fileExtension == .png {
                return self.pngData()
            }else{
                return self.jpegData(compressionQuality: 1)
            }
        }()
        
        
        if let kImageData = imageData {
            do {
                try kImageData.write(to: fileURL, options: [.atomic])
                return fileURL
            }catch {
                print("saveImageToDocuments error 1: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
    
    class func readImageFromeDocuments(fileName : String, fileExtension : FileExtensionType = .png) -> UIImage? {
        
        let documentPathURL : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let fileName : String     = "\(fileName).\(fileExtension.rawValue)"
        let fileURL : URL         = documentPathURL.appendingPathComponent(fileName)
        
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    func resizeForWeb() -> UIImage?{
        let maxSize = max(self.size.width, self.size.height)
        let scale = 720 / maxSize
        
        return resizeImage(scale: scale)
    }
    
    func resizeImage(scale : CGFloat) -> UIImage? {
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let newSize = self.size.applying(transform)
        
        return resizeImage(size: newSize)
    }
    
    func resizeImage(size : CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let afterImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return afterImage
    }
    
    //Barcode
    enum CodeType {
        case qrCode
        case barCode
    }
    
    class func makeQRCodeImage( type : CodeType, code : String, size : CGSize ) -> UIImage? {
        
        let filter : CIFilter
        if type == .qrCode { filter = CIFilter(name: "CIQRCodeGenerator")! }
        else{ filter = CIFilter(name: "CICode128BarcodeGenerator")! }
        
        filter.setDefaults()
        
        let data : Data?
        if type == .qrCode { data = code.data(using: String.Encoding.utf8) }
        else{ data = code.data(using: String.Encoding.ascii) }
        
        if data == nil {
            print("string error not - encoded")
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            
            let transform = CGAffineTransform.identity.scaledBy(x: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            let image = UIImage(ciImage: scaledImage, scale: 10.0, orientation: UIImage.Orientation.up)
            
            print("barcode original imageSize:\(image.size)")
            
            return image.resizeImage(size: size)
        }
        return nil
    }
}

extension UIImage {
    
    static func fromColor(color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    
    func blendWithColorAndRect(blendMode: CGBlendMode, color: UIColor, viewFrame : CGRect, blendFrame: CGRect) -> UIImage? {
        
        //컬러로 만들어진 이미지 객체 - 블렌드 영역 크기
        let imageColor = UIImage.fromColor(color: color, size:blendFrame.size)
        
        //(이미지)뷰의 크기, 여기선 origin이 0,0이 된다 (자기 자신이니까)
        let viewBound = CGRect(origin: CGPoint.zero, size: viewFrame.size)
        
        //뷰 크기만큼 바탕을 만든다
        UIGraphicsBeginImageContextWithOptions(viewFrame.size, true, 0) //좌표계의 기준
        let context = UIGraphicsGetCurrentContext()
        
        //뷰에 뷰 영역만큼 흰색을 칠함
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(viewBound) // 화이트 영역
        
        //뷰 영역만큼 normal 블렌드로 이미지(자신)를 채운다
        self.draw(in: viewBound, blendMode: .normal, alpha: 1) //이미지 드로우 영역
        
        //블렌드 영역만큼 컬러 이미지를 원하는 블렌드모드로 채운다
        imageColor?.draw(in: blendFrame, blendMode: blendMode, alpha: 1) //컬러 드로우 영역
        
        //작업 결과를 이미지 객체로 만든다.
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        //작업 종료
        UIGraphicsEndImageContext()
        return result
        
    }
}

//MARK:================================================================================================================================================ UIImage


//MARK:UIViewController
extension UIViewController : UIGestureRecognizerDelegate {
    
    //스와이프(swipe)로 뒤로가기
    
    //navigationController의 rootViewController에 등록
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    //    }
    
    //extention으로 둠
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


extension UIViewController {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
//            if let textField = touch.view as? UITextField {
//                textField.resignFirstResponder()
//            }else if let textView = touch.view as? UITextView {
//                textView.resignFirstResponder()
//            }
            
            if !touch.view!.isKind(of: UITextField.self) || !touch.view!.isKind(of: UITextView.self) {
//                print("extension UIViewController touchesBegan")

                self.view.endEditing(true)
            }
        }
    }
}


//MARK:UIColor
extension UIColor {
    
    static let systemRed                 = UIColor(colorWithHexValue: 0xFF3B30)
    static let systemOrange              = UIColor(colorWithHexValue: 0xFF9500)
    static let systemYellow              = UIColor(colorWithHexValue: 0xFFCC00)
    static let systemGreen               = UIColor(colorWithHexValue: 0x4CD964)
    static let systemTeal                = UIColor(colorWithHexValue: 0x5AC8FA)
    static let systemBlue                = UIColor(colorWithHexValue: 0x007AFF)
    static let systemPurple              = UIColor(colorWithHexValue: 0x5856D6)
    static let systemPink                = UIColor(colorWithHexValue: 0xFF2D55)
    
    static let systemExtraLightGrayColor = UIColor(colorWithHexValue: 0xEFEFF4)
    static let systemLightGrayColor      = UIColor(colorWithHexValue: 0xE5E5EA)
    static let systemLightMidGrayColor   = UIColor(colorWithHexValue: 0xD1D1D6)
    static let systemMidGrayColor        = UIColor(colorWithHexValue: 0xC7C7CC)
    static let systemGrayColor           = UIColor(colorWithHexValue: 0x8E8E93)

    static var random: UIColor {
        get{
            return UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
        }
    }
    
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    
    convenience init(colorWithHexString hexString: String){
        
        var rgbValue : CUnsignedInt = 0
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 0
        scanner.scanHexInt32(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1
        )
    }
    
    func removeBrightness(val: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0
        var b: CGFloat = 0, a: CGFloat = 0
        
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            else {return self}
        
        return UIColor(hue: h,
                       saturation: s,
                       brightness: (b - val),
                       alpha:a )
    }
}


//MARK:UITextField
extension UITextField {
    func addDoneCancelToolbar(doneString : String = "완료", onDone: (target: Any, action: Selector)? = nil) {
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: doneString, style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
        
    }
    
    @objc func doneButtonTapped() { self.resignFirstResponder() }

}

//MARK:UITextView
extension UITextView {
    func addDoneCancelToolbar(doneString : String = "완료", onDone: (target: Any, action: Selector)? = nil) {
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: doneString, style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
        
    }
    
    @objc func doneButtonTapped() { self.resignFirstResponder() }
}

//MARK:String
extension String {
    
    func subString(start startIndex : Int , numberOf endIndex : Int ) -> String? {
        if self.count < (startIndex + endIndex) {
            print("\(#function) out of range")
            return nil
        }
        
        let start  = self.index(self.startIndex, offsetBy: startIndex)
        let end  = self.index(start, offsetBy: endIndex)
        let subString = self[start..<end]
        return String(subString)
    }
    
    func subString(start startIndex : Int , end endIndex : Int ) -> String? {
        if self.count < startIndex || self.count < endIndex {
            print("\(#function) out of range")
            return nil
        }
        
        let start  = self.index(self.startIndex, offsetBy: startIndex)
        let end  = self.index(self.startIndex, offsetBy: endIndex)
        let subString = self[start...end]
        return String(subString)
    }
    
    func subString(to endIndex : Int) -> String?{
        if self.count < endIndex {
            print("\(#function) out of range")
            return nil
        }
        
        let end  = self.index(self.startIndex, offsetBy: endIndex)
        let subString = self[self.startIndex...end]
        return String(subString)
    }
    
    func subString(from startIndex : Int) -> String?{
        if self.count < startIndex {
            print("\(#function) out of range")
            return nil
        }
        let start  = self.index(self.startIndex, offsetBy: startIndex)
        let subString = self[start..<self.endIndex]
        return String(subString)
    }
    
    func toCGFloat() -> CGFloat? {
        if let number = NumberFormatter().number(from: self) {
            return CGFloat(truncating: number)
        }
        return nil
        
    }
    
    func toInt() -> Int? {
        return Int(self, radix: 10)
    }
    
    func toData() -> Data? {
        return self.data(using: String.Encoding.utf8)
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    func toHtmlAttString() -> NSAttributedString? {
        if let unicodeData = self.data(using: String.Encoding.unicode) {
            
            do {
                let attrStr = try NSAttributedString( // do catch
                    data: unicodeData,
                    options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                    documentAttributes: nil)
                return attrStr
            }catch {
                print("toHtmlAttString error 2: \(error.localizedDescription)")
            }
        }
        
        return nil
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    func supAttString() -> NSAttributedString? {
        let newString = "<sup>\(self)</sup>"
        return newString.toHtmlAttString()
    }
    
    func subAttString() -> NSAttributedString? {
        let newString = "<sub>\(self)</sub>"
        return newString.toHtmlAttString()
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func search(of target:String) -> Range<Index>? {
        // 찾는 결과는 `leftIndex`와 `rightIndex`사이에 들어가게 된다.
        var leftIndex = startIndex
        while true {
            // 우선 `leftIndex`의 글자가 찾고자하는 target의 첫글자와 일치하는 곳까지 커서를 전진한다.
            guard self[leftIndex] == target[target.startIndex] else {
                leftIndex = index(after:leftIndex)
                if leftIndex >= endIndex { return nil }
                continue
            }
            // `leftIndex`의 글자가 일치하는 곳이후부터 `rightIndex`를 늘려가면서 일치여부를 찾는다.
            var rightIndex = index(after:leftIndex)
            var targetIndex = target.index(after:target.startIndex)
            while self[rightIndex] == target[targetIndex] {
                // target의 전체 구간이 일치함이 확인되는 경우
                guard distance(from:leftIndex, to:rightIndex) < target.count - 1
                    else {
                        return leftIndex..<index(after:rightIndex)
                }
                rightIndex = index(after:rightIndex)
                targetIndex = target.index(after:targetIndex)
                // 만약 일치한 구간을 찾지못하고 범위를 벗어나는 경우
                if rightIndex >= endIndex {
                    return nil
                }
            }
            leftIndex = index(after:leftIndex)
        }
    }
}

extension String {
    func regularExpression(pattern : String, option : NSRegularExpression.Options = .caseInsensitive) -> [String]{
        //리턴할 문자 배열 생성
        var afterStrings = [String]()
        
        //Range를 이용하기 위해 NSString으로 변경
        let myNSString = self as NSString
        do {
            //정규표현식 객체 생성
            let regex = try NSRegularExpression(pattern: pattern, options: option)
            
            //정규표현식과 매칭 -> [NSTextCheckingResult]
            let results = regex.matches(in: self, options: [], range: NSRange(location: 0, length: myNSString.length))
            
            //결과에 포함되어 있는 range를 이용해 매칭된 문자들을 뽑아냄
            afterStrings = results.map { (result: NSTextCheckingResult) -> String in
                let afterString = myNSString.substring(with: result.range)
                return afterString
            }
        }catch{
            //정규표현식 객체 생성 실패
            print("\(#function) error 3: \(error.localizedDescription)")
            
        }
        
        //결과물 리턴
        return afterStrings
    }
}




extension Dictionary where Key == String {
    
    func showValue(){
        print()
        print("====")
        let keys = self.keys.sorted(by: > )
        for key in keys {
            if let dataDicValue = self[key] as? [String:Any] {
                print("\(key) : ")
                dataDicValue.showValue()
            }else if let dataArrayValue = self[key] as? [[String:Any]]{
                for i in 0..<dataArrayValue.count {
                    let dataDic = dataArrayValue[i]
                    dataDic.showValue()
                }
            }else if let value = self[key] {
                print("\"\(key)\" : \"\(value)\"")
            }
        }
        print("====")
        print()
    }
    
}


//from 용철대리님

//extension String {
//    //문장 찾기.
//    func search(of target:String) -> Range<Index>? {
//        // 찾는 결과는 `leftIndex`와 `rightIndex`사이에 들어가게 된다.
//        var leftIndex = startIndex
//        while true {
//            // 우선 `leftIndex`의 글자가 찾고자하는 target의 첫글자와 일치하는 곳까지 커서를 전진한다.
//            guard self[leftIndex] == target[target.startIndex] else {
//                leftIndex = index(after:leftIndex)
//                if leftIndex >= endIndex { return nil }
//                continue
//            }
//            // `leftIndex`의 글자가 일치하는 곳이후부터 `rightIndex`를 늘려가면서 일치여부를 찾는다.
//            var rightIndex = index(after:leftIndex)
//            var targetIndex = target.index(after:target.startIndex)
//            while self[rightIndex] == target[targetIndex] {
//                // target의 전체 구간이 일치함이 확인되는 경우
//                guard distance(from:leftIndex, to:rightIndex) < target.characters.count - 1
//                    else {
//                        return leftIndex..<index(after:rightIndex)
//                }
//                rightIndex = index(after:rightIndex)
//                targetIndex = target.index(after:targetIndex)
//                // 만약 일치한 구간을 찾지못하고 범위를 벗어나는 경우
//                if rightIndex >= endIndex {
//                    return nil
//                }
//            }
//            leftIndex = index(after:leftIndex)
//        }
//    }
//}
//
////암호화
//
//extension String {
//
//    /* How to using
//    func getUkMd5(){
//        let date = Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yMMddHmssSSSS"
//        let hashvalue = UUID().uuidString.hmac(algorithm: .MD5, key: formatter.string(from: date))
//        print("hash=\(hashvalue)")
//        //code insert
//        UD.set(hashvalue, forKey: "id")
//        DispatchQueue.global().async(execute: {
//            REQ.sendLogin(code: EVENT_CODE, id: hashvalue)
//        })
//    }
//    */
//
//    enum CryptoAlgorithm {
//        case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
//        var HMACAlgorithm: CCHmacAlgorithm {
//            var result: Int = 0
//            switch self {
//            case .MD5:      result = kCCHmacAlgMD5
//            case .SHA1:     result = kCCHmacAlgSHA1
//            case .SHA224:   result = kCCHmacAlgSHA224
//            case .SHA256:   result = kCCHmacAlgSHA256
//            case .SHA384:   result = kCCHmacAlgSHA384
//            case .SHA512:   result = kCCHmacAlgSHA512
//            }
//            return CCHmacAlgorithm(result)
//        }
//        var digestLength: Int {
//            var result: Int32 = 0
//            switch self {
//            case .MD5:      result = CC_MD5_DIGEST_LENGTH
//            case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
//            case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
//            case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
//            case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
//            case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
//            }
//            return Int(result)
//        }
//    }
//
//    func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
//        var result: [CUnsignedChar]
//        if let ckey = key.cString(using: String.Encoding.utf8), let cdata = self.cString(using: String.Encoding.utf8) {
//            result = Array(repeating: 0, count: Int(algorithm.digestLength))
//            CCHmac(algorithm.HMACAlgorithm, ckey, ckey.count-1, cdata, cdata.count-1, &result)
//        } else {
//            fatalError("Nil returned when processing input strings as UTF8")
//        }
//
//        //return Data(bytes: result, count: result.count).base64EncodedString()
//        /**/
//        let hash = NSMutableString()
//        for val in result {
//            hash.appendFormat("%02hhx", val)
//        }
//        return hash as String
//        /**/
//    }
//}



