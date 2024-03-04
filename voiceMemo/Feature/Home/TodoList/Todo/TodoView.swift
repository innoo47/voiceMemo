//
//  TodoView.swift
//  voiceMemo
//
//  Created by 박인호 on 2/1/24.
//

import SwiftUI

struct TodoView: View {
    @EnvironmentObject private var pathModel: PathModel
    @EnvironmentObject private var todoListViewModel: TodoListViewModel
    @StateObject private var todoViewModel = TodoViewModel()
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                
                leftBtnAction: { // 뒤로가기 버튼 클릭시 최상단의 TodoView가 닫힘
                    pathModel.paths.removeLast()
                },
                
                rightBtnAction: {
                    todoListViewModel.addTodo(
                        .init(
                            title: todoViewModel.title,
                            time: todoViewModel.time,
                            day: todoViewModel.day,
                            selected: false
                        )
                    )
                    pathModel.paths.removeLast()
                    
                },
                
                rightBtnType: .create
            )
            
            
            // 타이틀 뷰
            TitleView()
                .padding(.top, 20)
            
            Spacer()
                .frame(height: 20)
            
            // 투 두 타이틀 뷰 (텍스트 필드)
            TodoTitleView(todoViewModel: todoViewModel)
                .padding(.leading, 20)
            
            // 시간 선택
            SelectTimeView(todoViewModel: todoViewModel)
            
            // 날짜 선택
            SelectDayView(todoViewModel: todoViewModel)
                .padding(.leading, 20)
            
            Spacer()
        }
    }
}

//MARK: - 타이틀 뷰

private struct TitleView: View {
    
    
    fileprivate var body: some View {
        HStack {
            Text("To do List를\n추가해 보세요.")
            
            Spacer()
        }
        .font(.system(size: 30, weight: .bold))
        .padding(.leading, 20)
    }
}

//MARK: - 투 두 타이틀 뷰 (제목 입력 뷰)

private struct TodoTitleView: View {
    @ObservedObject private var todoViewModel: TodoViewModel
    
    fileprivate init(todoViewModel: TodoViewModel) {
        self.todoViewModel = todoViewModel
    }
    
    fileprivate var body: some View {
        TextField("제목을 입력하세요.", text: $todoViewModel.title)
    }
}

//MARK: - 시간 선택

private struct SelectTimeView: View {
    @ObservedObject private var todoViewModel: TodoViewModel
    
    fileprivate init(todoViewModel: TodoViewModel) {
        self.todoViewModel = todoViewModel
    }
    
    fileprivate var body: some View {
        VStack {
            Rectangle()
                .fill(Color.customGray0)
                .frame(height: 1)
            
            DatePicker(
                "",
                selection: $todoViewModel.time,
                displayedComponents: [.hourAndMinute]
            )
            .labelsHidden()
            .datePickerStyle(WheelDatePickerStyle())
            .frame(maxWidth: .infinity, alignment: .center)
            
            Rectangle()
                .fill(Color.customGray0)
                .frame(height: 1)
        }
    }
}

//MARK: - 날짜 선택 뷰

private struct SelectDayView: View {
    @ObservedObject private var todoViewModel: TodoViewModel
    
    fileprivate init(todoViewModel: TodoViewModel) {
        self.todoViewModel = todoViewModel
    }
    
    fileprivate var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("날짜")
                    .foregroundColor(.customIconGray)
                
                Spacer()
            }
            
            HStack {
                Button(
                    action: {todoViewModel.setIsDisplayCalender(true)},
                    label: {
                        Text("\(todoViewModel.day.formattedDay)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.customGreen)
                        
                        
                        
                    }
                )
                .popover(isPresented: $todoViewModel.isDisplayCalender) {
                    DatePicker(
                        "",
                        selection: $todoViewModel.day,
                        displayedComponents: .date
                        
                    )
                    .labelsHidden()
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .onChange(of: todoViewModel.day) { _ in
                        todoViewModel.setIsDisplayCalender(false)
                    }
                    
                    
                }
                Spacer()
                
            }
        }
    }
}

#Preview {
    TodoView()
}
