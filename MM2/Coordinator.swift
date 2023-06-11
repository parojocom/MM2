//
//  Coordinator.swift
//  MM2
//
//  Created by 2fletch on 2020-12-16.
//

import Foundation
import CoreGraphics

class Coordinator {
    let startDate: Date
    let endDate: Date?
    let startDelay: TimeInterval
    
    static let eventSrcUserData: Int64 = 1234567890987654321
    
    let eventSource: CGEventSource? = {
        let ret = CGEventSource(stateID: CGEventSourceStateID.privateState)
        ret?.userData = Coordinator.eventSrcUserData
        return ret
    }()
    
    var lastMoved: TimeInterval = 0
    var moveInterval: TimeInterval = 0.0333
    #if DEBUG
    var pauseInterval: TimeInterval = 10.0
    #else
    var pauseInterval: TimeInterval = 60.0
    #endif
    
    var stepSize: CGFloat = 2
    
    var currDirectionX: CGFloat = 1
    var currDirectionY: CGFloat = 1
    
    var currPoint = CGPoint(x: 0, y: 0)
    
    private(set) var timer: CFRunLoopTimer?
    
    var bounds: CGRect = CGRect(x: 0, y: 0, width: 1024, height: 768)
    
    var minX: CGFloat {
        return bounds.origin.x
    }
    
    var minY: CGFloat {
        return bounds.origin.y
    }
    
    var maxX: CGFloat {
        return bounds.origin.x + bounds.width
    }
    var maxY: CGFloat {
        return bounds.origin.y + bounds.height
    }
    
    init(startDate: Date, endDate: Date?, startDelay: TimeInterval, moveInterval: TimeInterval?, moveStep: CGFloat?, pauseInterval: TimeInterval?) {
        self.startDate = startDate
        self.endDate = endDate
        self.startDelay = startDelay
        
        if let moveInterval = moveInterval {
            self.moveInterval = moveInterval
        }
        
        if let moveStep = moveStep {
            self.stepSize = moveStep
        }
        
        if let pauseInterval = pauseInterval {
            self.pauseInterval = pauseInterval
        }
    }
    
    func start() {
        let now = Date().timeIntervalSince1970
        updateBounds()
        lastMoved = startDelay > 0 ? (now + startDelay) : (now - moveInterval)
        createTimer()
    }
}

extension Coordinator: EventHandler {

    func handleEvent(_ event: CGEvent, proxy: CGEventTapProxy) -> Bool {
        if event.getIntegerValueField(CGEventField.eventSourceUserData) != Coordinator.eventSrcUserData {
            processRealEvent(event)
            return false
        }
        return true
    }
    
    func processRealEvent(_ event: CGEvent) {
        let now = Date().timeIntervalSince1970
        lastMoved = now + pauseInterval
        
        if SupportedEventTypess.isMouseEvent(event, excludeScroll: true) {
            setCurrentPosition(event.location)
        }
    }
}

extension Coordinator: MMRunLoopTimerProvider {
    var timers: [CFRunLoopTimer] {
        guard let timer = timer else {
            return []
        }
        return [timer]
    }
    
    func createTimer() {
        let timerInterval = moveInterval// 1.0 / 33.0
        timer = CFRunLoopTimerCreate(kCFAllocatorDefault, 0, timerInterval, 0, 0, { (timer, refCon) in
            timer?.mmCoordinator?.onTick()
        }, nil)
        timer?.mmCoordinator = self
    }
    
    func onTick() {
        let now = Date().timeIntervalSince1970
        
        if let endTime = endDate?.timeIntervalSince1970, endTime <= now {
            MMPrint("** MM - Ending - \(Date().mmoveDateString)")
            exit(0)
        }

        guard lastMoved < 1.0 || (lastMoved /*+ moveInterval*/) <= now else {
            MMDebugPrint("** MM - next move in: \((lastMoved + moveInterval) - now)")
            return
        }
        
        lastMoved = now
        
        updateCurrentPosition()
        
        moveTo(point: currPoint)
    }
    
    func moveTo(point: CGPoint) {
        let event = CGEvent.init(mouseEventSource: eventSource, mouseType: CGEventType.mouseMoved, mouseCursorPosition: point, mouseButton: CGMouseButton.left)
        
        event?.post(tap: CGEventTapLocation.cghidEventTap)
    }
    
    func updateCurrentPosition() {
        if (currPoint.x + (stepSize * currDirectionX)) > maxX || (currPoint.x + (stepSize * currDirectionX)) < minX {
            currDirectionX *= -1
        }
        
        if (currPoint.y + (stepSize * currDirectionY)) > maxY || (currPoint.y + (stepSize * currDirectionY)) < minY {
            currDirectionY *= -1
        }
        
        currPoint.x += (stepSize * currDirectionX)
        currPoint.y += (stepSize * currDirectionY)
    }
    
    func setCurrentPosition(_ point: CGPoint) {
        currPoint.x = max(minX, min(maxX, point.x.rounded()))
        currPoint.y = max(minY, min(maxY, point.y.rounded()))
    }
    
    func updateBounds() {
        let id = CGMainDisplayID()
        bounds = CGDisplayBounds(id)
        currPoint = CGPoint(x: minX, y: minY)
        currDirectionX = 1
        currDirectionY = 1
        MMDebugPrint("** MM - Display Bounds - \(bounds)")
    }
}

private extension CFRunLoopTimer {
    struct Associated {
        static var key = "pc_loop_key"
    }
    
    var mmCoordinator: Coordinator? {
        set {
            objc_setAssociatedObject(self, &Associated.key, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &Associated.key) as? Coordinator
        }
    }
}
