//
//  PathType.swift
//  voiceMemo
//
//  Created by 박인호 on 1/21/24.
//

enum PathType: Hashable {
    case homeView
    case todoView
    case memoView(isCreateMode: Bool, memo: Memo?)
    
    
}
