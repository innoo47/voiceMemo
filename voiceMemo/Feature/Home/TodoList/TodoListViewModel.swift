//
//  TodoListViewModel.swift
//  voiceMemo
//
//  Created by 박인호 on 1/22/24.
//

import Foundation

class TodoListViewModel: ObservableObject {
    @Published var todos: [Todo]                    // todo 목록 들
    @Published var isEditTodoMode: Bool         // Edit 모드 여부
    @Published var removeTodos: [Todo]              // 삭제 할 todo 목록 들
    @Published var isDisplayRemoveTodoAlert: Bool   // 삭제 할 todo의 체크 여부
    
    /// 삭제 될 todo 목록의 개수
    var removeTodosCount: Int {
        return removeTodos.count
    }
    
    /// 네비게이션 바 우측 버튼 모드
    var navigationBarRightBtnMode: NavigationBtnType {
        isEditTodoMode ? .complete : .edit
    }
    
    init(
        todos: [Todo] = [],
        isEditModeTodoMode: Bool = false,
        removeTodos: [Todo] = [],
        isDisplayRemoveTodoAlert: Bool = false
    ) {
        self.todos = todos
        self.isEditTodoMode = isEditModeTodoMode
        self.removeTodos = removeTodos
        self.isDisplayRemoveTodoAlert = isDisplayRemoveTodoAlert
    }
}


// 로직
extension TodoListViewModel {
    
    // 체크 박스 선택 시
    func selectedBoxTapped(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0 == todo }) {
            todos[index].selected.toggle()
        }
    }
    
    // todo 목록에 추가
    func addTodo(_ todo: Todo) {
        todos.append(todo)
    }
    
    // 네비게이션 바 오른쪽 버튼 탭 시
    func navigationRightBtnTapped() {
        if isEditTodoMode {
            if removeTodos.isEmpty {
                isEditTodoMode = false
            } else {
                // 삭제 얼럿 상태값 변경을 위한 메서드 호출
                setIsDisplayRemoveTodoAlert(true)
            }
        } else {
            isEditTodoMode = true
        }
    }
    
    func setIsDisplayRemoveTodoAlert(_ isDisplay: Bool) {
        isDisplayRemoveTodoAlert = isDisplay
    }
    
    // 삭제 박스 탭 시
    func todoRemoveSelectedBoxTapped(_ todo: Todo) {
        if let index = removeTodos.firstIndex(of: todo) {
            removeTodos.remove(at: index)
        } else {
            removeTodos.append(todo)
        }
    }
    
    // 삭제 버튼 탭 시 동작
    func removeBtnTapped() {
        todos.removeAll { todo in
            removeTodos.contains(todo)  // 삭제하기 위해 선택된 todo들과 일치하는 todo들을 배열에서 삭제
        }
        removeTodos.removeAll()         // 삭제할 todo들을 배열에서 모두 삭제
        isEditTodoMode = false          // 그 후 편집 모드에서 나감
    }
    
}
