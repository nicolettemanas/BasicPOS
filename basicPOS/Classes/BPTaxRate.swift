//
//  BPTaxRate.swift
//  basicPOS
//
//  Created by Jean on 26/05/2020.
//

import Foundation

public protocol BPTaxRate: Codable {
  var id: Int? { get set }
  var name: String? { get set }
  var rate: Double? { get set }
}
