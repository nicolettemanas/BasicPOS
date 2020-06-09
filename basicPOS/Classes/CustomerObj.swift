//
//  CustomerObj.swift
//  basicPOS
//
//  Created by Jean on 09/06/2020.
//

import Foundation

public struct CustomerObj: BPCustomer {
  public var name: String?
  public var isTaxExempt: Bool
  
  public init(name: String?, isTaxExempt: Bool = false) {
    self.name = name
    self.isTaxExempt = isTaxExempt
  }
}
