//
//  ViewController.swift
//  PonDeReplayKit
//
//  Created by natalie on 6/15/15.
//  Copyright © 2015 Natalie Podrazik. All rights reserved.
//

import UIKit
import WebKit
import ReplayKit

class ViewController: UIViewController, RPScreenRecorderDelegate, RPPreviewViewControllerDelegate {

    var viewTimer: NSTimer?
    let viewLimit = 10
    var imageView = UIImageView()
    let bubblesContainer = UIView()
    var animator : UIDynamicAnimator!
    var recordButton = UIButton()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        
        imageView.frame = self.view.frame
        imageView.image = UIImage(named: "ponde")
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.view.addSubview(imageView)
        
        bubblesContainer.frame = self.view.frame
        bubblesContainer.userInteractionEnabled = false
        self.view.addSubview(bubblesContainer)
        animator = UIDynamicAnimator(referenceView: bubblesContainer)
        
        recordButton.frame = CGRect(x: self.view.frame.size.width - 90, y: 5, width: 85, height: 40)
        recordButton.setTitle("⚪️ Start ", forState: UIControlState.Normal)
        recordButton.setTitle("🔴 Stop ", forState: UIControlState.Selected)
        recordButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        recordButton.layer.cornerRadius = 5.0
        recordButton.addTarget(self, action: Selector("toggleRecording"), forControlEvents: UIControlEvents.TouchUpInside)
        // TODO: move recordButton to a separate uiwindow 
        // so it's not captured in screen recording :/
        self.view.addSubview(recordButton)
        
        viewTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("drawRandomView"), userInfo: nil, repeats: true)
    }

    func drawRandomView() {

        for subview in bubblesContainer.subviews {
            subview.removeFromSuperview()
        }
    
        animator.removeAllBehaviors()
        let bubbleCount = 20
        for (var i = 0; i < bubbleCount; i++) {
            let newView = UIView(frame: self.getRandomFrame())
            newView.backgroundColor = self.getRandomColor()
            newView.layer.cornerRadius = newView.frame.size.width / 2.0
            bubblesContainer.addSubview(newView)
        }
        
        let boundaryCollision = UICollisionBehavior(items: Array(bubblesContainer.subviews[0...(bubbleCount / 2)]))
        boundaryCollision.translatesReferenceBoundsIntoBoundary = true
        
        let elasticityBehavior = UIDynamicItemBehavior(items: bubblesContainer.subviews)
        elasticityBehavior.elasticity = 1.0
        elasticityBehavior.allowsRotation = false
        
        let gravityBehavior = UIGravityBehavior(items: bubblesContainer.subviews)
        
        self.animator.addBehavior(boundaryCollision)
        self.animator.addBehavior(elasticityBehavior)
        self.animator.addBehavior(gravityBehavior)
    }
    
    func getRandomFrame() -> CGRect {
        
        let randomX = CGFloat(arc4random_uniform(UInt32(UIScreen.mainScreen().bounds.size.width)))
        var randomY = CGFloat(arc4random_uniform(6))
        let randomEdgeSize = CGFloat(arc4random_uniform(3) + 1)

        randomY = (randomY == 0) ? 0 : (UIScreen.mainScreen().bounds.size.height) / randomY

        return CGRect(x:randomX, y:randomY, width: 15 * randomEdgeSize, height: 15 * randomEdgeSize)
    }
    
    func getRandomColor() -> UIColor {
        let colors:[UIColor] = [
                        UIColor.purpleColor(),
                        UIColor.blueColor(),
                        UIColor.cyanColor(),
                        UIColor.yellowColor(),
                        UIColor.orangeColor(),
                        UIColor.redColor(),
                        UIColor.magentaColor(),
                        UIColor.whiteColor()
        ]
        
        return colors[Int(arc4random_uniform(UInt32(colors.count)))]
    }
    
    func toggleRecording() {
        if (recordButton.selected) {
            self.stopRecording()
        } else {
            self.startRecording()
        }
        
        recordButton.selected = !recordButton.selected
    }
    
    func startRecording() {
        let sharedRecorder = RPScreenRecorder.sharedRecorder()
        sharedRecorder.delegate = self

        sharedRecorder.startRecordingWithMicrophoneEnabled(true) { error in
            if let error = error {
                print ("Recording couldn't begin due to error: \(error.localizedDescription)")
                return
            }
            
            print ("Recording has started; .isRecording = \(sharedRecorder.recording)")
        }
    }
    
    func stopRecording() {
        let sharedRecorder = RPScreenRecorder.sharedRecorder()

        sharedRecorder.stopRecordingWithHandler { (previewViewController: RPPreviewViewController?, error: NSError?) in
            if let error = error {
                print("There was an error stopping the recording: \(error.localizedDescription)")
                return
            }
            
            if let previewViewController = previewViewController {
                // Set delegate to handle view controller dismissal!
                previewViewController.previewControllerDelegate = self
                
                // DON'T FORGET TO PRESENT IT
                self.presentViewController(previewViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: <RPScreenRecorderDelegate>
    func screenRecorder(screenRecorder: RPScreenRecorder, didStopRecordingWithError error: NSError, previewViewController: RPPreviewViewController?) {
        print("Screen recording stopped because of an error: \(error.localizedDescription)")
    }
    
    func screenRecorderDidChangeAvailability(screenRecorder: RPScreenRecorder) {
        print("Screen recording availability changed to: \(screenRecorder.available)")

    }
    
    // MARK: <RPPreviewViewControllerDelegate>
    func previewControllerDidFinish(previewController: RPPreviewViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

