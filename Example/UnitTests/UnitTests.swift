//
//  basicPOSTests.swift
//  basicPOSTests
//
//  Created by Jean on 05/06/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//
import Quick
import Nimble

@testable import basicPOS_Example

struct TestProducts {
  static let product1 = ProductObj(id: 0, name: "Product 1", price: 200, isTaxExempt: false, isDiscountDisabled: false, taxRates: [])
  static let product2 = ProductObj(id: 1, name: "Product 2", price: 250, isTaxExempt: true, isDiscountDisabled: false, taxRates: [])
  static let product3 = ProductObj(id: 2, name: "Product 3", price: 300, isTaxExempt: false, isDiscountDisabled: true, taxRates: [])
  static let product4 = ProductObj(id: 3, name: "Product 4", price: 350, isTaxExempt: true, isDiscountDisabled: false, taxRates: [])
  static let product5 = ProductObj(id: 4, name: "Product 5", price: 400, isTaxExempt: true, isDiscountDisabled: true, taxRates: [])
}

struct TestTaxes {
  static let tax1 = TaxRateObj(id: 0, name: "VAT", rate: 0.12)
  static let tax2 = TaxRateObj(id: 1, name: "Pink tax", rate: 0.07)
}

class basicPOSTests: QuickSpec {
  override func spec() {
    describe("InvoiceObj") {
      context("regular sale, no discounts, no tax, no extra charges") {
        it("provides right computation and recomputes after adding a line") {
          var i = InvoiceObj()
          let line1 = InvoiceLineObj(invoice: i, id: 0, product: TestProducts.product1, qty: 1)
          let line2 = InvoiceLineObj(invoice: i, id: 1, product: TestProducts.product1, qty: 2)
          i.add(line: line1)
          i.add(line: line2)
          
          expect(i.amountDue).to(equal(600.00))
          expect(i.tax).to(equal(0))
          expect(i.taxable).to(equal(600))
          expect(i.taxExempt).to(equal(0))
          expect(i.discount).to(equal(0))
          
          let line3 = InvoiceLineObj(invoice: i, id: 1, product: TestProducts.product1, qty: 2)
          i.add(line: line3)
          
          expect(i.amountDue).to(equal(1000.00))
          expect(i.tax).to(equal(0))
          expect(i.taxable).to(equal(1000))
          expect(i.taxExempt).to(equal(0))
          expect(i.discount).to(equal(0))
        }
      }
      
      context("regular sale, no discounts, with 12% inclusive tax") {
        it("provides right computation") {
          var i = InvoiceObj(taxRates: [TestTaxes.tax1])
          let line1 = InvoiceLineObj(invoice: i, id: 0, product: TestProducts.product1, qty: 1)
          let line2 = InvoiceLineObj(invoice: i, id: 1, product: TestProducts.product1, qty: 2)
          i.add(line: line1)
          i.add(line: line2)
          
          expect(i.amountDue.currency()).to(equal("600.00"))
          expect(i.tax.currency()).to(equal("64.29"))
          expect(i.taxable.currency()).to(equal("535.71"))
          expect(i.taxExempt.currency()).to(equal("0.00"))
          expect(i.discount.currency()).to(equal("0.00"))
        }
      }
      
      context("regular sale, no discount, with 7% and 12% inclusive tax") {
        it("provides right computation") {
          var i = InvoiceObj(taxRates: [TestTaxes.tax1, TestTaxes.tax2])
          let line1 = InvoiceLineObj(invoice: i, id: 0, product: TestProducts.product1, qty: 1)
          let line2 = InvoiceLineObj(invoice: i, id: 1, product: TestProducts.product1, qty: 2)
          i.add(line: line1)
          i.add(line: line2)
          
          expect(i.amountDue.currency()).to(equal("600.00"))
          expect(i.tax.currency()).to(equal("95.80"))
          expect(i.taxable.currency()).to(equal("504.20"))
          expect(i.taxExempt.currency()).to(equal("0.00"))
          expect(i.discount.currency()).to(equal("0.00"))
        }
      }
      
      context("regular sale, with 50 line discount, 12% inclusive tax") {
        it("provides right computation") {
          var i = InvoiceObj(taxRates: [TestTaxes.tax1])
          let line1 = InvoiceLineObj(invoice: i, id: 0, product: TestProducts.product1, qty: 3, discount: .amount(50))
          i.add(line: line1)
          
          expect(i.amountDue.currency()).to(equal("550.00"))
          expect(i.tax.currency()).to(equal("58.93"))
          expect(i.taxable.currency()).to(equal("491.07"))
          expect(i.taxExempt.currency()).to(equal("0.00"))
          expect(i.discount.currency()).to(equal("50.00"))
        }
      }
      
      context("regular sale, with 50 line discount, 12% exclusive tax") {
        it("provides right computation") {
          var i = InvoiceObj(isTaxInclusive: false, taxRates: [TestTaxes.tax1])
          let line1 = InvoiceLineObj(invoice: i, id: 0, product: TestProducts.product1, qty: 3, discount: .amount(50))
          i.add(line: line1)
          
          expect(i.amountDue.currency()).to(equal("616.00"))
          expect(i.tax.currency()).to(equal("66.00"))
          expect(i.taxable.currency()).to(equal("550.00"))
          expect(i.taxExempt.currency()).to(equal("0.00"))
          expect(i.discount.currency()).to(equal("50.00"))
        }
      }
    }
  }
}
