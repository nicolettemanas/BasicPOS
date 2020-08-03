//
//  ExtraChargeObj.swift
//  basicPOS
//
//  Created by Jean on 09/06/2020.
//

import Foundation

public struct BPExtraChargeObj: BPExtraCharge {
  // MARK: non-conforming properties
  
  // MARK: BPExtraCharge
  public var id: String
  public var name: String?
  public var rate: Double?
  
  public init(id: String, name: String?, rate: Double?) {
    self.id = id
    self.rate = rate
    self.name = name
  }
}
