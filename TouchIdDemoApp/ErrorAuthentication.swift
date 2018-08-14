//
//  ErrorAuthentication.swift
//  TouchIdDemoApp
//
//  Created by Sumit Ghosh on 13/08/18.
//  Copyright © 2018 Sumit Ghosh. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

enum LAError: Int {
    case AuthenticationFailed
    case UserCancel
    case UserFallback
    case SystemCancel
    case PasscodeNotSet
    case TouchIDNotAvailable
    case TouchIDNotEnrolled
}
