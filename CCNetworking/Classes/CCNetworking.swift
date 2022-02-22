//
//  CCNetworking.swift
//  CCNetworking
//
//  Created by ZCZ on 2022/2/22.
//

import UIKit
import CCConfigSetting

typealias CCSuccess = ([String: Any]?)->Void
typealias CCFailure = (Any?)->Void

class CCNetworking: NSObject {
    
    class func POST(_ path: String = "", param: [String: Any], success: CCSuccess?, failure: CCFailure?) {
        
        if let data = try? JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.fragmentsAllowed) {
            let jsonStr = String(data: data, encoding: .utf8) ?? ""
            let jsonString = "data=\(jsonStr)"
            let newString = jsonString.replacingOccurrences(of: "\\/", with: "/")
            let newData = newString.data(using: String.Encoding.utf8)!

            let session = URLSession.shared
            var url = ccBaseURL
            if path.isEmpty == false {
                url = url.appendingPathComponent(path)
            }
            
            var request = URLRequest.init(url: url)
            request.httpMethod = "POST"
            request.httpBody = newData
                        
            let task = session.dataTask(with: request) { (backData, response, error) in
                if let data = backData {
                    DispatchQueue.main.async {
                        let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                        if let dic = dict, let suc = dic?["Succeed"] as? Bool, suc == true {
                            success?(dic)
                        } else {
                            failure?(error ?? "请求失败,请稍后重试!")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        failure?(error?.localizedDescription)
                    }
                }
            }
            
            task.resume()
        } else {
            failure?("数据格式错误")
        }
    }
    
    class func POSTMoblie(param: [String: Any], success: CCSuccess?, failure: CCFailure?) {
        POST("/mobile", param: param, success: success, failure: failure)
    }
    
}