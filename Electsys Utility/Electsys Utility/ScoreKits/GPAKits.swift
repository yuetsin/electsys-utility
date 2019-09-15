//
//  GPAKits.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/15.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Foundation

class GPAKits {
    static let GpaStrategies: [String] = ["标准 4.0 制",
                                          "改进 4.0 制（第一类）",
                                          "改进 4.0 制（第二类）",
                                          "北京大学 4.0 制",
                                          "加拿大 4.3 制",
                                          "中国科学技术大学 4.3 制",
                                          "上海交通大学 4.3 制"]

    static func calculateGpa(scores: [NGScore]) -> Double? {
        var totalGradePoints: Double = 0.0
        var creditCount: Float = 0.0
        switch PreferenceKits.gpaStrategy {
        case .Canadian_4_3:
            for score in scores {
                if score.finalScore == nil || score.credit == nil {
                    continue
                }
                creditCount += score.credit!
                switch score.finalScore! {
                case 60 ..< 65:
                    totalGradePoints += 2.3 * Double(score.credit!)
                case 65 ..< 70:
                    totalGradePoints += 2.7 * Double(score.credit!)
                case 70 ..< 75:
                    totalGradePoints += 3.0 * Double(score.credit!)
                case 75 ..< 80:
                    totalGradePoints += 3.3 * Double(score.credit!)
                case 80 ..< 85:
                    totalGradePoints += 3.7 * Double(score.credit!)
                case 85 ..< 90:
                    totalGradePoints += 4.0 * Double(score.credit!)
                case 90 ... 100:
                    totalGradePoints += 4.3 * Double(score.credit!)
                default: break
                    // do nothing
                }
            }
        case .Normal_4_0:
            for score in scores {
                if score.finalScore == nil || score.credit == nil {
                    continue
                }
                creditCount += score.credit!
                switch score.finalScore! {
                case 60 ..< 70:
                    totalGradePoints += 1.0 * Double(score.credit!)
                case 70 ..< 80:
                    totalGradePoints += 2.0 * Double(score.credit!)
                case 80 ..< 90:
                    totalGradePoints += 3.0 * Double(score.credit!)
                case 90 ... 100:
                    totalGradePoints += 4.0 * Double(score.credit!)
                default: break
                    // do nothing
                }
            }
        case .Improved_4_0_A:
            for score in scores {
                if score.finalScore == nil || score.credit == nil {
                    continue
                }
                creditCount += score.credit!
                switch score.finalScore! {
                case 60 ..< 70:
                    totalGradePoints += 2.0 * Double(score.credit!)
                case 70 ..< 85:
                    totalGradePoints += 3.0 * Double(score.credit!)
                case 85 ... 100:
                    totalGradePoints += 4.0 * Double(score.credit!)
                default: break
                }
            }
        case .Improved_4_0_B:
            for score in scores {
                if score.finalScore == nil || score.credit == nil {
                    continue
                }
                creditCount += score.credit!
                switch score.finalScore! {
                case 60 ..< 75:
                    totalGradePoints += 2.0 * Double(score.credit!)
                case 75 ..< 85:
                    totalGradePoints += 3.0 * Double(score.credit!)
                case 85 ... 100:
                    totalGradePoints += 4.0 * Double(score.credit!)
                default: break
                }
            }
        case .PKU_4_0:
            for score in scores {
                if score.finalScore == nil || score.credit == nil {
                    continue
                }
                creditCount += score.credit!
                switch score.finalScore! {
                case 60 ..< 64:
                    totalGradePoints += 1.0 * Double(score.credit!)
                case 64 ..< 68:
                    totalGradePoints += 1.5 * Double(score.credit!)
                case 68 ..< 72:
                    totalGradePoints += 2.0 * Double(score.credit!)
                case 72 ..< 75:
                    totalGradePoints += 2.3 * Double(score.credit!)
                case 75 ..< 78:
                    totalGradePoints += 2.7 * Double(score.credit!)
                case 78 ..< 82:
                    totalGradePoints += 3.0 * Double(score.credit!)
                case 82 ..< 85:
                    totalGradePoints += 3.3 * Double(score.credit!)
                case 85 ..< 90:
                    totalGradePoints += 3.7 * Double(score.credit!)
                case 90 ... 100:
                    totalGradePoints += 4.0 * Double(score.credit!)
                default: break
                }
            }
        case .USTC_4_3:
            for score in scores {
                if score.finalScore == nil || score.credit == nil {
                    continue
                }
                creditCount += score.credit!
                switch score.finalScore! {
                case 60 ..< 61:
                    totalGradePoints += 1.0 * Double(score.credit!)
                case 61 ..< 64:
                    totalGradePoints += 1.3 * Double(score.credit!)
                case 64 ..< 65:
                    totalGradePoints += 1.5 * Double(score.credit!)
                case 65 ..< 68:
                    totalGradePoints += 1.7 * Double(score.credit!)
                case 68 ..< 72:
                    totalGradePoints += 2.0 * Double(score.credit!)
                case 72 ..< 75:
                    totalGradePoints += 2.3 * Double(score.credit!)
                case 75 ..< 78:
                    totalGradePoints += 2.7 * Double(score.credit!)
                case 78 ..< 82:
                    totalGradePoints += 3.0 * Double(score.credit!)
                case 82 ..< 85:
                    totalGradePoints += 3.3 * Double(score.credit!)
                case 85 ..< 90:
                    totalGradePoints += 3.7 * Double(score.credit!)
                case 90 ..< 95:
                    totalGradePoints += 4.0 * Double(score.credit!)
                case 95 ... 100:
                    totalGradePoints += 4.3 * Double(score.credit!)
                default: break
                }
            }
        case .SJTU_4_3:
            for score in scores {
                if score.finalScore == nil || score.credit == nil {
                    continue
                }
                creditCount += score.credit!
                switch score.finalScore! {
                case 60 ..< 62:
                    totalGradePoints += 1.0 * Double(score.credit!)
                case 62 ..< 65:
                    totalGradePoints += 1.7 * Double(score.credit!)
                case 65 ..< 67:
                    totalGradePoints += 2.0 * Double(score.credit!)
                case 67 ..< 70:
                    totalGradePoints += 2.3 * Double(score.credit!)
                case 70 ..< 75:
                    totalGradePoints += 2.7 * Double(score.credit!)
                case 75 ..< 80:
                    totalGradePoints += 3.0 * Double(score.credit!)
                case 80 ..< 85:
                    totalGradePoints += 3.3 * Double(score.credit!)
                case 85 ..< 90:
                    totalGradePoints += 3.7 * Double(score.credit!)
                case 90 ..< 95:
                    totalGradePoints += 4.0 * Double(score.credit!)
                case 95 ... 100:
                    totalGradePoints += 4.3 * Double(score.credit!)
                default: break
                }
            }
        }

        if creditCount == 0.0 {
            return nil
        }
        
        return totalGradePoints / Double(creditCount)
    }
}
