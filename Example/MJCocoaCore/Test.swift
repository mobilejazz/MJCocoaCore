//
//  Test.swift
//  MJCocoaCore_Example
//
//  Created by Joan Martin on 23/03/2018.
//  Copyright © 2018 Joan Martin. All rights reserved.
//

import Foundation
import MJCocoaCore

func testFuture() {
    let future = MJFuture<NSString>()
    
    future.then { value in
        
        }.fail { error in
            
    }
}

