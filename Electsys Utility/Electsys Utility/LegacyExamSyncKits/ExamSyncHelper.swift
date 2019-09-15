//
//  ExamSyncHelper.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/9/6.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation
import Alamofire

let examRequestUrl = "http://electsys.sjtu.edu.cn/edu/student/examArrange/examArrange.aspx"


class ExamSync {
    
    var delegate: examQueryDelegate?
    
    func getExamData(year: Year, term: Term) {

        Alamofire.request(examRequestUrl).responseData(completionHandler: { response in
            if response.response == nil {
                self.delegate?.parseResponse(examData: "")
                return
            }
            // 从这个页面中获取 __VIEWSTATE、__VIEWSTATEGENERATOR 和 __EVENTVALIDATION。
            let realOutput = String(data: response.data!, encoding: .utf8)!
            //                        print(realOutput)
            let viewState = getByXpath(realOutput, "//*[@id=\"__VIEWSTATE\"]/@value")
            let viewStateGenerator = getByXpath(realOutput, "//*[@id=\"__VIEWSTATEGENERATOR\"]/@value")
            let eventValidation = getByXpath(realOutput, "//*[@id=\"__EVENTVALIDATION\"]/@value")
            print("__VIEWSTATE: \(viewState)")
            print("__VIEWSTATEGENERATOR: \(viewStateGenerator)")
            print("__EVENTVALIDATION: \(eventValidation)")
            let postParams: Parameters = [
                "__VIEWSTATE": viewState,
                "__VIEWSTATEGENERATOR": viewStateGenerator,
                "__EVENTVALIDATION": eventValidation,
                "dpXn": ConvertToString(year),
                "dpXq": String(term.rawValue),
                "btnQuery": "查 询"
            ]
            Alamofire.request(examRequestUrl, method: .post, parameters: postParams, encoding: URLEncoding.httpBody).responseData(completionHandler: { response in
                self.delegate?.parseResponse(examData: String(data: response.data!, encoding: .utf8)!)
            })
        })
    }
}
