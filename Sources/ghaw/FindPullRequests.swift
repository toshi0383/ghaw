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
    struct Argument: AutoArgumentsDecodable {
        // sourcery: shift
        let match: String
    }

    let argument: Argument

    func run() throws {
        let result = try shellOut(to: pathForShellScript(named: "find-pull-requests.sh"),
                                  arguments: [argument.match])
        print(result)
        exit(0)
    }
}
