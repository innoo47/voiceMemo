//
//  CustomNavigationBar.swift
//  voiceMemo
//
//  Created by 박인호 on 1/22/24.
//

import SwiftUI

struct CustomNavigationBar: View {
    let isDisplayLeftBtn: Bool
    let isDisplayRightBtn: Bool
    let leftBtnAction: () -> Void
    let rightBtnAction: () -> Void
    let rightBtnType: NavigationBtnType
    
    init(
        isDisplayLeftBtn: Bool = true,
        isDisplayRightBtn: Bool = true,
        leftBtnAction: @escaping () -> Void = {},
        rightBtnAction: @escaping () -> Void = {},
        rightBtnType: NavigationBtnType = .edit
    ) {
        self.isDisplayLeftBtn = isDisplayLeftBtn
        self.isDisplayRightBtn = isDisplayRightBtn
        self.leftBtnAction = leftBtnAction
        self.rightBtnAction = rightBtnAction
        self.rightBtnType = rightBtnType
    }
    
    var body: some View {
        VStack {
            HStack {
                
                // 좌측 버튼
                if isDisplayLeftBtn {
                    Button(action: leftBtnAction,
                           label: {
                        Image("leftArrow")
                    })
                }
                
                Spacer()
                
                // 우측 버튼
                if isDisplayRightBtn {
                    Button( action: rightBtnAction,
                            label: {
                        if rightBtnType == .close {
                            Image("close")
                        } else {
                            Text(rightBtnType.rawValue)
                                .foregroundColor(.customBlack)
                        }
                    })
                }
                
            }
            .padding(.horizontal, 20)
            .frame(height: 20)
            .padding(.bottom, 5)
            
//            // 구분 선
//            Rectangle()
//                .frame(height: 0.5)
//                .foregroundColor(.customBlack)
        }
    }
}

#Preview {
    CustomNavigationBar()
}
