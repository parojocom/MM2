//
//  EventListener.swift
//  MM2
//
//  Created by 2fletch on 2020-12-16.
//

import Foundation
import CoreGraphics

class EventListener: MMRunLoopSourceProvider {
    static let instance: EventListener = EventListener()
    
    private(set) var runloopSource: CFRunLoopSource?
    private(set) var tapListener: CFMachPort?
    
    weak var eventHandler: EventHandler?

    var sources: [CFRunLoopSource] {
        guard let loopSource = runloopSource else {
            return []
        }
        return [loopSource]
    }
    
    private init() {
        setupLoopSource()
    }
    
    
    func setupLoopSource() {
        guard tapListener == nil else {
            return
        }
        
        let tapLocation: CGEventTapLocation = CGEventTapLocation.cghidEventTap
        let tapPlace: CGEventTapPlacement = CGEventTapPlacement.headInsertEventTap
        let options: CGEventTapOptions = CGEventTapOptions.listenOnly
        
        let eventsOfInterest = (eventHandler?.eventsOfInterest ?? SupportedEventTypess.allTypes).masked
        
        func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
            guard EventListener.instance.handleEvent(event, proxy: proxy) == true else {
                return Unmanaged.passRetained(event)
            }
            return nil
        }
        
        tapListener = CGEvent.tapCreate(tap: tapLocation, place: tapPlace, options: options, eventsOfInterest: eventsOfInterest, callback: handleEvent, userInfo: nil)
        
        
        runloopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tapListener!, 0)
        
        CGEvent.tapEnable(tap: tapListener!, enable: true)
    }
    
    func handleEvent(_ event: CGEvent, proxy: CGEventTapProxy) -> Bool {
        return eventHandler?.handleEvent(event, proxy: proxy) ?? false
    }
}
