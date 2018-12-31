//
//  Logger.swift
//  TimeTracker
//
//  Created by Sam Johnson on 12/22/18.
//  Copyright © 2018 Sam Johnson. All rights reserved.
//

import Foundation
import os.log

public class Logger {
    public static func debug(_ message: StaticString, _ args: CVarArg...) {
        os_log(message, log: OSLog.default, type: .debug, args)
    }
    
    public static func log(_ message: StaticString, _ args: CVarArg...) {
        os_log(message, args)
    }
}
