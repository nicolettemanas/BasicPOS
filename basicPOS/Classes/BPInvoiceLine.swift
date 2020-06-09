//
//  InvoiceLineObj.swift
//  basicPOS
//
//  Created by Jean on 26/05/2020.
//

import Foundation

public enum BPDiscountType {
  case amount(Double)
  case percent(Double)
}

public protocol BPInvoiceLine {
  
  var id: Int { get set }
  var product: BPProduct { get set}
  var qty: Double { get set }
  var discount: BPDiscountType? { get set }
  
  /// if `true`, skip computation of tax
  /// set upon initializing InvoiceLine
  var isTaxExempt: Bool { get set }
  
  /// `taxRates` specific invoice line tax rates
  /// if applicable, appends the product-specific tax to existing invoice tax rates
  /// set upon initializing InvoiceLine
  var taxRates: [BPTaxRate] { get set }
  
  /// if `true`, do not add tax after computation as taxes are
  /// already included in the price
  var isTaxInclusive: Bool { get set }
  
  mutating func set(
    product: BPProduct,
    qty: Double,
    invoice: BPInvoice,
    discount: BPDiscountType?)
  
  // MARK: - Computed properties
  
  /// Gross total of the invoice line (price x qty)
  var subTotal: Double { get }
  
  /// sum of all tax rates (in case of multiple taxes)
  var totalTaxRate: Double { get }
  
  /// Computes the discount amount depending on the
  /// given discount type
  var discountAmount: Double { get }
  
  /// the amount to compute the discount from
  var discountable: Double { get }
  
  /// the amount to compute the tax from
  var taxable: Double { get }
  
  /// the amount of tax for this invoice line
  var tax: Double { get }
  
  /// the amount of tax exempted sales
  var taxExempt: Double { get }
  
  /// total amount to pay
  var amountDue: Double { get }
}

public extension BPInvoiceLine where Self: Any {
  mutating func set(
    product p: BPProduct,
    qty q: Double,
    invoice: BPInvoice,
    discount d: BPDiscountType?) {
    
    product = p
    qty = q
    discount = d ?? invoice.discountType
    
    isTaxExempt = invoice.isTaxExempt || (product.isTaxExempt ?? false)
    taxRates = isTaxExempt ? [] : product.taxRates + invoice.taxRates
    isTaxInclusive = invoice.isTaxInclusive
  }
  
  var subTotal: Double {
    return (product.price ?? 0) * qty
  }
  
  var totalTaxRate: Double {
    return taxRates.reduce(0) { return $0 + ($1.rate ?? 0.0) }
  }

  var discountAmount: Double {
    guard let _d = discount, !(product.isDiscountDisabled ?? false)
      else { return 0 }
    
    switch (_d) {
      case let .amount(d): return d
      case let .percent(p): return discountable * p
    }
  }
  
  var discountable: Double {
    return subTotal
  }
  
  var taxable: Double {
    guard !isTaxExempt else { return 0 }
    let amount = discountable - discountAmount
    
    return isTaxInclusive ? amount / (1 + totalTaxRate) : amount
  }
  
  var tax: Double {
    return taxable * totalTaxRate
  }
  
  var taxExempt: Double {
    return isTaxExempt ? amountDue : 0
  }
  
  var amountDue: Double {
    let amount = discountable - discountAmount
    return isTaxInclusive ? amount : amount + tax
  }
}
