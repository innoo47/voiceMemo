//
//  TodoListView.swift
//  voiceMemo
//
//  Created by 박인호 on 1/30/24.
//

import SwiftUI

struct TodoListView: View {
    @EnvironmentObject private var pathModel: PathModel
    @EnvironmentObject private var todoListViewModel: TodoListViewModel
    @EnvironmentObject private var homeViewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            
            VStack {
                // 투두 셀들의 유무에 따라 상단 바 존재 여부
                if !todoListViewModel.todos.isEmpty {
                    CustomNavigationBar(
                        isDisplayLeftBtn: false,
                        rightBtnAction: {
                            todoListViewModel.navigationRightBtnTapped()
                        },
                        rightBtnType: (
                            todoListViewModel.navigationBarRightBtnMode
                        )
                    )
                } else {
                    Spacer()
                        .frame(height: 30)
                }
                
                // 타이틀 뷰
                TitleView()
                
                if todoListViewModel.todos.isEmpty {
                    // 안내 뷰
                    AnnouncementView()
                } else {
                    
                    // 컨텐츠 뷰
                    TodoListContentView()
                        .padding(.top, 20)
                }
            }
            
            if !todoListViewModel.isEditTodoMode {
                // 작성 버튼
                WriteTodoBtnTapped()
                    .padding(.bottom, 50)
                    .padding(.trailing, 20)
            }
            
        }
        .alert(
            "To do List \(todoListViewModel.removeTodosCount)개 삭제하시겠습니까?",
            isPresented: $todoListViewModel.isDisplayRemoveTodoAlert
        ) {
            Button ("삭제", role: .destructive) {
                todoListViewModel.removeBtnTapped()
            }
            Button ("취소", role: .cancel) { }
        }
        .onChange(
            of: todoListViewModel.todos ,
            perform: { todos in
                homeViewModel.setTodosCount(todos.count)
            }
        )
    }
    
    // 프로퍼티
    //    var titleView: some View {
    //        Text("Title")
    //    }
    
    //  // 메소드
    //    func titleView: some View {
    //        Text("Title")
    //    }
}


// MARK: - TodoList 타이틀 뷰

private struct TitleView: View { // 하위뷰로 만들기
    //    @EnvironmentObject  <-- 써야하기 때문에 프로퍼티나 메소드로 사용하면 편리하지만
    // 자주 사용해야 하거나 할때는 외부에서도 사용가능하게 구조체로 따로 빼는 편이 편리
    @EnvironmentObject private var todoListViewModel: TodoListViewModel
    
    fileprivate var body: some View {
        HStack {
            if todoListViewModel.todos.isEmpty {
                Text("To do list를\n추가해 보세요")
            } else {
                Text("To do list \(todoListViewModel.todos.count)개가 \n있습니다")
            }
            Spacer()
        }
        .font(.system(size: 30, weight: .bold))
        .padding(.leading, 20)
        .padding(.top, 20)
        
    }
}


// MARK: - TodoList 안내 뷰

private struct AnnouncementView: View {
    
    fileprivate var body: some View {
        VStack(spacing: 15) {
            Spacer()
            
            Image("pencil")
                .renderingMode(.template)
            
            Text("\"매일 아침 8시에 운동가기\"")
            Text("\"내일 10시에 수강 신청하기\"")
            Text("\"1시 반 점심 약속\"")
            
            Spacer()
        }
        .font(.system(size: 16))
        .foregroundColor(.customGray2)
        .padding(.bottom, 50)
    }
}


// MARK: - TodoList 컨텐츠 뷰

private struct TodoListContentView: View {
    @EnvironmentObject private var todoListViewModel: TodoListViewModel
    
    fileprivate var body: some View {
        VStack {
            HStack {
                Text("할일 목록")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.leading, 20)
                
                Spacer()
            }
            
            ScrollView(.vertical) {
                VStack {
                    Rectangle()
                        .fill(Color.customGray0)
                        .frame(height: 1)
                    
                    ForEach(todoListViewModel.todos, id: \.self) { todo in
                        // MARK: - Todo 셀 뷰에 todo들 넣어서 뷰 호출
                        TodoCellView(todo: todo)
                    }
                    
                }
            }
        }
        .padding(.bottom, 10) // ScrollView와 TabView간의 UI적인 이슈로 인해 추가
    }
}


// MARK: - TodoList 셀 뷰

private struct TodoCellView: View {
    @EnvironmentObject private var todoListViewModel: TodoListViewModel
    @State private var isRemoveSelected: Bool
    private var todo: Todo
    
    fileprivate init (
        isRemoveSelected: Bool = false,
        todo: Todo
    ) {
        _isRemoveSelected = State(initialValue: isRemoveSelected)
        self.todo = todo
    }
    
    fileprivate var body: some View {
        VStack(spacing: 20) {
            HStack {
                
                // 기본 모드 체크 박스
                if !todoListViewModel.isEditTodoMode {
                    Button (
                        action: {
                            todoListViewModel.selectedBoxTapped(todo)
                        },
                        label: {
                            todo.selected ? Image("selectedBox") : Image("unSelectedBox")
                        }
                    )
                }
                
                // 제목 + 시간
                VStack(alignment: .leading, spacing: 5) {
                    Text(todo.title)
                        .font(.system(size: 16))
                        .foregroundColor(todo.selected ? .customIconGray : .customBlack)
                        .strikethrough(todo.selected)
                    
                    Text(todo.convertedDayAndTime)
                        .font(.system(size: 12))
                        .foregroundColor(.customIconGray)
                }
                
                Spacer()
                
                // 편집 모드 체크 박스
                if todoListViewModel.isEditTodoMode {
                    Button(
                        action: {
                            isRemoveSelected.toggle()
                            todoListViewModel.todoRemoveSelectedBoxTapped(todo)
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
}

//MARK: - 작성 버튼

private struct WriteTodoBtnTapped: View {
    @EnvironmentObject private var pathModel: PathModel
    
    fileprivate var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(
                    action: {
                        pathModel.paths.append(.todoView)
                    },
                    label: {
                        Image("writeBtn")
                    }
                )
            }
        }
    }
}

#Preview {
    TodoListView()
        .environmentObject(PathModel())
        .environmentObject(TodoListViewModel())
}
