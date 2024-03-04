//
//  MemoViewModel.swift
//  voiceMemo
//
//  Created by 박인호 on 2/6/24.
//

import Foundation

class MemoViewModel: ObservableObject{
    @Published var memo: Memo
    
    init(memo: Memo) {
        self.memo = memo
    }
      
}
