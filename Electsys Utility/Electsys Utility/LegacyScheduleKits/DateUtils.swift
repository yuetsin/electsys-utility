//
//  DateUtils.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/9/2.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation
import EventKit

class CalendarHelper {

    let eventStore = EKEventStore()
    let defaultCalendarTitle = "jAccount 同步"
    var calendar: EKCalendar?
    weak var delegate: writeCalendarDelegate!
    
    init (name: String, type: EKSourceType, delegate: writeCalendarDelegate) {
        self.delegate = delegate
        eventStore.requestAccess(to: .event) {(granted, error) in
            if ((error) != nil) {
                self.delegate?.showError(error: "哎呀！Sync Utility 没有权限访问您的日历。\n请在「系统偏好设置」-「安全性与隐私」中给予权限，然后再启动 Sync Utility。")
                return
            } else if (!granted) {
                self.delegate?.showError(error: "哎呀！Sync Utility 没有权限访问您的日历。\n请在「系统偏好设置」-「安全性与隐私」中给予权限，然后再启动 Sync Utility。")
                return
            } else {
                let newCalendar = EKCalendar(for: .event, eventStore: self.eventStore)
                if name.isEmpty {
                    newCalendar.title = self.defaultCalendarTitle
                } else {
                    newCalendar.title = name
                }
                let sourcesInEventStore = self.eventStore.sources
                newCalendar.source = sourcesInEventStore.filter{
                    (source: EKSource) -> Bool in
                    source.sourceType.rawValue == type.rawValue
                    }.first
                if newCalendar.source == nil {
                    self.delegate?.showError(error: "哎呀！Sync Utility 无法创建这个日历。\n请检查 Calendar.app 的账户权限。")
                    return
                }
                do {
                    try self.eventStore.saveCalendar(newCalendar, commit: true)
                    self.calendar = newCalendar
                } catch {
                    self.delegate?.showError(error: "哎呀！Sync Utility 无法保存到指定的日历。\n请检查 Calendar.app 的账户权限。")
                }
            }
            self.delegate?.startWriteCalendar()
        }
    }

    func addToCalendar(date: Date,
                       title: String,
                       place: String,
                       start: Time,
                       end: Time,
                       remindType: remindType
                       ) {
        
        // request access to system library
        
       
        
        eventStore.requestAccess(to: .event) {(granted, error) in
            if ((error) != nil) {
                self.delegate?.showError(error: "哎呀！Sync Utility 没有权限访问您的日历。\n请在「系统偏好设置」-「安全性与隐私」中给予权限，然后再启动 Sync Utility。")
                return
            } else if (!granted) {
                self.delegate?.showError(error: "哎呀！Sync Utility 没有权限访问您的日历。\n请在「系统偏好设置」-「安全性与隐私」中给予权限，然后再启动 Sync Utility。")
                return
            } else {
                let event = EKEvent(eventStore: self.eventStore)
                event.calendar = self.calendar
                event.title = title
                event.location = place
                event.calendar = self.calendar
                let dateFormatter = DateFormatter()
                let timeAndDateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                timeAndDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let dateString = dateFormatter.string(from: date)
                let startDate = timeAndDateFormatter.date(from: "\(dateString) \(start.getTimeString())")
                let endDate = timeAndDateFormatter.date(from: "\(dateString) \(end.getTimeString())")
//                print("startDate = \(startDate), endDate = \(endDate)")
                event.startDate = startDate!
                event.endDate = endDate!

                switch remindType {
                case .atCourseStarts:
                    let alarm = EKAlarm(relativeOffset: 0)
                    event.addAlarm(alarm)
                    break
                case .fifteenMinutes:
                    let alarm = EKAlarm(relativeOffset: -900.0)
                    event.addAlarm(alarm)
                    break
                case .tenMinutes:
                    let alarm = EKAlarm(relativeOffset: -600.0)
                    event.addAlarm(alarm)
                    break
                default:
                    break
                }
                do {
                    try self.eventStore.save(event, span: .thisEvent, commit: true)
                    self.delegate?.didWriteEvent(title: event.title)
                } catch {
                    print("Event could not be saved.")
                }
            }
        }
    }
    
    func addToDate(exam: Exam, remind: Bool) {
        eventStore.requestAccess(to: .event) {(granted, error) in
            if ((error) != nil) {
                self.delegate?.showError(error: "哎呀！Sync Utility 没有权限访问您的日历。\n请在「系统偏好设置」-「安全性与隐私」中给予权限，然后再启动 Sync Utility。")
                return
            } else if (!granted) {
                self.delegate?.showError(error: "哎呀！Sync Utility 没有权限访问您的日历。\n请在「系统偏好设置」-「安全性与隐私」中给予权限，然后再启动 Sync Utility。")
                return
            } else {
                let event = EKEvent(eventStore: self.eventStore)
                event.calendar = self.calendar
                event.title = exam.name! + "考试"
                event.location = exam.location
                event.calendar = self.calendar
                event.startDate = exam.startDate
                event.endDate = exam.endDate
                
                if remind {
                    let alarm = EKAlarm(relativeOffset: -1800.0)
                    event.addAlarm(alarm)
                }
                do {
                    try self.eventStore.save(event, span: .thisEvent, commit: true)
                } catch {
                    print("Event could not be saved. Error: \(error as NSError)")
                }
            }
        }
    }
    
    func addToDate(exam: NGExam, remind: Bool) {
        eventStore.requestAccess(to: .event) {(granted, error) in
            if ((error) != nil) {
                self.delegate?.showError(error: "哎呀！Sync Utility 没有权限访问您的日历。\n请在「系统偏好设置」-「安全性与隐私」中给予权限，然后再启动 Sync Utility。")
                return
            } else if (!granted) {
                self.delegate?.showError(error: "哎呀！Sync Utility 没有权限访问您的日历。\n请在「系统偏好设置」-「安全性与隐私」中给予权限，然后再启动 Sync Utility。")
                return
            } else {
                let event = EKEvent(eventStore: self.eventStore)
                event.calendar = self.calendar
                event.title = exam.name! + "考试"
                event.location = exam.location
                event.calendar = self.calendar
                event.startDate = exam.startDate
                event.endDate = exam.endDate
                
                if remind {
                    let alarm = EKAlarm(relativeOffset: -1800.0)
                    event.addAlarm(alarm)
                }
                do {
                    try self.eventStore.save(event, span: .thisEvent, commit: true)
                } catch {
                    print("Event could not be saved. Error: \(error as NSError)")
                }
            }
        }
    }
    
    func commitChanges() {
//          deprecated method
//        do {
//            try self.eventStore.commit()
//        } catch {
//            print("Event could not be committed. Error: \(error as NSError).localizedDescription")
//        }
    }
}

extension Date {
    func convertWeekToDate(week: Int, weekday: Int) -> Date {
        return self.addingTimeInterval(Double(((week - 1) * 7 + weekday - 1)) * secondsInDay)
    }
}


enum remindType {
    case fifteenMinutes
    case tenMinutes
    case atCourseStarts
    case noReminder
}
