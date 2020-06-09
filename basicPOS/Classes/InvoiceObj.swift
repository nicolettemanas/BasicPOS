//
//  InvoiceObj.swift
//  basicPOS
//
//  Created by Jean on 08/06/2020.
//

import Foundation

public struct InvoiceObj: BPInvoice {
  // MARK: non-conforming properties
  
  // MARK: BPInvoice
  public var id: Int
  public var isTaxInclusive: Bool {
    didSet {
      recalculate()
    }
  }
  
  public var isTaxExempt: Bool {
    didSet {
      recalculate()
    }
  }
  
  public var taxRates: [BPTaxRate] {
    didSet {
      recalculate()
    }
  }
  
  public var discountType: BPDiscountType? {
    didSet {
      recalculate()
    }
  }
  
  public var lines: [BPInvoiceLine]
  
  public init(id: Int = 0,
       isTaxInclusive: Bool = true,
       isTaxExempt: Bool = false,
       taxRates: [BPTaxRate] = [],
       discountType: BPDiscountType? = nil) {
    
    self.id = id
    self.isTaxInclusive = isTaxInclusive
    self.isTaxExempt = isTaxExempt
    self.lines = []
    self.taxRates = taxRates
    self.discountType = discountType
  }
  
  /// removes and adds modified lines to update computation
  private mutating func recalculate() {
    var newLines = [BPInvoiceLine]()
    for var l in lines {
      l.set(product: l.product,
            qty: l.qty,
            invoice: self,
            discount: discountType ?? l.discount)
      newLines.append(l)
    }
    
    lines = newLines
  }
  
  public func log() {
    print("========START=======")
    print("Invoice: \(id)")
    print("Amount Due: \(amountDue)")
    print("Tax: \(tax)")
    print("Taxable: \(taxable)")
    print("Tax Exempt: \(taxExempt)")
    print("Discount: \(discount)")
    print("=========END=========")
  }
}
