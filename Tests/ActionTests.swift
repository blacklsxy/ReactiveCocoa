//
//  ActionTests.swift
//  Rex
//
//  Created by Ilya Laryionau on 4/20/16.
//  Copyright © 2016 Neil Pankey. All rights reserved.
//

@testable import Rex
import ReactiveCocoa
import XCTest
import enum Result.NoError

final class ActionTests: XCTestCase {
    
    enum TestError: ErrorType {
        case Unknown
    }

    func testStarted() {
        let action = Action<Void, Void, NoError> { .empty }

        var started = false
        action
            .rex_started
            .observeNext { started = true }

        action
            .apply()
            .start()

        XCTAssertTrue(started)
    }
    
    func testCompleted() {
        let (producer, sink) = SignalProducer<Int, TestError>.buffer(Int.max)
        let action = Action { producer }

        var completed = false
        action
            .rex_completed
            .observeNext { completed = true }

        action
            .apply()
            .start()
        
        sink.sendNext(1)
        XCTAssertFalse(completed)

        sink.sendCompleted()
        XCTAssertTrue(completed)
    }
    
    func testCompletedOnFailed() {
        let (producer, sink) = SignalProducer<Int, TestError>.buffer(Int.max)
        let action = Action { producer }
        
        var completed = false
        action
            .rex_completed
            .observeNext { completed = true }

        action
            .apply()
            .start()
        
        sink.sendFailed(.Unknown)
        XCTAssertFalse(completed)
    }
}
