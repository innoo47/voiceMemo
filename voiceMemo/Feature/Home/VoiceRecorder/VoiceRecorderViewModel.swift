//
//  VoiceRecorderViewModel.swift
//  voiceMemo
//
//  Created by 박인호 on 2/16/24.
//

import AVFoundation

class VoiceRecorderViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    // NSObject -> AVAudioPlayerDelegate를 채택하여 객체를 구현하기 위해서 NSObjectPlayer 프로토콜을 채택하거나
    // 또는 NSObject를 상속 받아서 간접적으로 RunTime 매커니즘을 사용할 수 있게 만들 수 있다.
    // ObservableObject -> AudioRecordManager 서비스 객체를 만들면서 해당 객체를 뷰에 얹어서 사용하기 위해 채택
    // AVAudioPlayerDelegate -> AVAudioPlayer의 Delegate를 사용하기 위해
    
    @Published var isDisplayRemoveVoiceRecorderAlert: Bool  // 삭제 얼럿 표시 여부를 나타내는 퍼블리셔
    @Published var isDisplayAlert: Bool                     // 얼럿 표시 여부를 나타내는 퍼블리셔
    @Published var alertMessage: String                     // 얼럿에 표시 될 메시지
    
    
    // 음성 녹음 관련 프로퍼티
    var audioRecorder: AVAudioRecorder?
    @Published var isRecording: Bool        // 음성 녹음 중 여부
    
    // 음성 재생 관련 프로퍼티
    var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool          // 음성 재생 중 여부
    @Published var isPaused: Bool           // 음성 재생이 일시정지된 상태 여부
    @Published var playedTime:TimeInterval  // 재생중인 음성의 현재 재생 시간
    private var progressTimer: Timer?
    
    // 음성 메모 된 파일
    var recordedFiles: [URL]
    
    // 현재 선택된 음성메모 파일
    @Published var selectedRecordedFile: URL?
    
    // 초기화
    init(
        isDisplayRemoveVoiceRecorderAlert: Bool = false,
        isDisplayErrorAlert: Bool = false,
        errorAlertMessage: String = "",
        isRecording: Bool = false,
        isPlaying: Bool = false,
        isPaused: Bool = false,
        playedTime: TimeInterval = 0,
        recordedFiles: [URL] = [],
        selectedRecordedFile: URL? = nil
    ) {
        self.isDisplayRemoveVoiceRecorderAlert = isDisplayRemoveVoiceRecorderAlert
        self.isDisplayAlert = isDisplayErrorAlert
        self.alertMessage = errorAlertMessage
        self.isRecording = isRecording
        self.isPlaying = isPlaying
        self.isPaused = isPaused
        self.playedTime = playedTime
        self.recordedFiles = recordedFiles
        self.selectedRecordedFile = selectedRecordedFile
    }
    
}


// MARK: - 로직

extension VoiceRecorderViewModel {
    
    // 음성메모 셀을 탭했을 때의 동작을 처리합니다.
    func voiceRecorderCellTapped(_ recordedFile: URL) {
        if self.selectedRecordedFile != recordedFile {
            // 재생 중인 음성메모를 중지합니다.
            self.stopPlaying()
            
            // 프로그래스 바와 재생된 시간을 초기화합니다.
            self.playedTime = 0
            self.progressTimer?.invalidate() // 이전 타이머가 실행 중인 경우 중지
            
            // 선택된 음성메모를 업데이트합니다.
            self.selectedRecordedFile = recordedFile
            
        }
    }
    
    // 삭제 버튼을 탭했을 때의 동작을 처리합니다.
    func removeBtnTapped() {
        // 삭제 얼럿을 표시하기 위한 상태를 변경합니다.
        setIsDisplayRemoveVoiceRecorderAlert(true)
    }
    
    // 선택된 음성메모를 삭제합니다.
    func removeSelectedVoiceRecord() {
        guard let fileToRemove = selectedRecordedFile,
              let indexToRemove = recordedFiles.firstIndex(of: fileToRemove) else {
            // 선택된 음성메모를 찾을 수 없는 경우 에러를 표시합니다.
            displayAlert(message: "선택된 음성 메모를 찾을 수 없습니다.")
            return
        }
        
        do {
            // 파일을 삭제하고 관련 데이터를 업데이트합니다.
            try FileManager.default.removeItem(at: fileToRemove)
            recordedFiles.remove(at: indexToRemove)
            selectedRecordedFile = nil
            
            // 삭제 성공을 알리는 얼럿을 표시합니다.
            displayAlert(message: "선택된 음성메모 파일을 성공적으로 삭제했습니다.")
            
        } catch {
            // 삭제 중 에러가 발생한 경우 에러를 표시합니다.
            displayAlert(message: "선택된 음성 메모 파일을 삭제 중 오류가 발생했습니다.")
            // 확인을 누르면 다시 시도하거나 서버에서 서버 데이터를 다시 호출할 수 있습니다.
            
        }
    }
    
    // 삭제 얼럿을 표시하기 위한 상태를 설정합니다.
    private func setIsDisplayRemoveVoiceRecorderAlert(_ isDisplay: Bool) {
        isDisplayRemoveVoiceRecorderAlert = isDisplay
    }
    
    // 에러 메세지를 설정합니다.
    private func setErrorAlertMessage(_ message: String) {
        alertMessage = message
    }
    
