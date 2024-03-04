//
//  MemoView.swift
//  voiceMemo
//
//  Created by 박인호 on 2/6/24.
//

import SwiftUI

struct MemoView: View {
    @EnvironmentObject private var pathModel: PathModel
    @EnvironmentObject private var memoListViewModel: MemoListViewModel
    @StateObject var memoViewModel: MemoViewModel
    @State var isCreateMode: Bool = true
    
    var body: some View {
        ZStack {
            VStack {
                CustomNavigationBar(
                    leftBtnAction: {
                        pathModel.paths.removeLast()
                    },
                    
                    rightBtnAction: {
                        if isCreateMode {
                            memoListViewModel.addMemo(memoViewModel.memo)       // 작성 모드
                        } else {
                            memoListViewModel.updateMemo(memoViewModel.memo)    // 수정 모드
                        }
                        
                        pathModel.paths.removeLast()
                    },
                    
                    rightBtnType: isCreateMode ? .create : .complete
                )
                
                // 메모 타이틀 인풋 뷰
                MemoTitleInputView(
                    memoViewModel: memoViewModel,
                    isCreateMode: $isCreateMode
                )
                .padding(.top, 20)
                
                // 메모 컨텐츠 인풋 뷰
                MemoContentInputView(memoViewModel: memoViewModel)
                    .padding(.top, 10)
                
            }
            
            if !isCreateMode {
                // 삭제 플로팅 버튼
                RemoveMemoBtnView(memoViewModel: memoViewModel)
                    .padding(.trailing, 20)
                    .padding(.bottom, 10)
                
            }
            
        }
    }
}

// MARK: - 타이틀 뷰

private struct MemoTitleInputView: View {
    @ObservedObject private var memoViewModel: MemoViewModel
    @FocusState private var isTitleFieldFocused: Bool
    @Binding private var isCreateMode: Bool
    
    fileprivate init(
        memoViewModel: MemoViewModel,
        isCreateMode: Binding<Bool>
    ) {
        self.memoViewModel = memoViewModel
        self._isCreateMode = isCreateMode
    }
    
    fileprivate var body: some View {
        TextField(
            "제목을 입력하세요.",
            text: $memoViewModel.memo.title
        )
        .font(.system(size: 30))
        .padding(.horizontal, 20)
        .focused($isTitleFieldFocused)
        .onAppear {
            if isCreateMode {
                isTitleFieldFocused = true
            }
        }
    }
}


// MARK: - 컨텐츠 뷰

private struct MemoContentInputView: View {
    @ObservedObject private var memoViewModel: MemoViewModel
    
    fileprivate init(memoViewModel: MemoViewModel) {
        self.memoViewModel = memoViewModel
    }
    
    fileprivate var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $memoViewModel.memo.content)
                .font(.system(size: 20))
            
            if memoViewModel.memo.content.isEmpty {
                Text("메모를 입력하세요.")
                    .font(.system(size: 16))
                    .foregroundColor(.customGray1)
                    .allowsHitTesting(false) // false -> Text 터치가 안되게하여 TextEditor가 터치되도록 함
                    .padding(.top, 10)
                    .padding(.leading, 5)
            }
        }
        .padding(.horizontal, 20)
    }
}


// MARK: - 메모 삭제 버튼 뷰

private struct RemoveMemoBtnView: View {
    @EnvironmentObject private var pathModel: PathModel
    @EnvironmentObject private var memoListViewModel: MemoListViewModel
    @ObservedObject private var memoViewModel: MemoViewModel
    @State private var removeAlert = false
    
    fileprivate init(
        memoViewModel: MemoViewModel
    ) {
        self.memoViewModel = memoViewModel
    }
    
    fileprivate var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(
                    action: {
                        removeAlert = true
                    },
                    label: {
                        Image("trash")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.customGray2)
                    })
            }
        }
        .alert(isPresented: $removeAlert) {
            Alert(
                title: Text("메모 삭제"),
                message: Text("메모를 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("삭제")) {
                    memoListViewModel.removeMemo(memoViewModel.memo)
                    pathModel.paths.removeLast()
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
    }
    
}



#Preview {
    MemoView(
        memoViewModel: .init(
            memo: .init(
                title: "",
                content: "",
                date: Date()
            )
        )
    )
}
