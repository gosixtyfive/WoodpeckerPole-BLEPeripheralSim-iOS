//
//  Result.swift
//  Robot BLE Sim
//
//  Created by Steven Knodl on 4/4/17.
//  Copyright © 2017 Steve Knodl. All rights reserved.
//

import Foundation

enum Result<A, B> {
    case success(A)
    case failure(B)
}
