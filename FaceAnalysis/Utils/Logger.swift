//
//  Logger.swift
//  FaceAnalysis
//
//  Created by Darko Damjanovic on 10.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation

/// A basic Logger class. Default is to log only in DEBUG builds.
public class Logger {
    
    public init() {
        #if DEBUG
        isLoggingEnabled = true
        #endif
    }
    
    public var logLevel: LogLevel = .info
    public var isLoggingEnabled = false
    
    public enum LogLevel: Int {
        case verbose = 0
        case debug = 1
        case info = 2
        case warning = 3
        case error = 4
    }
    
    public func verbose(_ message: @autoclosure () -> Any, _ function: String = #function, lineNumber: Int = #line, file: String = #file) {
        doLogging(level: .verbose, message: message(), function: function, lineNumber: String(lineNumber), filePath: file)
    }
    
    public func debug(_ message: @autoclosure () -> Any, _ function: String = #function, lineNumber: Int = #line, file: String = #file) {
        doLogging(level: .debug, message: message(), function: function, lineNumber: String(lineNumber), filePath: file)
    }
    
    public func info(_ message: @autoclosure () -> Any, _ function: String = #function, lineNumber: Int = #line, file: String = #file) {
        doLogging(level: .info, message: message(), function: function, lineNumber: String(lineNumber), filePath: file)
    }
    
    public func warning(_ message: @autoclosure () -> Any, _ function: String = #function, lineNumber: Int = #line, file: String = #file) {
        doLogging(level: .warning, message: message(), function: function, lineNumber: String(lineNumber), filePath: file)
    }
    
    public func error(_ message: @autoclosure () -> Any, _ function: String = #function, lineNumber: Int = #line, file: String = #file) {
        doLogging(level: .error, message: message(), function: function, lineNumber: String(lineNumber), filePath: file)
    }
    
    private func doLogging(level: LogLevel, message: Any, function: String, lineNumber: String, filePath: String) {
        guard level.rawValue >= self.logLevel.rawValue else { return }
        guard isLoggingEnabled else { return }
        
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        let time = dateFormatter.string(from: Date())
        
        var fileName = ""
        let fileParts = filePath.components(separatedBy: "/")
        if let lastPart = fileParts.last {
            fileName = lastPart
            fileName += "."
        }
        
        var logLevelText = ""
        switch level {
        case .verbose:
            logLevelText = "👁 VERBOSE"
        case .debug:
            logLevelText = "🐞 DEBUG"
        case .info:
            logLevelText = "ℹ️ INFO"
        case .warning:
            logLevelText = "⚠️ WARNING"
        case .error:
            logLevelText = "🔴 ERROR"
        }
        
        let outMessage = "\(time) \(logLevelText) \(fileName)\(function):\(lineNumber) - \(String(describing: message))"
        print(outMessage)
    }
    
}
