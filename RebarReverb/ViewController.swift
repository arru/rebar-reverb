//
//  ViewController.swift
//  RebarReverb
//
//  Created by Arvid Rudling on 2016-12-15.
//  Copyright © 2016 Allihoopa. All rights reserved.
//

import UIKit
import CoreAudioKit
import AVFoundation


class BarcodeHighlightView : UIView {

	var borderLayer = CAShapeLayer()

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override init(frame:CGRect) {
		super.init(frame:frame)

		borderLayer.strokeColor = UIColor.red.cgColor
		borderLayer.lineWidth = 8.0
		borderLayer.fillColor = UIColor.clear.cgColor
		borderLayer.opacity = 0.0
		borderLayer.frame = frame
		self.layer.addSublayer(borderLayer)
	}

	func setHighlightStatus(color: UIColor?, corners: [Any]){

		if let newColor = color {
			let path = UIBezierPath()

			path.move(to: cornerArrayToCGPoint(corners: corners, index: 0))
			var i = 1
			while i < corners.count {
				path.addLine(to: cornerArrayToCGPoint(corners: corners, index: i))
				i += 1
			}
			path.addLine(to: cornerArrayToCGPoint(corners: corners, index: 0))

			let borderCGPath = path.cgPath
			borderLayer.path = borderCGPath

			self.setNeedsLayout()

			borderLayer.strokeColor = newColor.cgColor

			borderLayer.removeAllAnimations()

			let fade = CABasicAnimation (keyPath:"opacity")
			fade.fromValue = 1.0
			fade.toValue = 0.0
			fade.duration = 1.5

			borderLayer.add(fade, forKey:"fadeAnimation")
			self.layoutIfNeeded()
		}
	}
}


class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

	var engine: AVAudioEngine!
	var reverb: AVAudioUnitReverb!
	var delay: AVAudioUnitDelay!
	var currentParameterCode: Int = 0

	@IBOutlet var previewView: UIView!
	let barcodeCaptureSession = AVCaptureSession()
	var previewLayer: AVCaptureVideoPreviewLayer!
	var  _barcodeHighlight : BarcodeHighlightView?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		initializeEngine()

		engine.prepare()

		initializeBarcodeCapture()
		addBarcodePreviewLayer()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewWillAppear(_ animated: Bool) {
		try! engine.start()
		barcodeCaptureSession.startRunning()
	}

	override func viewWillDisappear(_ animated: Bool) {
		barcodeCaptureSession.stopRunning()
		engine.stop()
	}

	override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
		return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.portraitUpsideDown]
	}

	func initializeBarcodeCapture() {

		let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

		let inputDevice = try! AVCaptureDeviceInput(device: captureDevice)
		barcodeCaptureSession.addInput(inputDevice)

		let output = AVCaptureMetadataOutput()
		barcodeCaptureSession.addOutput(output)
		output.metadataObjectTypes = output.availableMetadataObjectTypes

		output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
	}

	func addBarcodePreviewLayer() {
		previewLayer = AVCaptureVideoPreviewLayer(session: barcodeCaptureSession)
		previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
		previewLayer?.bounds = previewView.bounds
		previewLayer?.position = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY)

		_barcodeHighlight = BarcodeHighlightView(frame: self.view.bounds)
		_barcodeHighlight?.backgroundColor = UIColor.clear

		previewView.layer.addSublayer(previewLayer)
		previewView.addSubview(_barcodeHighlight!)
	}

	func initializeEngine() {
		engine = AVAudioEngine()
		reverb = AVAudioUnitReverb()
		delay = AVAudioUnitDelay()

		let input = engine.inputNode!
		let format = input.inputFormat(forBus: 0)

		engine.attach(reverb)
		engine.attach(delay)

		engine.connect(input, to: delay, format: format)
		engine.connect(delay, to: reverb, format: format)
		engine.connect(reverb, to: engine.mainMixerNode, format: format)

		applyParameterCode(code: Int(arc4random()))

		assert(engine.inputNode != nil)
	}

	func applyParameterCode(code: Int) {
		if (code != currentParameterCode) {
			// largeHall2 is the last of AVAudioUnitReverbPresets
			let newPreset: AVAudioUnitReverbPreset! = AVAudioUnitReverbPreset(rawValue: code % (AVAudioUnitReverbPreset.largeHall2.rawValue + 1))
			reverb.loadFactoryPreset(newPreset)
			reverb.wetDryMix = Float(code % 41011) / 410.11

			delay.wetDryMix = Float(code % 3203) / 32.03
			delay.feedback = Float(code % 4993) / 49.93
			delay.delayTime = TimeInterval(0.01 + pow(Double(code % 31583) / 10000.0, 2.0))
			//The valid range of lowPassCutoff values is 10 Hz through (sampleRate/2).
			delay.lowPassCutoff = 10.0 + pow(3.17+Float(code % 13997)/100.0,2.0)

			currentParameterCode = code
		}
	}

	func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
		for data in metadataObjects {
			if let transformed = previewLayer?.transformedMetadataObject(for: data  as? AVMetadataObject) {
					if let barcodeMetadata = transformed as? AVMetadataMachineReadableCodeObject {
						print("Code: \(barcodeMetadata.stringValue) of type \(transformed.type) at \(barcodeMetadata.corners)")

						if let barcodeNumberValue = NumberFormatter().number(from: barcodeMetadata.stringValue) {
							_barcodeHighlight?.setHighlightStatus(color: UIColor.green, corners: barcodeMetadata.corners)
							applyParameterCode(code: Int(barcodeNumberValue))
						}
						else {
							_barcodeHighlight?.setHighlightStatus(color: UIColor.red, corners: barcodeMetadata.corners)
						}
					}
					else {
						let generatedCorners = [["X": transformed.bounds.minX, "Y":transformed.bounds.minY],
							["X": transformed.bounds.minX, "Y":transformed.bounds.maxY],
							["X": transformed.bounds.maxX, "Y":transformed.bounds.maxY],
							["X": transformed.bounds.maxX, "Y":transformed.bounds.minY]]
						_barcodeHighlight?.setHighlightStatus(color: UIColor.brown, corners: generatedCorners)
					}
			}
		}
	}
}

func cornerArrayToCGPoint (corners :  [Any], index: Int) -> CGPoint {
	let dict = corners [index] as! NSDictionary

	let x = CGFloat(dict["X"] as! NSNumber)
	let y = CGFloat(dict["Y"] as! NSNumber)

	return CGPoint(x:x,y:y)
}
