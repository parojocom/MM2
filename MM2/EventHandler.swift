//
//  EventHandler.swift
//  MM2
//
//  Created by 2fletch on 2020-12-16.
//

import Foundation
import CoreGraphics

protocol EventHandler: AnyObject {
    var eventsOfInterest: [CGEventType] { get }
    
    func handleEvent(_ event: CGEvent, proxy: CGEventTapProxy) -> Bool
}
extension EventHandler {
    var eventsOfInterest: [CGEventType] {
        return SupportedEventTypess.allTypes
    }
}