    // 에러 얼럿을 표시하기 위한 상태를 설정합니다.
    private func setIsDisplayErrorAlert(_ isDisplay: Bool) {
        isDisplayAlert = isDisplay
    }
    
    // 얼럿 메세지를 표시합니다.
    private func displayAlert(message: String) {
        // 에러 메세지를 설정하고 에러 얼럿을 표시합니다.
        setErrorAlertMessage(message)
        setIsDisplayErrorAlert(true)
    }
}


// MARK: - 음성메모 녹음 관련

extension VoiceRecorderViewModel {
    
    // 녹음 버튼을 탭했을 때의 동작을 처리합니다.
    func recordBtnTapped() {
        selectedRecordedFile = nil
        
        if isPlaying {
            // 현재 재생 중이라면 재생을 중지합니다.
            stopPlaying()
            
            // 재생을 중지하고 녹음을 시작하는 메서드 호출
            startRecording()
            
        } else if isRecording {
            // 현재 녹음 중이라면 녹음을 중지합니다.
            stopRecording()
            
        } else {
            // 녹음을 시작합니다.
            startRecording()
        }
    }
    
    // 녹음을 시작하는 메서드
    private func startRecording() {
        // 새로운 녹음 파일을 저장할 URL 생성
        let fileURL = getDocumentsDirectory().appendingPathComponent("새로운 녹음 \(recordedFiles.count + 1)")
        
        // 오디오 녹음 설정
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC), // 오디오 포맷 지정
            AVSampleRateKey: 12000, // 샘플 속도 설정
            AVNumberOfChannelsKey: 1, // 채널 수 설정
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue // 오디오 품질 설정
        ]
        
        // 오디오 녹음기 생성 및 설정
        do {
            self.audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            try AVAudioSession.sharedInstance().setCategory(.record)
            try AVAudioSession.sharedInstance().setActive(true)
            self.audioRecorder?.record() // 녹음 시작
            self.isRecording = true // 녹음 중 상태로 변경
        } catch {
            // 오류가 발생한 경우 알림을 표시합니다.
            self.displayAlert(message: "음성메모 녹음 중 오류가 발생하였습니다.")
        }
    }
    
    // Documents 디렉토리의 URL을 반환합니다.
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // 녹음을 중지하는 메서드
    private func stopRecording() {
        audioRecorder?.stop()
        // 녹음된 파일을 recordedFiles 배열에 추가합니다.
        self.recordedFiles.append(self.audioRecorder!.url)
        self.isRecording = false
        
        print("\(self.audioRecorder!.url)")
    }
    
}


// MARK: - 음성메모 재생 관련

extension VoiceRecorderViewModel {
    
    // 음성메모 재생을 시작합니다.
    func startPlaying(recordingURL: URL) {
        do {
            // AVAudioPlayer를 생성하고 재생합니다.
            self.audioPlayer = try AVAudioPlayer(contentsOf: recordingURL)
            self.audioPlayer?.delegate = self
            try AVAudioSession.sharedInstance().setCategory(.playback)  // 오디오 세션 준비
            try AVAudioSession.sharedInstance().setActive(true)         // 오디오 세션 활성화
            self.audioPlayer?.play()
            self.isPlaying = true
            self.isPaused = false
            
            print("\(recordingURL)")
            
            // 재생 진행 상황을 업데이트하는 타이머를 시작합니다.
            self.progressTimer = Timer.scheduledTimer(
                withTimeInterval: 0.1,
                repeats: true
            ) { _ in
                // 현재시각 업데이트 메서드 호출
                self.updateCurrentTime()
            }
        } catch {
            // 오류가 발생한 경우 알림을 표시합니다.
            self.displayAlert(message: "음성메모 재생 중 오류가 발생했습니다.")
        }
    }
    
    // 재생 중인 음성메모의 현재 재생 시간을 업데이트합니다.
    private func updateCurrentTime() {
        self.playedTime = audioPlayer?.currentTime ?? 0
    }
    
    // 음성메모 재생을 중지합니다.
    func stopPlaying() {
        self.audioPlayer?.stop()
        self.isPlaying = false
        self.isPaused = false
    }
    
    // 음성메모 재생을 일시 정지합니다.
    func pausePlaying() {
        self.audioPlayer?.pause()
        self.isPaused = true
    }
    
    // 일시 정지된 음성메모 재생을 다시 시작합니다.
    func resumePlaying() {
        self.audioPlayer?.play()
        self.isPaused = false
    }
    
    // 음성메모 파일의 정보를 가져옵니다.
    func getFileinfo(for url: URL) -> (Date?, TimeInterval?) {
        let fileManager = FileManager.default
        var creationDate: Date?
        var duration: TimeInterval?
        
        do {
            // 파일 생성일을 가져옵니다.
            let fileAttributes = try fileManager.attributesOfItem(atPath: url.path)
            creationDate = fileAttributes[.creationDate] as? Date
        } catch {
            // 파일 정보를 가져오는 데 실패한 경우 알림을 표시합니다.
            self.displayAlert(message: "선택된 음성메모 파일 정보를 가져올 수 없습니다.")
        }
        
        do {
            // 재생 시간을 가져옵니다.
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            duration = audioPlayer.duration
            
        } catch {
            // 재생 시간을 가져오는 데 실패한 경우 알림을 표시합니다.
            self.displayAlert(message: "선택된 음성메모 파일의 재생 시간을 불러올 수 없습니다. ")
        }
        
        return (creationDate, duration)
    }
    
}
