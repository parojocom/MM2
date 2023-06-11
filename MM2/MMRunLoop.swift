//
//  MMRunLoop.swift
//  MM2
//
//  Created by 2fletch on 2020-12-16.
//

import Foundation

protocol MMRunLoopSourceProvider: AnyObject {
    var sources: [CFRunLoopSource] { get }
}

protocol MMRunLoopTimerProvider: AnyObject {
    var timers: [CFRunLoopTimer] { get }
}

class MMRunLoop {
    weak var sourceProvider: MMRunLoopSourceProvider?
    weak var timerProvider: MMRunLoopTimerProvider?
    
    func run() {
        createLoops()
    }
    
    private func createLoops() {
        let runLoop = RunLoop.current.getCFRunLoop()
        let srcs = sourceProvider?.sources ?? []
        let timers = timerProvider?.timers ?? []
        
        for src in srcs {
            CFRunLoopAddSource(runLoop, src, CFRunLoopMode.commonModes)
        }
        
        for timer in timers {
            CFRunLoopAddTimer(runLoop, timer, CFRunLoopMode.commonModes)
        }
        
        CFRunLoopRun()
    }
}
