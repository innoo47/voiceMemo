//
//  MemoListView.swift
//  voiceMemo
//
//  Created by 박인호 on 2/6/24.
//

import SwiftUI

struct MemoListView: View {
    @EnvironmentObject private var pathModel: PathModel
    @EnvironmentObject private var memoListViewModel: MemoListViewModel
    @EnvironmentObject private var homeViewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            // 투두 셀 리스트
            VStack {
                if !memoListViewModel.memos.isEmpty {
                    CustomNavigationBar(
                        isDisplayLeftBtn: false,
                        rightBtnAction: {
                            memoListViewModel.navigationRightBtnTapped()
                        },
                        rightBtnType: (
                            memoListViewModel.navigationBarRightBtnMode
                        )
                    )
                } else {
                    Spacer()
                        .frame(height: 30)
                }
                
                // 타이틀 뷰
                TitleView()
                
                // 안내 뷰 또는 메모 리스트 컨텐츠 뷰
                if memoListViewModel.memos.isEmpty {
                    AnnouncementView()
                } else {
                    MemoListContentView()
                        .padding(.top, 20)
                }
            }
            
            if !memoListViewModel.isEditMemoMode {
                // 메모 작성 플로팅 아이콘 버튼 뷰
                WriteMemoBtnTapped()
                    .padding(.bottom, 50)
                    .padding(.trailing, 20)
            }
            
        }
        .alert(
            "메모 \(memoListViewModel.removeMemoCount)개를 삭제하시겠습니까?",
            isPresented: $memoListViewModel.isDisplayRemoveMemoAlert
        ) {
            Button ("삭제", role: .destructive) {
                memoListViewModel.removeBtnTapped()
            }
            Button ("취소", role: .cancel) { }
        }
        .onChange(
            of: memoListViewModel.memos,
            perform: { memos in
                homeViewModel.setMemosCount(memos.count)
            }
        )
    }
}

// MARK: - MemoList 타이틀 뷰

private struct TitleView: View {
    @EnvironmentObject private var memoListViewModel: MemoListViewModel
    
    fileprivate var body: some View {
        HStack {
            if memoListViewModel.memos.isEmpty {
                Text("메모를\n추가해 보세요")
            } else {
                Text("메모 \(memoListViewModel.memos.count)개가 \n있습니다")
            }
            Spacer()
        }
        .font(.system(size: 30, weight: .bold))
        .padding(.leading, 20)
        .padding(.top, 20)
    }
    
}

// MARK: - MemoList 안내 뷰

private struct AnnouncementView: View {
    @EnvironmentObject private var memoListViewModel: MemoListViewModel
    
    fileprivate var body: some View {
        VStack(spacing: 15) {
            Spacer()
            
            Image("pencil")
                .renderingMode(.template)
            
            Text("\"퇴근 9시간 전 메모\"")
            Text("\"기획서 작성 후 퇴근하기 메모\"")
            Text("\"밀린 집안일 하기 메모\"")
            
            Spacer()
        }
        .font(.system(size: 16))
        .foregroundColor(.customGray2)
        .padding(.bottom, 50)
    }
    
}

// MARK: - MemoList 컨텐츠 뷰

private struct MemoListContentView: View {
    @EnvironmentObject private var memoListViewModel: MemoListViewModel
    
    fileprivate var body: some View {
        VStack {
            HStack {
                Text("메모 목록")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.leading, 20)
                
                Spacer()
            }
            
            ScrollView(.vertical) {
                VStack {
                    Rectangle()
                        .fill(Color.customGray0)
                        .frame(height: 1)
                    
                    ForEach(memoListViewModel.memos, id: \.self) { memo in
                        // Memo 셀 뷰에 memo들 넣어서 뷰 호출
                        MemoCellView(memo: memo)
                    }
                    
                }
            }
        }
        .padding(.bottom, 10) // ScrollView와 TabView간의 UI적인 이슈 해결을 위해 추가
    }
}

// MARK: - MemoList 셀 뷰

private struct MemoCellView: View {
    @EnvironmentObject private var pathModel: PathModel
    @EnvironmentObject private var memoListViewModel: MemoListViewModel
    @State private var isRemoveSelected: Bool
    private var memo: Memo
    
    fileprivate init (
        isRemoveSelected: Bool = false,
        memo: Memo
    ) {
        _isRemoveSelected = State(initialValue: isRemoveSelected)
        self.memo = memo
    }
    
    fileprivate var body: some View {
        Button (
            action: {
                pathModel.paths.append(.memoView(isCreateMode: false, memo: memo))
            },
            label: {
                
                VStack(spacing: 20) {
                    HStack {
                        
                        // 제목 + 시간
                        VStack(alignment: .leading, spacing: 5) {
                            Text(memo.title)
                                .font(.system(size: 16))
                                .foregroundColor(.customBlack)
                            
                            Text(memo.convertedDate)
                                .font(.system(size: 12))
                                .foregroundColor(.customIconGray)
                        }
                        
                        Spacer()
                        
                        // 편집 모드 체크 박스
                        if memoListViewModel.isEditMemoMode {
                            Button(
                                action: {
                                    isRemoveSelected.toggle()
                                    memoListViewModel.memoRemoveSelectedBoxTapped(memo)
                                },
                                label: {
                                    isRemoveSelected ? Image("selectedBox") : Image("unSelectedBox")
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Rectangle()
                        .fill(Color.customGray0)
                        .frame(height: 1)
                }
            }
            
        )
    }
}



// MARK: - 메모 작성 버튼

private struct WriteMemoBtnTapped: View {
    @EnvironmentObject private var pathModel: PathModel
    
    fileprivate var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button (
                    action: {
                        pathModel.paths.append(.memoView(isCreateMode: true, memo: nil))
                    },
                    label: { Image("writeBtn") }
                )
            }
        }
    }
    
    
}

#Preview {
    MemoListView()
        .environmentObject(PathModel())
        .environmentObject(MemoListViewModel())
}
