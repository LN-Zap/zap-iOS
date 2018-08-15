//
//  Zap
//
//  Created by Otto Suess on 09.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import AVFoundation
import BTCUtil
import Lightning
import UIKit

final class QRCodeScannerView: UIView {
    private weak var overlayView: UIView?
    private weak var scanRectView: UIView?
    private weak var captureDevice: AVCaptureDevice?
    
    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var oldCode: String?
    
    var handler: ((String) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        DispatchQueue.main.async {
            self.setup()
        }
    }
    
    var lightningService: LightningService?
    
    private func setup() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInTrueDepthCamera, .builtInTelephotoCamera, .builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard
            let captureDevice = deviceDiscoverySession.devices.first,
            let input = try? AVCaptureDeviceInput(device: captureDevice)
            else { return }
        self.captureDevice = captureDevice
        
        captureSession.addInput(input)
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = layer.bounds
        layer.addSublayer(videoPreviewLayer)
        self.videoPreviewLayer = videoPreviewLayer
        
        captureSession.startRunning()
        
        let scanRectView = ScanRectView(frame: frame)
        addSubview(scanRectView)
        self.scanRectView = scanRectView
        
        setupOverlay()
        
        if captureDevice.hasTorch {
            setupFlashlightButton()
        }
        
        setupTopLabel()
    }
    
    private func setupTopLabel() {
        guard let scanRectView = scanRectView else { fatalError("scanRectView not initialized") }
        
        let topLabelContainer = UIView()
        topLabelContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        topLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        topLabelContainer.layer.cornerRadius = 16
        addSubview(topLabelContainer)
        
        NSLayoutConstraint.activate([
            topLabelContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            scanRectView.topAnchor.constraint(equalTo: topLabelContainer.bottomAnchor, constant: 20)
        ])
        
        let topLabel = UILabel()
        Style.Label.custom(color: UIColor.white.withAlphaComponent(0.6)).apply(to: topLabel)
        topLabel.text = "scene.qrcode_scanner.top_label".localized
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topLabelContainer.addSubview(topLabel)
        
        NSLayoutConstraint.activate([
            topLabel.topAnchor.constraint(equalTo: topLabelContainer.topAnchor, constant: 5),
            topLabelContainer.bottomAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 5),
            topLabel.leadingAnchor.constraint(equalTo: topLabelContainer.leadingAnchor, constant: 10),
            topLabelContainer.trailingAnchor.constraint(equalTo: topLabel.trailingAnchor, constant: 10)
        ])
    }
    
    private func setupOverlay() {
        let overlay = UIView()
        overlay.backgroundColor = .black
        overlay.alpha = 0.8
        overlay.clipsToBounds = true
        overlay.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlay)
        constrainEdges(to: overlay)
        self.overlayView = overlay
        
        updateOverlayMask()
    }
    
    private func updateOverlayMask() {
        let maskLayer = CAShapeLayer()
        
        let margin: CGFloat = 30
        let rectSize = bounds.width - margin * 2
        let yPosition = (bounds.height - rectSize) / 2 * 0.85
        
        let framePath = UIBezierPath(rect: bounds)
        
        let frame = CGRect(x: margin, y: yPosition, width: rectSize, height: rectSize)
        let path = UIBezierPath(roundedRect: frame, cornerRadius: 35)
        framePath.append(path.reversing())
        
        maskLayer.path = framePath.cgPath
        overlayView?.layer.mask = maskLayer
        
        scanRectView?.frame = frame
    }
    
    private func setupFlashlightButton() {
        guard let scanRectView = scanRectView else { return }
        
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icon_flashlight", in: Bundle.library, compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(toggleTorch), for: .touchUpInside)
        addSubview(button)
        bringSubview(toFront: button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.topAnchor.constraint(equalTo: scanRectView.bottomAnchor, constant: 30)
        ])
    }
    
    @objc private func toggleTorch() {
        setTorchOn(captureDevice?.torchMode == .off)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    private func setTorchOn(_ isOn: Bool) {
        do {
            try captureDevice?.lockForConfiguration()
            if isOn {
                try captureDevice?.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            } else {
                captureDevice?.torchMode = .off
            }
            captureDevice?.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        videoPreviewLayer?.frame = layer.bounds
        updateOverlayMask()
    }
    
    func stop() {
        UISelectionFeedbackGenerator().selectionChanged()
        
        overlayView?.alpha = 0
        
        captureSession.stopRunning()
    }
}

extension QRCodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard
            let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let code = metadataObj.stringValue,
            code != oldCode
            else { return }
        
        oldCode = code
        handler?(code)
    }
}
