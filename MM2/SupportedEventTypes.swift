//
//  SupportedEventTypes.swift
//  MM2
//
//  Created by 2fletch on 2020-12-16.
//

import Foundation
import CoreGraphics

enum SupportedEventTypess {
    static let mouseTypes: [CGEventType] = {
        return [
            CGEventType.mouseMoved,
            CGEventType.leftMouseDown,
            CGEventType.rightMouseDown,
            CGEventType.leftMouseUp,
            CGEventType.rightMouseUp,
            CGEventType.leftMouseDragged,
            CGEventType.rightMouseDragged,
            CGEventType.scrollWheel
        ]
    }()
    
    static let keyTypes: [CGEventType] = {
        return [
            CGEventType.keyDown
        ]
    }()
    
    static let allTypes: [CGEventType] = {
        return mouseTypes + keyTypes
    }()
}

extension SupportedEventTypess {
    static func isMouseEvent(_ event: CGEvent, excludeScroll: Bool = false) -> Bool {
        guard SupportedEventTypess.mouseTypes.contains(event.type) else {
            return false
        }
        
        if event.type == CGEventType.scrollWheel && excludeScroll == true {
            return false
        }
        
        return true
    }
}

extension Array where Element == CGEventType {
    var masked: CGEventMask {
        var ret = CGEventMask(0)
        for type in self {
            ret |= (1 << type.rawValue)
        }
        return ret
    }
}

extension CGEventType {
    var eventTypeName: String {
        var ret = ""
        switch self {
        case .null:
            ret = "null"
        case .leftMouseDown:
            ret = "leftMouseDown"
        case .leftMouseUp:
            ret = "leftMouseUp"
        case .rightMouseDown:
            ret = "rightMouseDown"
        case .rightMouseUp:
            ret = "rightMouseUp"
        case .mouseMoved:
            ret = "mouseMoved"
        case .leftMouseDragged:
            ret = "leftMouseDragged"
        case .rightMouseDragged:
            ret = "rightMouseDragged"
        case .keyDown:
            ret = "keyDown"
        case .keyUp:
            ret = "keyUp"
        case .flagsChanged:
            ret = "flagsChanged"
        case .scrollWheel:
            ret = "scrollWheel"
        case .tabletPointer:
            ret = "tabletPointer"
        case .tabletProximity:
            ret = "tabletProximity"
        case .otherMouseDown:
            ret = "otherMouseDown"
        case .otherMouseUp:
            ret = "otherMouseUp"
        case .otherMouseDragged:
            ret = "otherMouseDragged"
        case .tapDisabledByTimeout:
            ret = "tapDisabledByTimeout"
        case .tapDisabledByUserInput:
            ret = "tapDisabledByUserInput"
        default:
            ret = "[UKNOWN - \(self.rawValue)]"
        }
        return "CGEventType." + ret
    }
}
