//
//  BPExtraCharge.swift
//  basicPOS
//
//  Created by Jean on 09/06/2020.
//

import Foundation

public protocol BPExtraCharge: Codable {
  var id: String { get set }
  var name: String? { get set }
  var rate: Double? { get set }
}
