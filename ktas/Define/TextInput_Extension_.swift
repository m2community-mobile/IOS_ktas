import UIKit

//MARK:Way1
//extension UIViewController : UITextFieldDelegate, UITextViewDelegate {
//
//    public func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.didKeyBoardUp(control: textField)
//    }
//
//    public func textFieldDidEndEditing(_ textField: UITextField) {
//        self.didKeyBoardDown()
//    }
//
//    public func textViewDidBeginEditing(_ textView: UITextView) {
//        self.didKeyBoardUp(control: textView)
//    }
//
//    public func textViewDidEndEditing(_ textView: UITextView) {
//        self.didKeyBoardDown()
//    }
//
//    func didKeyBoardDown() {
//
//        UIView.animate(withDuration: 0.3) {
//            appDel.window?.frame.origin.y = 0
//        }
//    }
//
//    func didKeyBoardUp(control : UIView){
//
//        let margin : CGFloat = 20
//
//        let keyBoardHeight : CGFloat = DEFAULT_KEYBOARD_HEIGHT + margin
//
//        let textControlMaxY = (appDel.window?.rootViewController?.view.convert(control.frame, from: control.superview!).maxY)!
//        var targetHeight = (UIScreen.main.bounds.size.height - textControlMaxY) - keyBoardHeight
//        targetHeight = max(targetHeight, -keyBoardHeight)
//        targetHeight = min(targetHeight, 0)
//
//        UIView.animate(withDuration: 0.3) {
//            appDel.window?.frame.origin.y = targetHeight
//        }
//    }
//}


//MARK:Way2
extension UIViewController : UITextFieldDelegate, UITextViewDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.keyBoardUp(control: textField)
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        self.keyBoardUp(control: textView)
        
    }
    
    func keyBoardUp(control : UIView) {
        
        if appDel.controlView == nil {
            //키보드를 새로 띄울때
            appDel.controlView = control
        }else{
            //키보드가 이미 띄워져 있을때
            appDel.controlView = control
            
            //방향 새로 조정
            appDel.keyBoardUp(animated: true)
        }
    }
    
    
}

extension AppDelegate {
    
    struct AssociatedKeys {
        static var keyBoardHeight: UInt8 = 0
        static var controlView: UInt8 = 1
        
    }
    
    var controlView : UIView? {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.controlView) as? UIView else { return nil }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.controlView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var keyBoardHeight : CGFloat?
    {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.keyBoardHeight) as? CGFloat else { return nil }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.keyBoardHeight, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    func addKeyboardObserver(){
        
        NotificationCenter.default.addObserver(forName:
        UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (noti : Notification) in
            if let keyBoardNSRect = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                self.keyBoardHeight = keyBoardNSRect.cgRectValue.size.height

                self.keyBoardUp()
                
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (noti : Notification) in
            self.controlView = nil
            appDel.window?.frame.origin.y = 0
            
        }
    }
    
    func keyBoardUp(animated : Bool = false){
        
        if let control = self.controlView, let keyBoardHeight = self.keyBoardHeight {
            
            let margin : CGFloat = 20
            
            let keyBoardHeight : CGFloat = keyBoardHeight + margin
            
            let textControlMaxY = (appDel.window?.rootViewController?.view.convert(control.frame, from: control.superview!).maxY)!
            var targetHeight = (UIScreen.main.bounds.size.height - textControlMaxY) - keyBoardHeight
            targetHeight = max(targetHeight, -keyBoardHeight)
            targetHeight = min(targetHeight, 0)
            
            if animated {
                UIView.animate(withDuration: 0.3) { appDel.window?.frame.origin.y = targetHeight }
            }else{
                appDel.window?.frame.origin.y = targetHeight
            }
        }
    }
}

//extension UIView {
//    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            if !touch.view!.isKind(of: UITextField.self) || !touch.view!.isKind(of: UITextView.self) {
//                appDel.controlView?.resignFirstResponder()
//            }
//        }
//    }
//}
