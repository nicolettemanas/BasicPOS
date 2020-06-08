//
//  Double+Util.swift
//  basicPOS_Example
//
//  Created by Jean on 05/06/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

public extension Double {
  func currency(showCurrency: Bool = false) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = NumberFormatter.Style.currency
    formatter.roundingMode = NumberFormatter.RoundingMode.halfUp
    formatter.maximumFractionDigits = 2
    formatter.locale = Locale.current
    formatter.currencySymbol = showCurrency ? Locale.current.currencySymbol : ""

    return formatter.string(from: NSNumber(value: self)) ?? ""
  }
}
