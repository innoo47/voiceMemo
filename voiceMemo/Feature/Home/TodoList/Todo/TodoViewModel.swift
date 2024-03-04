//
//  TodoViewModel.swift
//  voiceMemo
//
//  Created by 박인호 on 2/1/24.
//

import Foundation

class TodoViewModel: ObservableObject {
    @Published var title: String
    @Published var time: Date
    @Published var day: Date
    @Published var isDisplayCalender: Bool
    
    init(
        title: String = "",
        time: Date = Date(),
        day: Date = Date(),
        isDisplayCalender: Bool = false
    ) {
        self.title = title
        self.time = time
        self.day = day
        self.isDisplayCalender = isDisplayCalender
    }
}

extension TodoViewModel {
    func setIsDisplayCalender(_ isDisplay: Bool) {
        isDisplayCalender = isDisplay
    }
}
