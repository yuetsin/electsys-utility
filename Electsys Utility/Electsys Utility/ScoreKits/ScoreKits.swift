//
//  ScoreKits.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/15.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Foundation
import Alamofire
import Alamofire_SwiftyJSON
import SwiftyJSON

class ScoreKits {
    static func requestScoreData(year: Int, term: Int,
                                   handler: @escaping ([NGScore]) -> Void,
                                   failure: @escaping (Int) -> Void) {
        // 1 - "3"
        // 2 - "12"
        // 3 - "16"
        if term < 1 || term > 3 {
            failure(-1)
            return
        }
        let termString = ScoreConst.termTable[term]

        let getParams: Parameters = [
            "xnm": year,
            "xqm": termString,
        ]

        Alamofire.request(ScoreConst.requestUrl,
                          method: .get,
                          parameters: getParams).responseSwiftyJSON(completionHandler: { responseJSON in
            if responseJSON.error == nil {
                let jsonResp = responseJSON.value
                if jsonResp != nil {
                    
                    var scoreSheet: [NGScore] = []
                
                    for scoreObject in jsonResp?["items"].arrayValue ?? [] {
                        scoreSheet.append(NGScore(classId: scoreObject["bg"].stringValue,
                                                  scorePoint: scoreObject["jd"].floatValue,
                                                  holderSchool: scoreObject["jgmc"].stringValue,
                                                  teacher: scoreObject["jsxm"].stringValue.replacingOccurrences(of: ";", with: "、"),
                                                  courseCode: scoreObject["kch"].stringValue,
                                                  courseName: scoreObject["kcmc"].stringValue,
                                                  status: scoreObject["ksxz"].stringValue,
                                                  finalScore: scoreObject["bfzcj"].intValue,
                                                  credit: scoreObject["xf"].floatValue))
                    }
                    handler(scoreSheet)
                } else {
                    failure(-3)
                }
            } else {
                failure(-2)
            }
        })
    }
}
