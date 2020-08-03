//
//  basicPOSTests.swift
//  basicPOSTests
//
//  Created by Jean on 05/06/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//
import Quick
import Nimble
import basicPOS

@testable import basicPOS_Example

struct TestProducts {
  static let product1 = BPProductObj(name: "Product 1", price: 200, isTaxExempt: false, isDiscountDisabled: false, taxRates: [])
  static let product2 = BPProductObj(name: "Product 2", price: 250, isTaxExempt: true, isDiscountDisabled: false, taxRates: [])
  static let product3 = BPProductObj(name: "Product 3", price: 300, isTaxExempt: false, isDiscountDisabled: true, taxRates: [])
  static let product4 = BPProductObj(name: "Product 4", price: 350, isTaxExempt: true, isDiscountDisabled: false, taxRates: [])
  static let product5 = BPProductObj(name: "Product 5", price: 400, isTaxExempt: true, isDiscountDisabled: true, taxRates: [])
}

struct TestTaxes {
  static let tax1 = BPTaxRateObj(id: "vat", name: "VAT", rate: 0.12)
  static let tax2 = BPTaxRateObj(id: "pink", name: "Pink tax", rate: 0.07)
}

struct TestCharges {
  static let charge1 = BPExtraChargeObj(id: "shipping", name: "Shipping fee", rate: 0.10)
  static let charge2 = BPExtraChargeObj(id: "sc", name: "Service Charge", rate: 0.15)
}

struct TestCustomers {
  static let customer1 = BPCustomerObj(name: "John Doe")
  static let customer2 = BPCustomerObj(name: "Jane Doe", isTaxExempt: true)
}

