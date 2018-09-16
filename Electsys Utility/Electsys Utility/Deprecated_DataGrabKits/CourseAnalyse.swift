//
//  CourseAnalyse.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/9/6.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation
import Kanna

func parseCourseDetail(_ htmlDoc: String) -> Curricula? {
    
    let curricula = Curricula()

    curricula.teacherName = getByXpath(htmlDoc,
                "//*[@id=\"TeacherInfo1_dataListT\"]/tr/td/table/tr[2]/td[2]")
    
//    curricula.codeName =
//        getByXpath(htmlDoc, "//*[@id=\"LessonArrangeDetail1_dataListKc\"]/tr/td/table/tr[1]/td[1]").deleteOccur(remove: "课程代码：")
   
    curricula.name =
        getByXpath(htmlDoc, "//*[@id=\"LessonArrangeDetail1_dataListKc\"]/tr/td/table/tr[1]/td[2]").deleteOccur(remove: "课程名称：")
    
    curricula.identifier =
        getByXpath(htmlDoc, "//*[@id=\"LessonArrangeDetail1_dataListKc\"]/tr/td/table/tr[1]/td[3]").deleteOccur(remove: "课号：")
    
    curricula.year = ConvertToYear(
        getByXpath(htmlDoc, "//*[@id=\"LessonArrangeDetail1_dataListKc\"]/tr/td/table/tr[2]/td[2]").deleteOccur(remove: "学年："))
    
    curricula.term = ConvertToTerm(
        getByXpath(htmlDoc, "//*[@id=\"LessonArrangeDetail1_dataListKc\"]/tr/td/table/tr[2]/td[3]").deleteOccur(remove: "学期："))
    
//    curricula.maximumNumber = Int(
//        getByXpath(htmlDoc, "//*[@id=\"LessonArrangeDetail1_dataListKc\"]/tr/td/table/tr[5]/td[1]").deleteOccur(remove: "最大人数："))!
    
    curricula.studentNumber = Int(
        getByXpath(htmlDoc, "//*[@id=\"LessonArrangeDetail1_dataListKc\"]/tr/td/table/tr[5]/td[2]").deleteOccur(remove: "已选课人数："))!
    
//    curricula.notes =
//        getByXpath(htmlDoc, "//*[@id=\"LessonArrangeDetail1_dataListKc\"]/tr/td/table/tr[6]/td[1]").deleteOccur(remove: "备注：")
//    if curricula.notes.contains("夏季") {
//        curricula.term = .Summer
        // 教务处不改学期字段，把信息写在备注里…… 绝了
//    }
    
    if curricula.identifier == "0" {
        return nil
    }
    
    return curricula
}

func parseTeacherDetail(_ htmlDoc: String, _ teachers: inout [Teacher]) -> Bool {
    let employeeId = getByXpath(htmlDoc, "//*[@id=\"TeacherInfo1_dataListT\"]/tr/td/table/tr[1]/td[2]")
    if findTeacherById(employeeId, &teachers) == -1 {
        // 此老师未入库，新建一条
        let teacher = Teacher()
        teacher.employeeID = employeeId
        teacher.name = getByXpath(htmlDoc, "//*[@id=\"TeacherInfo1_dataListT\"]/tr/td/table/tr[2]/td[2]")
        if getByXpath(htmlDoc, "//*[@id=\"TeacherInfo1_dataListT\"]/tr/td/table/tr[3]/td[2]") == "女" {
            teacher.gender = .Female
        } else {
            teacher.gender = .Male
        }
        teachers.append(teacher)
        return true
    }
    return false
}

func getByXpath(_ html: String, _ xpath: String) -> String {
    if let html = try? HTML(html: html, encoding: .utf8) {
        for i in html.xpath(xpath) {
            return sanitize(i.text ?? "0")
        }
    }
    return "0"
}
