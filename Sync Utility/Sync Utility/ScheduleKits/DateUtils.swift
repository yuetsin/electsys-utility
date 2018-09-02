//
//  DateUtils.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/9/2.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation
import EventKit

func addToCalendar(date: Date,
                   title: String,
                   place: String,
                   start: Time,
                   end: Time,
                   remindType: remindType) {
    let eventStore = EKEventStore()
    // request access to system library
    
    let calendarTitle = "jAccount 同步"
    
    eventStore.requestAccess(to: .event) {(granted, error) in
        
        if ((error) != nil) {
            return
        } else if (!granted) {
            return
        } else {
            let event = EKEvent(eventStore: eventStore)
            event.title = title
            event.location = place
            event.calendar = eventStore.defaultCalendarForNewEvents
            let dateFormatter = DateFormatter()
            let timeAndDateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            timeAndDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = dateFormatter.string(from: date)
            let startDate = timeAndDateFormatter.date(from: "\(dateString) \(start.getTimeString())")
            let endDate = timeAndDateFormatter.date(from: "\(dateString) \(end.getTimeString())")
//            print("startDate = \(startDate), endDate = \(endDate)")
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
            
            var calendar: EKCalendar?
            for cal in eventStore.calendars(for: .event) {
                if cal.calendarIdentifier == UserDefaults.standard.string(forKey: "EventTrackerPrimaryCalendar") {
                    calendar = cal
                }
            }
            do {
                if calendar == nil {
                    calendar = EKCalendar(for: .event, eventStore: eventStore)
                    calendar!.title = calendarTitle
                    let sourceInEventStore = eventStore.sources
                    calendar!.source = sourceInEventStore.filter {
                        (source: EKSource) -> Bool in
                        source.sourceType.rawValue == EKSourceType.local.rawValue
                    }.first!
                    try eventStore.saveCalendar(calendar!, commit: true)
                    UserDefaults.standard.set(calendar!.calendarIdentifier, forKey: "EventTrackerPrimaryCalendar")
                }
                event.calendar = calendar
                try eventStore.save(event, span: .futureEvents, commit: true)
                print("成了")
            } catch let error as NSError {
                print("没成: Error:\(error)")
                
            }
        }
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
