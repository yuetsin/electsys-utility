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

    var calIdentifier: String = ""
    let calIdentifierKey = "CalendarIdentifierKey"
    let eventStore = EKEventStore()
    let defaultCalendarTitle = "jAccount 同步"
    weak var delegate: writeCalendarDelegate?
    
    func initializeCalendar(name: String, type: EKSourceType) -> EKCalendar? {
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        if name.isEmpty {
            newCalendar.title = defaultCalendarTitle
        } else {
            newCalendar.title = name
        }
        let sourcesInEventStore = eventStore.sources
        newCalendar.source = sourcesInEventStore.filter{
            (source: EKSource) -> Bool in
            source.sourceType.rawValue == type.rawValue
            }.first!
        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            return newCalendar
        } catch {
//            print("Calendar cannot be saved.")
        }
        return nil
    }

    func addToCalendar(date: Date,
                       title: String,
                       place: String,
                       start: Time,
                       end: Time,
                       remindType: remindType,
                       in Calendar: EKCalendar) {
        
        // request access to system library
        
       
        
        eventStore.requestAccess(to: .event) {(granted, error) in
            
            if ((error) != nil) {
                return
            } else if (!granted) {
                return
            } else {
                let event = EKEvent(eventStore: self.eventStore)
                event.calendar = Calendar
                event.title = title
                event.location = place
                event.calendar = Calendar
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
//                    print("Event could not save. Error: \(error as NSError).localizedDescription")
                }
            }
        }
    }
    func commitChanges() {
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
