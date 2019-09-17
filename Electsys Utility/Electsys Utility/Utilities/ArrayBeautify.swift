//
//  ArrayBeautify.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/17.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Foundation

class Beautify {
    static func beautifier(array: [Int]) -> [(Int, Int)] {
        if array.count == 0 {
            return []
        } else if array.count == 1 {
            return [(array.first!, array.first!)]
        }
        var begin = array.first!
        var last = array.first!

        var resultPair: [(Int, Int)] = []
        
        var firstSkip = true
        for integer in array {
            if firstSkip {
                firstSkip = false
                continue
            }
            if integer - last == 1 {
                last += 1
            } else {
                resultPair.append((begin, last))
                begin = integer
                last = integer
            }
        }
        resultPair.append((begin, last))
        return resultPair
    }
}
