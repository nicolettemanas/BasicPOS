//
//  InvoiceObj.swift
//  basicPOS_Example
//
//  Created by Jean on 05/06/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import basicPOS

struct TaxRateObj: BPTaxRate {
  // MARK: non-conforming properties
  
  // MARK: BPTaxRate
  var id: Int?
  var name: String?
  var rate: Double?
}

struct ProductObj: BPProduct {
  // MARK: non-conforming properties
  
  // MARK: BPProduct
  var id: Int?
  var name: String?
  var price: Double?
  var isTaxExempt: Bool?
  var isDiscountDisabled: Bool?
  var taxRates: [BPTaxRate]
}

struct InvoiceLineObj: BPInvoiceLine {
  // MARK: BPInvoiceLine
  var id: Int
  var product: BPProduct
  var qty: Double
  var discount: BPDiscountType?
  var isTaxExempt: Bool
  var taxRates: [BPTaxRate]
  var isTaxInclusive: Bool
  
  // MARK: non-conforming properties & methods
  init(invoice: BPInvoice,
       id: Int,
       product: BPProduct,
       qty: Double,
       discount: BPDiscountType? = nil,
       isTaxExempt: Bool = false,
       taxRates: [BPTaxRate] = [],
       isTaxInclusive: Bool = true) {
    
    self.id = id
    self.product = product
    self.qty = qty
    self.discount = discount
    self.isTaxExempt = isTaxExempt
    self.taxRates = taxRates
    self.isTaxInclusive = isTaxInclusive
    
    set(product: product, qty: qty, invoice: invoice, discount: discount)
  }
}

struct InvoiceObj: BPInvoice {
  // MARK: non-conforming properties
  
  // MARK: BPInvoice
  var id: Int
  var isTaxInclusive: Bool
  var isTaxExempt: Bool
  var lines: [BPInvoiceLine]
  var taxRates: [BPTaxRate]
  
  init(id: Int = 0,
       isTaxInclusive: Bool = true,
       isTaxExempt: Bool = false,
       taxRates: [BPTaxRate] = []) {
    
    self.id = id
    self.isTaxInclusive = isTaxInclusive
    self.isTaxExempt = isTaxExempt
    self.lines = []
    self.taxRates = taxRates
  }
  
  func log() {
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
