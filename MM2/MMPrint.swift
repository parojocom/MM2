//
//  MMPrint.swift
//  MM2
//
//  Created by 2fletch on 2020-12-17.
//

import Foundation

// 'items: Any...' is converted into an array, so if you directly pass that to another func, that
// func thinks its VARIADIC list consists of one single arg that is an array

func MMPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    for (idx, item) in items.enumerated() {
        print(item, terminator: (idx + 1 == items.count ? terminator : separator))
    }
}

func MMPrint<Target>(_ items: Any..., separator: String = " ", terminator: String = "\n", to output: inout Target) where Target : TextOutputStream {
    for (idx, item) in items.enumerated() {
        print(item, terminator: (idx + 1 == items.count ? terminator : separator), to: &output)
    }
}

func MMDebugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    for (idx, item) in items.enumerated() {
        MMPrint(item, terminator: (idx + 1 == items.count ? terminator : separator))
    }
    #endif
}

func MMDebugPrint<Target>(_ items: Any..., separator: String = " ", terminator: String = "\n", to output: inout Target) where Target : TextOutputStream {
    #if DEBUG
    for (idx, item) in items.enumerated() {
        MMPrint(item, terminator: (idx + 1 == items.count ? terminator : separator), to: &output)
    }
    #endif
}
