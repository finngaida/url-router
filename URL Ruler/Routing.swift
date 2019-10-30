//
//  Routing.swift
//  URL Ruler
//
//  Created by Finn Gaida on 29.10.19.
//  Copyright © 2019 Finn Gaida. All rights reserved.
//

import Cocoa
import Foundation

enum MatchMode: Int, Codable, CaseIterable {
    case regex
    case beginsWith
    case contains
}

protocol URLRule {
    var matchMode: MatchMode { get }
    var pattern: String { get }
    var appURL: URL { get }
}

struct UserURLRule: URLRule, Codable {
    let matchMode: MatchMode
    let pattern: String
    let appURL: URL
}

enum RoutingError: Error {
    case noRuleMatch
}

struct Routing {
    static var shared = Routing()

    var rules: [UserURLRule] {
        didSet {
            guard let data = try? PropertyListEncoder().encode(rules) else { return }
            UserDefaults.standard.set(data, forKey: "rules")
        }
    }

    init() {
        guard
            let data = UserDefaults.standard.data(forKey: "rules"),
            let optRules = try? PropertyListDecoder().decode([UserURLRule].self, from: data)
            else {
                rules = [
                    UserURLRule(matchMode: .beginsWith,
                                pattern: "https://www.figma.com",
                                appURL: URL(fileURLWithPath: "/Applications/Google Chrome.app")),
                    UserURLRule(matchMode: .beginsWith,
                                pattern: "https://docs.google.com",
                                appURL: URL(fileURLWithPath: "/Applications/Google Chrome.app")),
                    UserURLRule(matchMode: .beginsWith,
                                pattern: "https://meet.google.com",
                                appURL: URL(fileURLWithPath: "/Applications/Google Chrome.app")),
                    UserURLRule(matchMode: .beginsWith,
                                pattern: "https://kaiahealth.atlassian.net",
                                appURL: URL(fileURLWithPath: "/Applications/Google Chrome.app")),
                    UserURLRule(matchMode: .beginsWith,
                                pattern: "https://trello.com",
                                appURL: URL(fileURLWithPath: "/Applications/Google Chrome.app")),
                    UserURLRule(matchMode: .beginsWith,
                                pattern: "https://calendar.google.com",
                                appURL: URL(fileURLWithPath: "/Applications/Google Chrome.app")),
                    UserURLRule(matchMode: .beginsWith,
                                pattern: "http",
                                appURL: URL(fileURLWithPath: "/Applications/Iridium.app")),
                ]
                return
        }

        rules = optRules
    }

    func execute(_ urls: [URL]) throws {
        for url in urls {
            let rule = try self.rule(for: url)
            try execute(rule, with: url)
        }
    }

    private func rule(for url: URL) throws -> URLRule {
        let string = url.absoluteString
        for rule in rules {
            switch rule.matchMode {
            case .regex:
                let regex = try NSRegularExpression(pattern: rule.pattern, options: [])
                if regex.numberOfMatches(in: string,
                                         options: [],
                                         range: NSRange(location: 0, length: string.count)) > 0 {
                    return rule
                }

            case .beginsWith, .contains:
                if let range = string.range(of: rule.pattern) {
                    if (rule.matchMode == .beginsWith && range.lowerBound == string.startIndex) ||
                        rule.matchMode == .contains {
                        return rule
                    }
                }
            }
        }
        throw RoutingError.noRuleMatch
    }

    private func execute(_ rule: URLRule, with url: URL) throws {
        print("Opening \(url) in \(rule.appURL.lastPathComponent)")
        try NSWorkspace.shared.open([url],
                                    withApplicationAt: rule.appURL,
                                    options: .default,
                                    configuration: [:])
    }
}
