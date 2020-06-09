//
//  InvoiceObj.swift
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
  
//// MARK: - Private methods
//private extension InvoiceObj {
//  /// Clears all non-reactive variables
//  private func clearAccumulators() {
//    lines = []
//
//    _taxable = 0
//    _tax = 0
//    _vatExempt = 0
//    _zeroRated = 0
//    _amountDue = 0
//    _discount = 0
//    _extraCharges = [:]
//  }
//
//  private func recalculate() {
//    let _lines = lines
//    clearAccumulators()
//
//    for l in _lines {
//      add(line: l)
//    }
//  }
//
//
//  private func update(line: InvoiceLineObj, multiplier: Double) {
//    /// add/subtract accumulated values
//    /// depending on the multiplier (1 if add, -1 if subtract)
//    _taxable    += line.taxable * multiplier
//    _tax        += line.tax * multiplier
//    _vatExempt  += line.vatExemptAmount * multiplier
//    _zeroRated  += line.zeroRatedAmount * multiplier
//    _discount   += line.discountInAmount * multiplier
//    _amountDue  += line.amountDue * multiplier
//
//    applyExtraCharges(for: line, multiplier: multiplier)
//  }
//
//  private func applyExtraCharges(for line: InvoiceLineObj, multiplier: Double) {
//    for charge in extraCharges {
//      let existingChargeAmt = _extraCharges[charge.id] ?? 0
//      let additionalAmount = line.amountDue * charge.rate * multiplier
//
//      _extraCharges[charge.id] = (existingChargeAmt + additionalAmount).roundToNearest(decimalCount: 2)
//      _amountDue += additionalAmount
//
//      if charge.vatable && !line.isTaxExempt && !isZeroRated {
//        let additionalVatable = additionalAmount / (1 + line.totalTaxRate)
//        _taxable += additionalVatable
//        _tax += additionalVatable * line.totalTaxRate
//      }
//
//      if isZeroRated {
//        _zeroRated += additionalAmount
//      } else if line.isTaxExempt {
//        _vatExempt += additionalAmount
//      }
//    }
//  }
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
