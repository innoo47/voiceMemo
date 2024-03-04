//
//  Memo.swift
//  voiceMemo
//
//  Created by 박인호 on 2/6/24.
//

import Foundation

struct Memo: Hashable {
    var title: String
    var content: String
    var date: Date
    var id = UUID()
    
    var convertedDate: String {
        String("\(date.formattedDay) - \(date.formattedTime)")
    }
    
}
