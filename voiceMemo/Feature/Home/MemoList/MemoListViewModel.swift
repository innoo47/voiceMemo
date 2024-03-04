//
//  MemoListViewModel.swift
//  voiceMemo
//
//  Created by 박인호 on 2/6/24.
//

import Foundation

class MemoListViewModel: ObservableObject {
    @Published var memos: [Memo]                     // memo 목록 들
    @Published var isEditMemoMode: Bool             // Edit 모드 여부
    @Published var removeMemos: [Memo]              // 삭제 할 memo 목록 들
    @Published var isDisplayRemoveMemoAlert: Bool   // 삭제 할 memo의 체크 여부
    
    // 삭제할 메모 개수
    var removeMemoCount: Int {
        return removeMemos.count
    }
    
    // 네비게이션 바 우측 버튼 모드
    var navigationBarRightBtnMode: NavigationBtnType {
        isEditMemoMode ? .complete : .edit
    }
    
    init(
        memos: [Memo] = [],
        isEditMemoMode: Bool = false,
        removeMemos: [Memo] = [],
        isDisplayRemoveMemoAlert: Bool = false
    ) {
        self.memos = memos
        self.isEditMemoMode = isEditMemoMode
        self.removeMemos = removeMemos
        self.isDisplayRemoveMemoAlert = isDisplayRemoveMemoAlert
    }
    
}


// 로직
extension MemoListViewModel {
    
    // 메모 추가
    func addMemo(_ memo: Memo) {
        memos.append(memo)
    }
    
    // 확인 및 수정을 위해
    func updateMemo(_ memo: Memo) {
        if let index = memos.firstIndex(where: { $0.id == memo.id } ) {
            memos[index] = memo
        }
    }
    
    // 메모 삭제를 위해
    func removeMemo(_ memo: Memo) {
        if let index = memos.firstIndex(where: { $0.id == memo.id }) {
            memos.remove(at: index)
        }
    }
    
    // 네비게이션 바 오른쪽 버튼 탭 시
    func navigationRightBtnTapped() {
        if isEditMemoMode {
            if removeMemos.isEmpty {
                isEditMemoMode = false
            } else {
                // 삭제 얼럿 상태값 변경을 위한 메서드 호출
                setIsDisplayRemoveMemoAlert(true)
            }
        } else {
            isEditMemoMode = true
        }
    }
    
    func setIsDisplayRemoveMemoAlert(_ isDisplay: Bool) {
        isDisplayRemoveMemoAlert = isDisplay
    }
    
    // 삭제 박스 탭 시
    func memoRemoveSelectedBoxTapped(_ memo: Memo) {
        if let index = removeMemos.firstIndex(of: memo) {
            removeMemos.remove(at: index)
        } else {
            removeMemos.append(memo)
        }
    }
    
    // 삭제 버튼 탭 시
    func removeBtnTapped() {
        memos.removeAll { memo in
            removeMemos.contains(memo)  // 삭제하기 위해 선택된 memo들과 일치하는 memo들을 배열에서 삭제
        }
        removeMemos.removeAll()         // 삭제할 memo들을 배열에서 모두 삭제
        isEditMemoMode = false          // 그 후 편집 모드에서 나감
    }
    
    
}
