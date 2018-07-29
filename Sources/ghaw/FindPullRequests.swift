//
//  FindPullRequests.swift
//  ghaw
//
//  Created by Toshihiro Suzuki on 2018/07/29.
//
import CoreCLI
import Foundation
import RxSwift
import ShellOut

struct FindPullRequests: CommandType {
    private let match: String

    init(parser: ArgumentParserType) throws {
        guard let match = parser.shift() else {
            throw CommandError("Missing filename parameter.")
        }
        self.match = match
    }

    func run() throws {
        let shellScriptPath: String = {
            let executableDir: String = {
                let path = "\(Bundle.main.bundlePath)/ghaw"
                let fm = FileManager.default
                let executablePath = (try? fm.destinationOfSymbolicLink(atPath: path)) ?? path
                let joined = executablePath.split(separator: "/").dropLast().joined(separator: "/")
                if executablePath.hasPrefix("/") {
                    return "/\(joined)"
                } else {
                    return joined
                }
            }()

            if executableDir.contains(".build") {
                // spm debug
                return "\(executableDir)/../../../Sources/Scripts/find-pull-requests.sh"
            } else if executableDir.contains("Library/Developer/Xcode/DerivedData") {
                // Xcode
                fatalError("Executing a script while debugging with Xcode is not supported. Please use SPM from commandline.")
            } else if executableDir.contains("lib/mint/packages") {
                // mint install
                return "\(executableDir)/find-pull-requests.sh"
            } else {
                // install.sh
                return "\(executableDir)/../share/ghaw/find-pull-requests.sh"
            }
        }()

        let result = try shellOut(to: shellScriptPath, arguments: [match])
        print(result)
        exit(0)
    }
}
