//
//  ToastView.swift
//  KSR
//
//  Created by m2comm on 2018. 7. 2..
//  Copyright © 2018년 m2community. All rights reserved.
//

import Foundation

func toastShow( message : String ){
    let themeToast = ToastView.makeText(message, (UIApplication.shared.delegate as! AppDelegate).window, UIColor.black.withAlphaComponent(0.7))
    themeToast?.show(toastGravityBottom, toastDurationShort)
}

