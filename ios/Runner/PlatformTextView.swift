//
//  PlatformTextView.swift
//  Runner
//
//  Created by Wiki on 2020/2/2.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation
import Flutter
class PlatformTextView: NSObject,FlutterPlatformView {
    let frame: CGRect;
    let viewId: Int64;
    var text:String = "iOS Label"

    init(_ frame: CGRect,viewID: Int64,args :Any?) {
        self.frame = frame
        self.viewId = viewID
        if(args is NSDictionary){
            let dict = args as! NSDictionary
            if(dict.allKeys(for: "text").count > 0){
                self.text = dict.value(forKey: "text") as! String
            }
        }
    }
    func view() -> UIView {
        let label = UILabel()
        label.text = self.text
        label.textColor = UIColor.red
        label.frame = self.frame
        return label
    }
}
