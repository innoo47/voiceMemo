//
//  VoiceRecorderView.swift
//  voiceMemo
//
//  Created by 박인호 on 2/23/24.
//

import SwiftUI

struct VoiceRecorderView: View {
    @StateObject private var voiceRecorderViewModel = VoiceRecorderViewModel()
    @EnvironmentObject private var homeViewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            
            VStack {
                
                // 타이틀 뷰
                TitleView()
                
                if voiceRecorderViewModel.recordedFiles.isEmpty {
                    // 안내 뷰
                    AnnouncementView()
                } else {
                    // 보이스 레코더 리스트 뷰
                    VoiceRecorderListView(voiceReorderViewModel: voiceRecorderViewModel)
                    
                }
                
                Spacer()
            }
            
            // 녹음 버튼 뷰
            RecordBtnView(voiceRecorderViewModel: voiceRecorderViewModel)
                .padding(.trailing, 23)
                .padding(.bottom, 56)
        }
        .alert(
            "선택된 음성 메모를 삭제 하시겠습니까?",
            isPresented: $voiceRecorderViewModel.isDisplayRemoveVoiceRecorderAlert
        ) {
            Button("삭제", role: .destructive) {
                voiceRecorderViewModel.removeSelectedVoiceRecord()
            }
            Button("취소", role: .cancel) { }
        }
        .alert (
            voiceRecorderViewModel.alertMessage,
            isPresented: $voiceRecorderViewModel.isDisplayAlert
        ) {
            Button("확인", role: .cancel) {   }
        }
        .onChange(
            of: voiceRecorderViewModel.recordedFiles,
            perform: { recordedFiles in
                homeViewModel.setVoiceRecordersCount(recordedFiles.count)
        })
        
    }
}


// MARK: - 타이틀 뷰

private struct TitleView: View {
    fileprivate var body: some View {
        HStack {
            Text("음성메모")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.customBlack)
            
            Spacer()
        }
        .padding(.leading, 20)
        .padding(.top, 50)
    }
}


// MARK: - 안내 뷰

private struct AnnouncementView: View {
    
    fileprivate var body: some View {
        
        VStack(spacing: 15) {
            Rectangle()
                .fill(Color.customCoolGray)
                .frame(height: 1)
            
            Spacer()
                .frame(height: 100)
            
            Image("pencil")
                .renderingMode(.template)
            
            Text("현재 등록된 음성메모가 없습니다.")
            Text("하단의 녹음버튼을 눌러 음성메모를 시작해주세요.")
            
            Spacer()
        }
        .font(.system(size: 16))
        .foregroundColor(.customGray2)
        .padding(.top, 100)
        
    }
}

// MARK: - 음성메모 리스트 뷰

private struct VoiceRecorderListView: View {
    @ObservedObject private var voiceReorderViewModel: VoiceRecorderViewModel
    
    fileprivate init(voiceReorderViewModel: VoiceRecorderViewModel) {
        self.voiceReorderViewModel = voiceReorderViewModel
    }
    
    fileprivate var body: some View {
        ScrollView(.vertical) {
            VStack {
                Rectangle()
                    .fill(Color.customGray0)
                    .frame(height: 1)
                
                ForEach(voiceReorderViewModel.recordedFiles, id: \.self) { recordedFile in
                    // 음성메모 셀 뷰 호출
                    VoiceRecorderCellView(
                        voiceRecordedViewModel: voiceReorderViewModel,
                        recordedFile: recordedFile)
                    
                }
                
            }
        }
    }
}

// MARK: - 음성메모 셀 뷰

private struct VoiceRecorderCellView: View {
    @ObservedObject private var voiceRecorderViewModel: VoiceRecorderViewModel
    private var recordedFile: URL
    private var creationDate: Date?
    private var duration: TimeInterval?
    private var prograssBarValue: Float {
        if voiceRecorderViewModel.selectedRecordedFile == recordedFile
            && (voiceRecorderViewModel.isPlaying || voiceRecorderViewModel.isPaused) {
            return Float(voiceRecorderViewModel.playedTime) / Float(duration ?? 1)
        } else {
            return 0
        }
    }
    
    fileprivate init(
        voiceRecordedViewModel: VoiceRecorderViewModel,
        recordedFile: URL
    ) {
        self.voiceRecorderViewModel = voiceRecordedViewModel
        self.recordedFile = recordedFile
        (self.creationDate, self.duration) = voiceRecorderViewModel.getFileinfo(for: recordedFile)
    }
    
