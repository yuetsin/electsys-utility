//
//  ExamKits.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/15.
//  Copyright © 2019 yuxiqian. All rights reserved.
//
import Foundation
import Alamofire
import Alamofire_SwiftyJSON
import SwiftyJSON

class ExamKits {
    static func requestExamTable(year: Int, term: Int,
                                   handler: @escaping ([NGExam]) -> Void,
                                   failure: @escaping (Int) -> Void) {
        // 1 - "3"
        // 2 - "12"
        // 3 - "16"
        if term < 1 || term > 3 {
            failure(-1)
            return
        }
        let termString = CourseConst.termTable[term]

        let getParams: Parameters = [
            "xnm": year,
            "xqm": termString,
        ]

        Alamofire.request(ExamConst.requestUrl,
                          method: .get,
                          parameters: getParams).responseSwiftyJSON(completionHandler: { responseJSON in
            if responseJSON.error == nil {
                let jsonResp = responseJSON.value
                if jsonResp != nil {

                    var examList: [NGExam] = []
                    
                    for examObject in jsonResp?["items"].arrayValue ?? [] {
                        
                        let timeString = examObject["kssj"].stringValue
                        let tokens = timeString.components(separatedBy: CharacterSet(charactersIn: "(-)")).filter({ $0 != ""})
                        if tokens.count != 5 {
                            ESLog.error("failed to parse time of `%@`. thrown.", timeString)
                            failure(-4)
                            return
                        }
                        
                        let dateStringFormatter = DateFormatter()
                        dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                        guard let startDate = dateStringFormatter.date(from: "\(tokens[0])-\(tokens[1])-\(tokens[2]) \(tokens[3])") else {
                            ESLog.error("failed to parse start date of `%@`. thrown.", timeString)
                            failure(-5)
                            return
                        }
                        
                        guard let endDate = dateStringFormatter.date(from: "\(tokens[0])-\(tokens[1])-\(tokens[2]) \(tokens[4])") else {
                            ESLog.error("failed to parse end date of %@. thrown.", timeString)
                            failure(-5)
                            return
                        }
                        
                        
                        examList.append(NGExam(name: examObject["ksmc"].stringValue,
                                               courseName: examObject["kcmc"].stringValue,
                                               courseCode: examObject["kch"].stringValue,
                                               location: examObject["cdmc"].stringValue,
                                               teacher: examObject["jsxx"].stringValue,
                                               startDate: startDate,
                                               endDate: endDate,
                                               campus: examObject["xqmc"].stringValue,
                                               originalTime: examObject["kssj"].stringValue))
                    }
                    handler(examList)
                } else {
                    failure(-3)
                }
            } else {
                failure(-2)
            }
        })
    }
}
