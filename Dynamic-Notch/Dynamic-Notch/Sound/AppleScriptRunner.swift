//
//  AppleScriptRunner.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/26/25.
//

import Foundation

class AppleScriptRunner {
    enum AppleScriptError: Error {
        case compilationFailed
        case executionFailed
        case noResult
    }
    
    static func run(script: String) throws -> String? {
        guard let appleScript = NSAppleScript(source: script) else {
            throw AppleScriptError.compilationFailed
        }
        
        var error: NSDictionary?
        let result = appleScript.executeAndReturnError(&error)
        
        if let error = error {
            print("AppleScript 오류: \(error)")
            throw AppleScriptError.executionFailed
        }
        
        return result.stringValue
    }
}

