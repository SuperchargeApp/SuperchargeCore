//
//  SharedExtensions.swift
//  Supercharge
//
//  Created by Kabir Oberai on 30/09/18.
//  Copyright © 2018 Kabir Oberai. All rights reserved.
//

import Foundation

extension String {

    func subtracting(_ base: String) -> String {
        let afterBase = index(base.endIndex, offsetBy: 1)
        return String(self[afterBase...])
    }

}

extension Progress {

    static func performDiscretely<ReturnType>(work: () throws -> ReturnType) rethrows -> ReturnType {
        return try discreteProgress(totalUnitCount: 1).performAsCurrent(withPendingUnitCount: 1, using: work)
    }

}
