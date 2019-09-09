import Foundation
import os

public extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let logic = OSLog(subsystem: subsystem, category: "logic")
    static let structure = OSLog(subsystem: subsystem, category: "structure")
}
