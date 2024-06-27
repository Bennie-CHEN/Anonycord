//
//  RecordView.swift
//  Anonycord
//
//  Created by c22 on 18/12/2022.
//  Updated by Bennie on 27/06/2024
//
import SwiftUI
import Photos
import AVFoundation

struct RecordView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return RecordViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

class RecordViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    @State private var showOverlay = false
    var captureSession: AVCaptureSession!
    var movieFileOutput: AVCaptureMovieFileOutput!
    var tapCount = 0
    let currentDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        
        // 设置分辨率
        captureSession.sessionPreset = .hd1920x1080 // 设置为1080p高清分辨率
        
        // 使用前置摄像头
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            UIApplication.shared.alert(title:"App Message", body: "Unable to access front cam")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            captureSession.addInput(input)
        } catch {
            UIApplication.shared.alert(title:"App Message", body: "Unable to access front cam")
            return
        }
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            UIApplication.shared.alert(title:"App Message", body: "Unable to access audio device")
            return
        }
        
        do {
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            captureSession.addInput(audioInput)
        } catch {
            UIApplication.shared.alert(title:"App Message", body: "Unable to access audio device")
            return
        }
        
        movieFileOutput = AVCaptureMovieFileOutput()
        captureSession.addOutput(movieFileOutput)
        
        let connection = movieFileOutput.connection(with: .video)
        let recordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        recordButton.center = view.center
        recordButton.setTitle("-------", for: .normal) // 按钮标题
        if self.traitCollection.userInterfaceStyle == .dark {
            recordButton.setTitleColor(.black, for: .normal)
        } else {
            recordButton.setTitleColor(.white, for: .normal)
        }
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        view.addSubview(recordButton)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        captureSession.startRunning()
    }

    @objc func recordButtonTapped() {
        if movieFileOutput.isRecording {
            movieFileOutput.stopRecording()
            bzzz()
        } else {
            self.movieFileOutput.startRecording(to: URL(fileURLWithPath: NSTemporaryDirectory() + "\(currentDate)-anonycording.mp4"), recordingDelegate: self)
            bzzz()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            UIApplication.shared.alert(title:"App Message", body: "Error recording video: \(error!.localizedDescription)")
        } else {
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, #selector(videoSaved(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if movieFileOutput.isRecording {
            movieFileOutput.stopRecording()
        }
    }
    
    @objc func videoSaved(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        if error != nil {
            UIApplication.shared.alert(title:"App Message", body: "Error saving video: \(error!.localizedDescription)")
        } else {
            UIApplication.shared.alert(title:"App Message", body: "Video saved successfully")
            exit(0)
        }
    }
    
    @objc func viewTapped() {
        tapCount += 1
        if tapCount == 2 {
            view.backgroundColor = .black
            movieFileOutput.stopRecording()
            bzzz()
        } else {
            view.backgroundColor = .black
            bzzz()
        }
    }
}

