//
//  Path.swift
//  voiceMemo
//
//  Created by 박인호 on 1/21/24.
//

import Foundation

class PathModel: ObservableObject {
    @Published var paths: [PathType]
    
    init(paths: [PathType] = []) {
        self.paths = paths
    }
    
    
}
