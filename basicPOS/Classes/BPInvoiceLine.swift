//
//  BPInvoiceLineObj.swift
//  basicPOS
//
//  Created by Jean on 26/05/2020.
//

import Foundation

public enum BPDiscountType {
  case amount(Double)
  case percent(Double)
  case scpwd20
  case scpwd5
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
  
  /// defines the rates of extra charges to add
  /// at the amount due if available
  /// e.g: service charge, delivery fee, etc.
  var chargeRates: [BPExtraCharge] { get set }
  
  /// if `true`, do not add tax after computation as taxes are
  /// already included in the price
  var isTaxInclusive: Bool { get set }
  
  // MARK: - LOCAL VARIABLES
  
  /// used in local computations
  /// AmtPerGuest * SCPWD Count
  var amountForSCPWDGuest: Double { get set }
  
  /// used in local computations
  /// AmtPerGuest * Guest Count
  var amountForRegularGuest: Double { get set }
  
  /// used in local computations
  /// SubTotal / Guest Count
  var amountPerGuest: Double { get set }
  
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
  
  /// the total amount of tax for this invoice line
  var tax: Double { get }
  
  /// the amount of tax exempted sales
  var taxExempt: Double { get }
  
  /// the amount to add extra charge to
  var chargeable: Double { get }
  
  /// the total amount of extra charge added
  var charge: Double { get }
  
  /// the amount of charge per charge type
  var chargesBreakdown: [String: Double] { get }
  
  /// the amount of tax amount per tax type
  var taxesBreakdown: [String: Double] { get }
  
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
    if  case .scpwd20 = discount,
        case .scpwd5 = discount {
      discount = product.isSCPWDDiscountable ?? false ? discount : nil
    }
    
    isTaxExempt = invoice.isTaxExempt || (product.isTaxExempt ?? false) || (invoice.customer?.isTaxExempt ?? false)
    taxRates = isTaxExempt ? [] : product.taxRates + invoice.taxRates
    chargeRates = invoice.chargeRates
    isTaxInclusive = invoice.isTaxInclusive
    
    amountPerGuest = subTotal/Double(invoice.numOfGuests)
    amountForSCPWDGuest = amountPerGuest * Double(invoice.numOfSCPWD)
    amountForRegularGuest = amountPerGuest * Double(invoice.numOfGuests - invoice.numOfSCPWD)
  }
  
  var subTotal: Double {
    return (product.price ?? 0) * qty
  }
  
  var totalTaxRate: Double {
    return taxRates.reduce(0) { return $0 + ($1.rate ?? 0.0) }
  }
  
  var totalChargeRate: Double {
    return chargeRates.reduce(0) { return $0 + ($1.rate ?? 0.0) }
  }

  /// sorted by computation
  
  /// compute discountable amount
  var discountable: Double {
    guard let _d = discount, !(product.isDiscountDisabled ?? false)
    else { return subTotal }
    
    switch (_d) {
      case .amount, .percent: return subTotal
      case .scpwd20: return amountForSCPWDGuest/(1 + totalTaxRate)
      case .scpwd5: return amountForSCPWDGuest
    }
  }
  
  /// identify discount amount and subtract discount from discountable
  var discountAmount: Double {
    guard let _d = discount, !(product.isDiscountDisabled ?? false)
      else { return 0 }
    
    switch (_d) {
      case let .amount(d): return d
      case let .percent(p): return discountable * p
      case .scpwd20: return discountable * 0.2
      case .scpwd5: return discountable * 0.05
    }
  }
  
  /// compute final taxable amount
  var taxable: Double {
    guard !isTaxExempt else { return 0 }

    switch (discount, product.isDiscountDisabled ?? false) {
    case (.amount, _),
         (.percent, _),
         (nil, _),
         (.scpwd20, true),
         (.scpwd5, true):
      let amount = discountable - discountAmount
      return isTaxInclusive ? amount / (1 + totalTaxRate) : amount
      
    case (.scpwd20, false):
      return product.isSCPWDDiscountable ?? true ? amountForRegularGuest / (1 + totalTaxRate) : chargeable / (1 + totalTaxRate)
      
    case (.scpwd5, false): return chargeable / (1 + totalTaxRate)
    }
  }
  
  /// compute final tax from taxable
  var tax: Double {
    return taxable * totalTaxRate
  }
  
  /// compute chargeable amount
  /// if no charge rates, can be amount due
  var chargeable: Double {
    switch (discount, product.isDiscountDisabled ?? false) {
      case (.amount, _),
      (.percent, _),
      (nil, _),
      (.scpwd20, true),
      (.scpwd5, true):
        let amount = discountable - discountAmount
        return isTaxInclusive ? amount : amount + tax
      
    case (.scpwd20, false),
         (.scpwd5, false):
      return discountable - discountAmount + amountForRegularGuest
    }
  }
  
  /// total extra charges added
  var charge: Double {
    return chargeable * totalChargeRate
  }
  
  /// the amount to pay for this invoice line
  var amountDue: Double {
    return chargeable + charge
  }
  
  var taxExempt: Double {
    switch (discount, product.isDiscountDisabled ?? false) {
    case (.scpwd20, false):
      return isTaxExempt ? amountDue : discountable - discountAmount
      
    default:
      return isTaxExempt ? amountDue : charge
    }
  }
  
  var chargesBreakdown: [String: Double] {
    var b = [String: Double]()
    for i in chargeRates {
      guard let rate = i.rate else { continue }
      b[i.id] = chargeable * rate
    }
    
    return b
  }
  
  var taxesBreakdown: [String: Double] {
    var b = [String: Double]()
    for i in taxRates {
      guard let rate = i.rate else { continue }
      b[i.id] = taxable * rate
    }
    
    return b
  }
}
