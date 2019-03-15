//
//  FormatTest.swift
//  PomodoroTests
//
//  Created by Sonnie Hiles on 26/02/2019.
//  Copyright © 2019 Sonnie Hiles. All rights reserved.
//

import XCTest
@testable import Pomodoro

class FormatTest: XCTestCase {

    func testWithLengthInHoursAndMinutesWords() {
        let expected = "1 hour, 1 minute"
        XCTAssertEqual(expected, Format.timeToStringWords(seconds: 3660))
    }
    
    func testWithLengthInDaysAndHoursWords() {
        let expected = "7 days, 55 minutes"
        XCTAssertEqual(expected, Format.timeToStringWords(seconds: 608100))
    }
    
    func testWithLengthInMinutes(){
        let expected = "2:05"
        XCTAssertEqual(expected, Format.timeToString(seconds: 125))
    }
    
    func testWithLengthInSeconds(){
        let expected = "59"
        XCTAssertEqual(expected, Format.timeToString(seconds: 59))
    }
}