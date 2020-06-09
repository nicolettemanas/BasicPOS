//
//  _Pods.swift
//  basicPOS
//
//  Created by Jean on 09/06/2020.
//

import Foundation

public protocol BPCustomer: Codable {
  var name: String? { get set }
  var isTaxExempt: Bool { get set }
}