class basicPOSTests: QuickSpec {
  override func spec() {
    describe("InvoiceObj") {
      context("regular sale, no discounts, no tax, no extra charges") {
        it("provides right computation and recomputes after adding a line") {
          var i = BPInvoiceObj()
          let line1 = BPInvoiceLineObj(invoice: i, id: 0, product: TestProducts.product1, qty: 1)
          let line2 = BPInvoiceLineObj(invoice: i, id: 1, product: TestProducts.product1, qty: 2)
          i.add(line: line1)
          i.add(line: line2)
          
          expect(i.amountDue).to(equal(600.00))
          expect(i.tax).to(equal(0))
          expect(i.taxable).to(equal(600))
          expect(i.taxExempt).to(equal(0))
          expect(i.discount).to(equal(0))
          expect(i.charge).to(equal(0))
          
          let line3 = BPInvoiceLineObj(invoice: i, id: 1, product: TestProducts.product1, qty: 2)
          i.add(line: line3)
          
          expect(i.amountDue).to(equal(1000.00))
          expect(i.tax).to(equal(0))
          expect(i.taxable).to(equal(1000))
          expect(i.taxExempt).to(equal(0))
          expect(i.discount).to(equal(0))
          expect(i.charge).to(equal(0))
          
          expect(i.chargesBreakdown.count).to(equal(0))
          expect(i.taxesBreakdown.count).to(equal(0))
        }
      }
      
      context("regular sale, no discounts, with 12% inclusive tax") {
        it("provides right computation") {
          var i = BPInvoiceObj(taxRates: [TestTaxes.tax1])
          let line1 = BPInvoiceLineObj(invoice: i, id: 0, product: TestProducts.product1, qty: 1)
          let line2 = BPInvoiceLineObj(invoice: i, id: 1, product: TestProducts.product1, qty: 2)
          i.add(line: line1)
          i.add(line: line2)
          
          expect(i.amountDue.currency()).to(equal("600.00"))
          expect(i.tax.currency()).to(equal("64.29"))
          expect(i.taxable.currency()).to(equal("535.71"))
          expect(i.taxExempt.currency()).to(equal("0.00"))
          expect(i.discount.currency()).to(equal("0.00"))
          expect(i.charge.currency()).to(equal("0.00"))
        }
      }
      
      context("regular sale, no discount, with 7% and 12% inclusive tax") {
        it("provides right computation") {
          var i = BPInvoiceObj(taxRates: [TestTaxes.tax1, TestTaxes.tax2])
          let line1 = BPInvoiceLineObj(invoice: i, id: 0, product: TestProducts.product1, qty: 1)
          let line2 = BPInvoiceLineObj(invoice: i, id: 1, product: TestProducts.product1, qty: 2)
          i.add(line: line1)
          i.add(line: line2)
          
          expect(i.amountDue.currency()).to(equal("600.00"))
          expect(i.tax.currency()).to(equal("95.80"))
          expect(i.taxable.currency()).to(equal("504.20"))
          expect(i.taxExempt.currency()).to(equal("0.00"))
          expect(i.discount.currency()).to(equal("0.00"))
          expect(i.charge.currency()).to(equal("0.00"))
          
          expect(i.taxesBreakdown.count).to(equal(2))
          expect(i.taxesBreakdown[TestTaxes.tax1.id]?.currency()).to(equal("60.50"))
          expect(i.taxesBreakdown[TestTaxes.tax2.id]?.currency()).to(equal("35.29"))
        }
      }
      
      context("regular sale, with 50 line discount, 12% inclusive tax") {
        it("provides right computation") {
          var i = BPInvoiceObj(taxRates: [TestTaxes.tax1])
          let line1 = BPInvoiceLineObj(invoice: i, id: 0, product: TestProducts.product1, qty: 3, discount: .amount(50))
          i.add(line: line1)
          
          expect(i.amountDue.currency()).to(equal("550.00"))
          expect(i.tax.currency()).to(equal("58.93"))
          expect(i.taxable.currency()).to(equal("491.07"))
          expect(i.taxExempt.currency()).to(equal("0.00"))
          expect(i.discount.currency()).to(equal("50.00"))
          expect(i.charge.currency()).to(equal("0.00"))
        }
      }
      
      context("regular sale, with 50 line discount, 12% exclusive tax") {
        it("provides right computation") {
          var i = BPInvoiceObj(isTaxInclusive: false, taxRates: [TestTaxes.tax1])
          let line1 = BPInvoiceLineObj(invoice: i, id: 0, product: TestProducts.product1, qty: 3, discount: .amount(50))
          i.add(line: line1)
          
          expect(i.amountDue.currency()).to(equal("616.00"))
          expect(i.tax.currency()).to(equal("66.00"))
          expect(i.taxable.currency()).to(equal("550.00"))
          expect(i.taxExempt.currency()).to(equal("0.00"))
          expect(i.discount.currency()).to(equal("50.00"))
          expect(i.charge.currency()).to(equal("0.00"))
        }
      }
      
      context("regular sale, with 20% overall discount, 12% and 7% exclusive tax") {
        it("provides right computation and recomputes after modifying properties last") {
          var i = BPInvoiceObj(isTaxInclusive: false, taxRates: [TestTaxes.tax1, TestTaxes.tax2])
          
          let line1 = BPInvoiceLineObj(invoice: i, id: 0, product: TestProducts.product1, qty: 1) // 200
          let line2 = BPInvoiceLineObj(invoice: i, id: 1, product: TestProducts.product2, qty: 1) // 250
          let line3 = BPInvoiceLineObj(invoice: i, id: 2, product: TestProducts.product3, qty: 1) // 300
          
          i.add(line: line1)
          i.add(line: line2)
          i.add(line: line3)
          
          i.discountType = .percent(0.2)
          
          // 200 - 40 = 160 + 30.4 = 190.4
          // 250 - 50 = 200 + 0    = 200
          // 300 - 0  = 300 + 57   = 357
          
          expect(i.amountDue.currency()).to(equal("747.40"))
          expect(i.tax.currency()).to(equal("87.40"))
          expect(i.taxable.currency()).to(equal("460.00"))
          expect(i.taxExempt.currency()).to(equal("200.00"))
          expect(i.discount.currency()).to(equal("90.00"))
          expect(i.charge.currency()).to(equal("0.00"))
          
          expect(i.taxesBreakdown.count).to(equal(2))
          expect(i.taxesBreakdown[TestTaxes.tax1.id]?.currency()).to(equal("55.20"))
          expect(i.taxesBreakdown[TestTaxes.tax2.id]?.currency()).to(equal("32.20"))
          
          expect(i.taxesBreakdown.count).to(equal(2))
          expect(i.taxesBreakdown[TestTaxes.tax1.id]?.currency()).to(equal("55.20"))
          expect(i.taxesBreakdown[TestTaxes.tax2.id]?.currency()).to(equal("32.20"))
        }
      }
      
      context("regular sale, with 10% overall discount, 7% exclusive tax, tax exempt") {
        it("provides right computation and recomputes after modifying properties last") {
          var i = BPInvoiceObj(isTaxInclusive: true, taxRates: [])
          let line1 = BPInvoiceLineObj(invoice: i, id: 0, product: TestProducts.product1, qty: 1) // 200
          
          i.add(line: line1)
          
          i.isTaxExempt = true
          i.taxRates = [TestTaxes.tax2]
          i.discountType = .percent(0.1)
          
          expect(i.amountDue.currency()).to(equal("180.00"))
          expect(i.tax.currency()).to(equal("0.00"))
          expect(i.taxable.currency()).to(equal("0.00"))
          expect(i.taxExempt.currency()).to(equal("180.00"))
          expect(i.discount.currency()).to(equal("20.00"))
          expect(i.charge.currency()).to(equal("0.00"))
        }
      }
      
      context("regular sale, 12% inclusive tax, customer is tax exempt") {
        it("provides right computation and recomputes after modifying properties last") {
          var i = BPInvoiceObj(isTaxInclusive: false, taxRates: [])
          let line1 = BPInvoiceLineObj(invoice: i, id: 0, product: TestProducts.product1, qty: 1) // 200
          
          i.add(line: line1)
          
          i.isTaxExempt = false
          i.customer = TestCustomers.customer2
          i.taxRates = [TestTaxes.tax1]
          
          expect(i.amountDue.currency()).to(equal("200.00"))
          expect(i.tax.currency()).to(equal("0.00"))
          expect(i.taxable.currency()).to(equal("0.00"))
          expect(i.taxExempt.currency()).to(equal("200.00"))
          expect(i.discount.currency()).to(equal("0.00"))
          expect(i.charge.currency()).to(equal("0.00"))
        }
      }
      
      context("regular sale, 12% inclusive and exclusive tax, 10% shipping fee") {
        it("provides right computation and recomputes after modifying properties last") {
          var i = BPInvoiceObj(isTaxInclusive: true)
          let line1 = BPInvoiceLineObj(invoice: i, id: 0, product: TestProducts.product1, qty: 1) // 200
          
          i.add(line: line1)
          
          i.taxRates = [TestTaxes.tax1]
          i.chargeRates = [TestCharges.charge1]
          
          expect(i.amountDue.currency()).to(equal("220.00"))
          expect(i.tax.currency()).to(equal("21.43"))
          expect(i.taxable.currency()).to(equal("178.57"))
          expect(i.taxExempt.currency()).to(equal("20.00"))
          expect(i.discount.currency()).to(equal("0.00"))
          expect(i.charge.currency()).to(equal("20.00"))
          
          i.isTaxInclusive = false
          
          expect(i.amountDue.currency()).to(equal("246.40"))
          expect(i.tax.currency()).to(equal("24.00"))
          expect(i.taxable.currency()).to(equal("200.00"))
          expect(i.taxExempt.currency()).to(equal("22.40"))
          expect(i.discount.currency()).to(equal("0.00"))
          expect(i.charge.currency()).to(equal("22.40"))
          
          expect(i.chargesBreakdown.count).to(equal(1))
          expect(i.chargesBreakdown[TestCharges.charge1.id]?.currency()).to(equal("22.40"))
          
          expect(i.taxesBreakdown.count).to(equal(1))
          expect(i.taxesBreakdown[TestTaxes.tax1.id]?.currency()).to(equal("24.00"))
        }
      }
      
      context("regular sale, 12% tax inclusive, 10% shipping fee, 15% service charge") {
        it("provides right computation and recomputes after modifying properties last") {
          var i = BPInvoiceObj(isTaxInclusive: true)
          let line1 = BPInvoiceLineObj(invoice: i, id: 0, product: TestProducts.product1, qty: 1) // 200
          
          i.add(line: line1)
          
          i.taxRates = [TestTaxes.tax1]
          i.chargeRates = [TestCharges.charge1, TestCharges.charge2]
          
          expect(i.amountDue.currency()).to(equal("250.00"))
          expect(i.tax.currency()).to(equal("21.43"))
          expect(i.taxable.currency()).to(equal("178.57"))
          expect(i.taxExempt.currency()).to(equal("50.00"))
          expect(i.discount.currency()).to(equal("0.00"))
          expect(i.charge.currency()).to(equal("50.00"))
          
          expect(i.chargesBreakdown.count).to(equal(2))
          expect(i.chargesBreakdown[TestCharges.charge1.id]?.currency()).to(equal("20.00"))
          expect(i.chargesBreakdown[TestCharges.charge2.id]?.currency()).to(equal("30.00"))
          
          expect(i.taxesBreakdown.count).to(equal(1))
          expect(i.taxesBreakdown[TestTaxes.tax1.id]?.currency()).to(equal("21.43"))
        }
      }
    }
  }
}
