//
//  ElloURI.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import Keys

public enum ElloURI {
    case Post
    case Profile
    case External

    // get the proper domain
    static let httpProtocol: String = "https://"
    private static var _domain: String?
    public static var domain: String {
        get {
        return ElloURI._domain ?? ElloKeys().domain()
        }
        set {
            if AppSetup.sharedState.isTesting {
                ElloURI._domain = newValue
            }
        }
    }
    public static var baseURL: String { return "\(ElloURI.httpProtocol)\(ElloURI.domain)" }

    // this is taken directly from app/models/user.rb
    static let usernameRegex = "[\\w\\-]+"
    static var userPathRegex: String { return "(w{3}\\.)?\(ElloURI.domain)\\/\(ElloURI.usernameRegex)" }



    public static func match(url: String) -> (type: ElloURI, data: String) {
        for type in self.all {
            if let match = url.rangeOfString(type.regexPattern, options: .RegularExpressionSearch) {
                return (type, type.data(url))
            }
        }
        return (self.External, self.External.data(url))
    }

    private var regexPattern: String {
        switch self {
        case .Post: return "\(ElloURI.userPathRegex)\\/post\\/[^\\/]+\\/?$"
        case .Profile: return "\(ElloURI.userPathRegex)\\/?$"
        case .External: return "https?:\\/\\/.{3,}"
        }
    }

    private func data(url: String) -> String {
        switch self {
        case .External: return url
        default:
            var urlArr = split(url) { $0 == "/" }
            return urlArr.last ?? url
        }
    }

    // Order matters: [MostSpecific, MostGeneric]
    static let all = [Post, Profile, External]
}