//
//  InvoiceLineObj.swift
//  basicPOS
//
//  Created by Jean on 08/06/2020.
//

import Foundation

public struct BPInvoiceLineObj: BPInvoiceLine {

  // MARK: BPInvoiceLine
  public var id: Int
  public var product: BPProduct
  public var qty: Double
  public var discount: BPDiscountType?
  public var isTaxExempt: Bool
  public var isTaxInclusive: Bool
  public var taxRates: [BPTaxRate]
  public var chargeRates: [BPExtraCharge]
  
  // MARK: non-conforming properties & methods
  public init(invoice: BPInvoice,
       id: Int,
       product: BPProduct,
       qty: Double,
       discount: BPDiscountType? = nil,
       isTaxExempt: Bool = false,
       taxRates: [BPTaxRate] = [],
       chargeRates: [BPExtraCharge] = [],
       isTaxInclusive: Bool = true) {
    
    self.id = id
    self.product = product
    self.qty = qty
    self.discount = discount ?? invoice.discountType
    self.isTaxExempt = isTaxExempt
    self.isTaxInclusive = isTaxInclusive
    self.taxRates = taxRates
    self.chargeRates = chargeRates
    
    set(product: product, qty: qty, invoice: invoice, discount: self.discount)
  }
}
