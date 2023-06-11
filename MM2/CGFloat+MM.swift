//
//  CGFloat+MM.swift
//  MM2
//
//  Created by 2fletch on 2020-12-17.
//

import Foundation

extension CGFloat {
    init?(_ stringVal: String?) {
        guard let stringVal = stringVal, let val = Double(stringVal) else {
            return nil
        }
        self = CGFloat(val)
    }
}
