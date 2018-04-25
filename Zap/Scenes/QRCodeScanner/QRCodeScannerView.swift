//
//  Zap
//
//  Created by Otto Suess on 09.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import AVFoundation
import BTCUtil
import UIKit

final class QRCodeScannerView: UIView {
    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var addressTypes: [AddressType]?
    var handler: ((AddressType, String) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard
            let captureDevice = deviceDiscoverySession.devices.first,
            let input = try? AVCaptureDeviceInput(device: captureDevice)
            else { return }
        
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        videoPreviewLayer?.frame = layer.bounds
    }
}

extension QRCodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard
            let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let code = metadataObj.stringValue,
            let addressTypes = addressTypes
            else { return }
        
        for addressType in addressTypes where addressType.isValidAddress(code, network: Settings.network) {
            handler?(addressType, code)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            captureSession.stopRunning()
            return
        }
    }
}
