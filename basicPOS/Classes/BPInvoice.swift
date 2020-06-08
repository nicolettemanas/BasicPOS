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
  
  /// constants
//  private let _taxRates: [BPTaxRate]
  var taxRates: [BPTaxRate] { get set }
//    return isTaxExempt ? [] : _taxRates
//  }
//
//  // MARK: Initializers
//  init(taxRates: [BPTaxRate], isTaxInclusive t: Bool = true) {
//    _taxRates = taxRates
//    isTaxInclusive = t
//  }
//
  // MARK: - Private accumulated values
//  private var _taxable: Double = 0
//  var taxable: Double { return _taxable }
//
//  private var _tax: Double = 0
//  var tax: Double { return _tax }
//
//  private var _amountDue: Double = 0
//  var amountDue: Double { return _amountDue }
//
//  private var _discount: Double = 0
//  var discount: Double { return _discount }
//
//  private var _extraCharges: [Int: Double] = [:]
//  var totalExtraCharges: [Int: Double] { return _extraCharges }
//
//  // MARK: `Reactive` properties
////  var customer: BPCustomer? {
////    didSet {
////      recalculate()
////    }
////  }
//
//  var extraCharges: [ExtraChargeObj] = [] {
//    didSet {
//      recalculate()
//    }
//  }
//
//  var discountType: BPDiscountType? {
//    didSet {
//      recalculate()
//    }
//  }
//
//  /// Format:
//  /// <AMOUNT> %  - for percent discounts
//  /// <AMOUNT>    - for regular amount discounts
//  var discountStr: String? {
//    didSet {
//      if discountStr?.contains("%") ?? false {
//        _discountStr = nil
//      } else {
//        _discountStr = "\((discountStr?.doubleValue ?? 0)/Double(max(lines.count, 1)))"
//      }
//
//      recalculate()
//    }
//  }
//
  var isTaxExempt: Bool { get set } // = false {
//    didSet {
//      recalculate()
//    }
//  }
//
//  /// resets and clears all invoice values
//  /// starts with a clean invoice
//  func reset() {
//    clearAccumulators()
//
//    // MARK: `Reactive` properties
//    customer = nil
//    extraCharges = [] // default value of setting
//    discountType = nil
//    discountStr = nil
//    guestCount = 1
//    scpwdCount = 0
//  }
//
//
//  /// removes line from cart, computes and updates applicable values
//  /// - Parameter line: line to remove
//  func remove(line: InvoiceLineObj) {
//    update(line: line, multiplier: -1)
//    lines.removeAll { $0.id == line.id }
//  }
//}
//
  mutating func add(line: BPInvoiceLine)
  
  mutating func remove(line: BPInvoiceLine)
  
  var amountDue: Double { get }
  
  var tax: Double { get }
  
  var taxable: Double { get }
  
  var taxExempt: Double { get }
  
  var discount: Double { get }
  
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
//  private func add(line: InvoiceLineObj) {
//    let line = line
//    line.invoice = self
//
//    /// override discount if discount is an overall amount (not percent)
//    /// set divided discount as oppose to the whole discount
//    /// eg: Discount = P15
//    /// set discount to P15/number of invoice lines
//    if discountStr != nil && !(discountStr?.contains("%") ?? true) {
//      line.discount = _discountStr
//    }
//
//    lines.append(line)
//    update(line: line, multiplier: 1)
//  }
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
}
