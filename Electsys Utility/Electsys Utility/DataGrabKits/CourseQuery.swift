//
//  CourseQuery.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/9/5.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation
import Alamofire

// bsid 从 330001 开始往后递增遍历就能得到所有课程信息。（但是！没有教室信息 深坑）
let dataGrabUrlHead = "http://electsys.sjtu.edu.cn/edu/lesson/viewLessonArrangeDetail2.aspx?bsid="


// 这个网站很废…说是按教室查找但根本做不到单独获取教室信息。就不用他好了
let searchWithClassroom = "http://electsysq.sjtu.edu.cn/ReportServer/Pages/ReportViewer.aspx?%2fExamArrange%2fLessonArrangeForOthers&rs:Command=Render"

// 教室信息得来这里用课号得到真·详细信息。
let searchWithCourseCode = "http://electsys.sjtu.edu.cn/edu/lesson/LessonQuery.aspx"


// 获取老师评教信息。
let teacherEvaluate = "http://electsys.sjtu.edu.cn/edu/teacher/teacherEvaluateResult.aspx?"
// 后面用gh=(工号)&xm=(名字) 获取信息

// 最早的 bsid 从 330001 开始。
let firstBsid = 330001

class Query {
    
    var delegate: queryDelegate?

    func start(Bsid: Int) {
        let requestUrl = "\(dataGrabUrlHead)\(Bsid)"
        print("Attempted to request \(requestUrl)")
        Alamofire.request(requestUrl).responseData(completionHandler: { response in
            let output = String(data: response.data!, encoding: .utf8)!
            //                        print(realOutput)
            self.delegate?.judgeResponse(htmlData: output)
        })
    }
}
