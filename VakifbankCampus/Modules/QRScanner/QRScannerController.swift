//
//  QRScannerController.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 22.08.2024.
//

import UIKit
import AVFoundation

class QRScannerController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    typealias QRCodeCompletion = (String) -> Void
    var onQRCodeScanned: QRCodeCompletion?
    
    var qrValueString: String?
    var isProcessing = false
    
    let vakifbankColor = UIColor(red: 246/255.0, green: 178/255.0, blue: 5/255.0, alpha: 255/255.0)
    var titleString = ""
    
    lazy var label_qr_title = Labels(textLabel: titleString, fontLabel: .systemFont(ofSize: 16), textColorLabel: vakifbankColor)
    
    lazy var imageInfoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "info.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = vakifbankColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Vazgeç", for: .normal)
        button.tintColor = .white
        button.backgroundColor = vakifbankColor
        button.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var video = AVCaptureVideoPreviewLayer()
    var captureSession = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationItem.hidesBackButton = true
        addTargetOnButton()
        setupCamera()
        setupUI()
    }

    private func setupCamera() {
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession.addInput(input)
        } catch {
            print("Kamera giriş hatası")
        }
        
        let output = AVCaptureMetadataOutput()
        captureSession.addOutput(output) 
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.qr]
        
        video = AVCaptureVideoPreviewLayer(session: captureSession)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        
        captureSession.startRunning()
    }
    
    private func setupUI() {
        setConstarintSquare()
        setConstraintCancelButton()
        
        view.bringSubviewToFront(imageInfoIcon)
        view.bringSubviewToFront(label_qr_title)
        view.bringSubviewToFront(cancelButton)
    }

    private func setConstarintSquare() {
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
   
          
        
        view.addSubview(imageInfoIcon)
        view.addSubview(label_qr_title)
        label_qr_title.textAlignment = .center
        label_qr_title.numberOfLines = 0
        label_qr_title.lineBreakMode = .byWordWrapping
        label_qr_title.anchor(
            top:view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 100,
            paddingLeft: 20,
            paddingRight: 20,
            height: 50
        )
        
        // imageInfoIcon constraints
        NSLayoutConstraint.activate([
            imageInfoIcon.bottomAnchor.constraint(equalTo: label_qr_title.topAnchor, constant: -10),
            imageInfoIcon.centerXAnchor.constraint(equalTo: label_qr_title.centerXAnchor),
            imageInfoIcon.widthAnchor.constraint(equalToConstant: 30),
            imageInfoIcon.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func setConstraintCancelButton() {
        view.addSubview(cancelButton)
        cancelButton.anchor(
            left: view.leftAnchor,
            right: view.rightAnchor,
            bottom: view.bottomAnchor,
            paddingBottom: 30,
            paddingLeft: 100,
            paddingRight: 100,
            width: 50,
            height: 50
        )
    }

    private func addTargetOnButton() {
        cancelButton.addTarget(self, action: #selector(tappedCancelButton), for: .touchUpInside)
    }
    
    @objc private func tappedCancelButton() {
        navigationController?.popViewController(animated: true)
        tabBarController?.tabBar.isHidden = false
        (tabBarController as? TabBarController)?.showTopView()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !isProcessing, !metadataObjects.isEmpty else { return }
        
        isProcessing = true
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject, readableObject.type == .qr else { return }
            if let qrCodeValue = readableObject.stringValue {
                onQRCodeScanned?(qrCodeValue)
                return
            }
        }
        onQRCodeScanned?("")
    }
    
    func getQrValueString(completion: @escaping (String) -> Void) {
    
        isProcessing = false
        captureSession.startRunning()
        onQRCodeScanned = { qrCodeValue in
            if !qrCodeValue.isEmpty {
                print("QR Kodu Değeri: \(qrCodeValue)")
                completion(qrCodeValue)
            } else {
                print("QR kodu bulunamadı.")
                completion("nil")
            }
        }
    }
}

