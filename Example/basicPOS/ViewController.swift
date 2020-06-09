//
//  ViewController.swift
//  basicPOS
//
//  Created by nicolettemanas@gmail.com on 05/22/2020.
//  Copyright (c) 2020 nicolettemanas@gmail.com. All rights reserved.
//

import UIKit
import basicPOS

class ViewController: UIViewController {

    override func viewDidLoad() {
      super.viewDidLoad()
        
      let product1 = ProductObj(name: "Product 1", price: 200, isTaxExempt: true, isDiscountDisabled: false, taxRates: [])
      let product2 = ProductObj(name: "Product 2", price: 250, isTaxExempt: false, isDiscountDisabled: false, taxRates: [])
//      let product3 = ProductObj(id: 2, name: "Product 3", price: 300, isTaxExempt: false, isDiscountDisabled: false, taxRates: [])
//      let product4 = ProductObj(id: 3, name: "Product 4", price: 350, isTaxExempt: false, isDiscountDisabled: false, taxRates: [])
//      let product5 = ProductObj(id: 4, name: "Product 5", price: 400, isTaxExempt: false, isDiscountDisabled: false, taxRates: [])
      
      var invoice = InvoiceObj()
      
      let line1 = InvoiceLineObj(invoice: invoice, id: 0, product: product1, qty: 1, discount: .amount(50))
      let line2 = InvoiceLineObj(invoice: invoice, id: 1, product: product2, qty: 2)
      
      invoice.add(line: line1)
      invoice.add(line: line2)
      
      invoice.log()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

