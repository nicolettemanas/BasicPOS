//
//  BPInvoiceObj.swift
//  basicPOS
//
//  Created by Jean on 26/05/2020.
//

import Foundation

public protocol BPInvoice {
  
  // MARK: - assignable properties
  var id: Int { get set }
  var lines: [BPInvoiceLine] { get set }
  var isTaxInclusive: Bool { get set }
  var isTaxExempt: Bool { get set }
  var discountType: BPDiscountType? { get set }
  var customer: BPCustomer? { get set }
  var taxRates: [BPTaxRate] { get set }
  var chargeRates: [BPExtraCharge] { get set }
  
  var numOfGuests: Int { get set }
  var numOfSCPWD: Int { get set }

  mutating func add(line: BPInvoiceLine)
  
  mutating func remove(line: BPInvoiceLine)
  
  var amountDue: Double { get }
  
  var tax: Double { get }
  
  var taxable: Double { get }
  
  var taxExempt: Double { get }
  
  var discount: Double { get }
  
  var charge: Double { get }
  
  var taxesBreakdown: [String: Double] { get }

  var chargesBreakdown: [String: Double] { get }
}

public extension BPInvoice where Self: Any {
  mutating func add(line: BPInvoiceLine) {
    lines.append(line)
  }
  
  mutating func remove(line: BPInvoiceLine) {
    lines.removeAll(where: { line.id == $0.id })
  }
  
  var amountDue: Double {
    return lines.reduce(0) { $0 + $1.amountDue }
  }
  
  var tax: Double {
    return lines.reduce(0) { $0 + $1.tax }
  }
  
  var taxable: Double {
    return lines.reduce(0) { $0 + $1.taxable }
  }
  
  var taxExempt: Double {
    return lines.reduce(0) { $0 + $1.taxExempt }
  }
  
  var discount: Double {
    return lines.reduce(0) { $0 + $1.discountAmount }
  }
  
  var charge: Double {
    return lines.reduce(0) { $0 + $1.charge }
  }
  
  var taxesBreakdown: [String : Double] {
    var b = taxRates.reduce(into: [:]) { $0[$1.id] = 0.0 }
    for line in lines {
      for tax in line.taxesBreakdown {
        b[tax.key]! += tax.value
      }
    }
    
    return b
  }

  var chargesBreakdown: [String : Double] {
    var b = chargeRates.reduce(into: [:]) { $0[$1.id] = 0.0 }
    for line in lines {
      for tax in line.chargesBreakdown {
        b[tax.key]! += tax.value
      }
    }
    
    return b
  }
}
