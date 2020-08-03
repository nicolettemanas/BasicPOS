//
//  PublicObj.swift
//  basicPOS
//
//  Created by Jean on 08/06/2020.
//

import Foundation

public struct BPProductObj: BPProduct {
  // MARK: non-conforming properties
  
  // MARK: BPProduct
  public var name: String?
  public var price: Double?
  public var isTaxExempt: Bool?
  public var isDiscountDisabled: Bool?
  public var taxRates: [BPTaxRate]
  
  public init(name: String,
              price: Double,
              isTaxExempt: Bool? = false,
              isDiscountDisabled: Bool = false,
              taxRates: [BPTaxRate] = []) {
    
    self.name = name
    self.price = price
    self.isTaxExempt = isTaxExempt
    self.isDiscountDisabled = isDiscountDisabled
    self.taxRates = taxRates
  }
}