    fileprivate var body: some View {
        VStack {
            Button (
                action: {
                    withAnimation(nil) {    // 음성메모 셀 탭 시 애니메이션 삭제
                        voiceRecorderViewModel.voiceRecorderCellTapped(recordedFile)
                    }
                },
                label: {
                    VStack {
                        // 제목
                        HStack {
                            Text(recordedFile.lastPathComponent)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.customBlack)
                            
                            Spacer()
                        }
                        
                        Spacer()
                            .frame(height: 5)
                        
                        
                        HStack {
                            // 음성 메모가 생성된 날짜
                            if let creationDate = creationDate {
                                Text(creationDate.formattedVoiceRecoderTime)
                                    .font(.system(size: 14))
                                    .foregroundColor(.customIconGray)
                            }
                            
                            Spacer()
                            
                            // 음성 메모 파일의 전체 녹음 시간
                            if voiceRecorderViewModel.selectedRecordedFile != recordedFile,
                               let duration = duration {
                                Text(duration.formattedTimeInterval)
                                    .font(.system(size: 14))
                                    .foregroundColor(.customIconGray)
                            }
                        }
                    }
                }
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            // 음성 메모 파일이 선택 되어질 경우 생기는 프로그래스 바
            if voiceRecorderViewModel.selectedRecordedFile == recordedFile {
                VStack {
                    // 프로그래스 바
                    ProgressBar(progress: prograssBarValue)
                        .frame(height: 2)
                    
                    Spacer()
                        .frame(height: 5)
                    
                    HStack {
                        // 재생 시간
                        Text(voiceRecorderViewModel.playedTime.formattedTimeInterval)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.customIconGray)
                        
                        Spacer()
                        
                        // 남은 시간
                        if let duration = duration {
                            Text(duration.formattedTimeInterval)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.customIconGray)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 10)
                    
                    HStack {
                        Spacer()
                        
                        // 플레이 버튼
                        Button(
                            action: {
                                // 문제: 다른 음성 메모로 넘어가서 재생 시 전 음성메모가 재생됨 : 해결
                                if voiceRecorderViewModel.isPaused {
                                    voiceRecorderViewModel.resumePlaying()
                                } else {
                                    voiceRecorderViewModel.startPlaying(recordingURL: recordedFile)
                                }
                            },
                            label: {
                                Image("play")
                                    .renderingMode(.template)
                                    .foregroundColor(.customBlack)
                            }
                        )
                        
                        Spacer()
                            .frame(width: 20)
                        
                        // 일시 정지 버튼
                        Button(
                            action: {
                                if voiceRecorderViewModel.isPlaying {
                                    voiceRecorderViewModel.pausePlaying()                                }
                            },
                            label: {
                                Image("pause")
                                    .renderingMode(.template)
                                    .foregroundColor(.customBlack)
                            }
                        )
                        
                        Spacer()
                        
                        // 삭제 버튼
                        Button(
                            action: {
                                voiceRecorderViewModel.removeBtnTapped()
                            },
                            label: {
                                Image("trash")
                                    .renderingMode(.template)
                                    .foregroundColor(.customBlack)
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.leading, 50)
                }
                .padding(.horizontal, 20)
                
            }
            
            Rectangle()
                .fill(Color.customGray0)
                .frame(height: 1)
        }
    }
}

// MARK: - 프로그래스 바

private struct ProgressBar: View {
    private var progress: Float
    
    fileprivate init(progress: Float) {
        self.progress = progress
    }
    
    fileprivate var body: some View {
        // 전체에서 진행률에 따라 막대 바가 늘어나는 것을 표현하기 위해 사용
        GeometryReader { geometry in
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.customGray2)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: CGFloat(self.progress) * geometry.size.width)
                
            }
            
        }
    }
}

// MARK: - 녹음 버튼

private struct RecordBtnView: View {
    @ObservedObject private var voiceRecorderViewModel: VoiceRecorderViewModel
    
    fileprivate init(voiceRecorderViewModel: VoiceRecorderViewModel) {
        self.voiceRecorderViewModel = voiceRecorderViewModel
    }
    
    fileprivate var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(
                    action: {
                        voiceRecorderViewModel.recordBtnTapped()
                    },
                    label: {
                        if voiceRecorderViewModel.isRecording {
                            Image("mic_recording")
                        } else {
                            Image("mic")
                        }
                    }
                )
                
            }
        }
    }
}



#Preview {
    VoiceRecorderView()
}
