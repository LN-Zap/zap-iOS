//
//  Zap
//
//  Created by Otto Suess on 18.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public protocol LensType {
    associatedtype Whole
    associatedtype Part
    
    init(view: @escaping (Whole) -> Part, set: @escaping (Part, Whole) -> Whole)
    
    var view: (Whole) -> Part { get }
    var set: (Part, Whole) -> Whole { get }
}

public struct Lens <Whole, Part> : LensType {
    public let view: (Whole) -> Part
    public let set: (Part, Whole) -> Whole
    
    public init(view: @escaping (Whole) -> Part, set: @escaping (Part, Whole) -> Whole) {
        self.view = view
        self.set = set
    }
}
