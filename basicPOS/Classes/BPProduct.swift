//
//  ProductObj.swift
//  basicPOS
//
//  Created by Jean on 26/05/2020.
//

import Foundation

public protocol BPProduct {
  var name: String? { get set }
  var price: Double? { get set }
  var isTaxExempt: Bool? { get set }
  var isDiscountDisabled: Bool? { get set }
  var isSCPWDDiscountable: Bool? { get set }

  var taxRates: [BPTaxRate] { get set }
}
