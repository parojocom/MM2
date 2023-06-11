//
//  MM.swift
//  MM2
//
//  Created by 2fletch on 2020-12-13.
//

import Foundation
import ParArg

class MM {
    static let instance = MM()
    static let version: String = "1.0.0"
    
    let startTime = Date()
    var endTime: Date?
    var startDelay: TimeInterval = 0
    var moveInterval: TimeInterval?
    var moveStep: CGFloat?
    var pauseInterval: TimeInterval?

    var coordinator: Coordinator?
    var runLoop: MMRunLoop?

    func run() {
        MMPrint("** MM - Version - \(MM.version)")
        guard processParArgs() else {
            MMPrint("")
            printUsage()
            MMPrint("** MM - Done")
            return
        }
        MMPrint("** MM - Start - \(startTime.mmoveDateString)")
        if let endTime = endTime {
            MMPrint("** MM - Will end at - \(endTime.mmoveDateString)")
        } else {
            MMPrint("** MM - Will run until stopped.")
        }
        
        startRunLoop()
    }
    
    func processParArgs() -> Bool {
        let parargs = ParArg.parse(inputs: CommandLine.arguments)
        
        #if DEBUG
        MMDebugPrint("** MM - ParArgs - start ***")
        for pararg in parargs {
            MMDebugPrint("** MM - n: \(pararg.name), v: \(pararg.value ?? "nil")")
        }
        MMDebugPrint("** MM - ParArgs  -  end ***")
        #endif
        
        if parargs["-help"] != nil || parargs["--help"] != nil {
            return false
        } else if let durPararg = parargs["-d"] ?? parargs["--duration"] {
            if let durStr = durPararg.value, let durVal = TimeInterval(durStr), durVal > 0 {
                endTime = startTime.addingTimeInterval(durVal * 60)
            } else {
                MMPrint("** MM - Invalid duration. Expected positive numeric value.")
                return false
            }
        } else if let endDatePararg = parargs["-e"] ?? parargs["--endDate"] {
            let failMsg = "** MM - Expected string values such as \"2004-02-29 16:21:42\", \"16:21:42\", or epoch in seconds."
            guard let dateStr = endDatePararg.value else {
                MMPrint(failMsg)
                return false
            }
            
            if let epoch = TimeInterval(dateStr) {
                endTime = Date(timeIntervalSince1970: epoch)
            } else {
                // try parsing the string
                endTime = DateFormatter.mmoveFullDateFormatter.date(from: dateStr)
                if endTime == nil {
                    let parts = dateStr.split(separator: ":")
                    guard parts.count == 3, let hour = Int(parts[0]), let min = Int(parts[1]), let sec = Int(parts[2]) else {
                        MMPrint(failMsg)
                        return false
                    }

                    let cal = Calendar(identifier: Calendar.Identifier.gregorian)
                    let dateComps = cal.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: startTime)
                    endTime = DateComponents(calendar: cal, year: dateComps.year, month: dateComps.month, day: dateComps.day, hour: hour, minute: min, second: sec).date
                }
            }

            if let newEnd = endTime {
                if newEnd < startTime {
                    MMPrint("** MM - end time must be later than start time")
                    endTime = nil
                    return false
                }
            } else {
                MMPrint(failMsg)
                return false
            }
        }
        
        if let startDelayPararg = parargs["-s"] ?? parargs["--startDelay"] {
            if let delayStr = startDelayPararg.value, let delayVal = TimeInterval(delayStr), delayVal >= 0.0 {
                startDelay = delayVal
            } else {
                MMPrint("** MM - Invalid duration. Expected positive numeric value.")
                return false
            }
        }
        
        if let paragRaw = parargs["-i"] ?? parargs["--moveInterval"] {
            if let valStr = paragRaw.value, let val = TimeInterval(valStr), val >= 0.0 {
                moveInterval = val
            } else {
                MMPrint("** MM - Invalid duration. Expected positive numeric value.")
                return false
            }
        }
        
        if let paragRaw = parargs["-m"] ?? parargs["--moveStep"] {
            if let valStr = paragRaw.value, let val = CGFloat(valStr), val >= 0.0 {
                moveStep = val
            } else {
                MMPrint("** MM - Invalid duration. Expected positive numeric value.")
                return false
            }
        }
        
        if let paragRaw = parargs["-p"] ?? parargs["--pauseInterval"] {
            if let valStr = paragRaw.value, let val = TimeInterval(valStr), val >= 0.0 {
                pauseInterval = val
            } else {
                MMPrint("** MM - Invalid duration. Expected positive numeric value.")
                return false
            }
        }
        
        return true
    }
    
    func startRunLoop() {
        coordinator = Coordinator(startDate: startTime, endDate: endTime, startDelay: startDelay, moveInterval: moveInterval, moveStep: moveStep, pauseInterval: pauseInterval)
        runLoop = MMRunLoop()
        EventListener.instance.eventHandler = coordinator
        runLoop?.sourceProvider = EventListener.instance
        runLoop?.timerProvider = coordinator
        
        guard EventListener.instance.runloopSource != nil else {
            MMPrint("** MM - FAILED TO CREATE RUN LOOP SOURCE - STOPPING.")
            return
        }
        guard EventListener.instance.tapListener != nil else {
            MMPrint("** MM - FAILED TO CREATE TAP LISTENER - STOPPING.")
            return
        }
        
        guard coordinator?.eventSource != nil else {
            MMPrint("** MM - FAILED TO CREATE EVENT SOURCE OBJECT - STOPPING.")
            return
        }
        coordinator?.start()
        
        guard coordinator?.timer != nil else {
            MMPrint("** MM - FAILED TO CREATE TIMER OBJECT - STOPPING.")
            return
        }
        
        runLoop?.run()
    }
    
    func printUsage() {
        MMPrint("")
        MMPrint("** MM - USAGE - START **************************")
        MMPrint("**")
        MMPrint("** --help" + "           " + "Shows usage screen.")
        MMPrint("**")
        MMPrint("** -d" + "               " + "Number of seconds program will run for.")
        MMPrint("** --duration" + "       " + "")
        MMPrint("**")
        MMPrint("** -e" + "               " + "Date and time program should end at.")
        MMPrint("** --endDate" + "        " + "\"2004-02-29 16:21:42\", \"16:21:42\",")
        MMPrint("**" + "                  " + "or unix timestamp (seconds)")
        MMPrint("**")
        MMPrint("** -s" + "               " + "Number of seconds to wait before starting")
        MMPrint("** --startDelay" + "     " + "program.")
        MMPrint("**")
        MMPrint("** -i" + "               " + "Number of seconds to wait between each")
        MMPrint("** --moveInterval" + "   " + "movement.")
        MMPrint("**")
        MMPrint("** -m" + "               " + "Number of pixels per movement.")
        MMPrint("** --moveStep" + "       " + "")
        MMPrint("**")
        MMPrint("** -p" + "               " + "Number of seconds to wait before")
        MMPrint("** --pauseInterval" + "  " + "resuming movement after a real")
        MMPrint("**" + "                  " + "movement has occurred.")
        MMPrint("**")
        MMPrint("** MM - USAGE - END ****************************")
        MMPrint("")
    }
}
