//
//  RoomVOWebViewViewController.swift
//  Refloor
//
//  Created by Apple on 06/02/25.
//  Copyright © 2025 oneteamus. All rights reserved.
//

import UIKit
import WebKit

class RoomVOWebViewViewController: UIViewController {

    static func initialization() -> RoomVOWebViewViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "RoomVOWebViewViewController") as? RoomVOWebViewViewController
    }
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
         super.viewDidLoad()
         setNavigationBarbackAndlogo2(with: "RoomVO")

        let configuration = WKWebViewConfiguration()
           configuration.allowsInlineMediaPlayback = true
           configuration.mediaTypesRequiringUserActionForPlayback = .all
           
           // Updated JavaScript to show video thumbnail/first frame
           let script = """
               function setupVideo() {
                   var videos = document.getElementsByTagName('video');
                   for(var i = 0; i < videos.length; i++) {
                       // Prevent autoplay but load first frame
                       videos[i].autoplay = false;
                       videos[i].playsInline = true;
                       videos[i].webkitPlaysInline = true;
                       videos[i].controls = true;
                       videos[i].preload = 'auto';  // Preload video data
                       
                       // Load first frame without playing
                       videos[i].currentTime = 0.01;
                       videos[i].pause();
                       
                       // Prevent fullscreen
                       videos[i].webkitSupportsFullscreen = false;
                       videos[i].webkitEnterFullscreen = function() {};
                       videos[i].webkitExitFullscreen = function() {};
                       
                       // Set attributes
                       videos[i].setAttribute('playsinline', '');
                       videos[i].setAttribute('webkit-playsinline', '');
                       videos[i].removeAttribute('autoplay');
                       
                       // Force poster/thumbnail to show if available
                       if (!videos[i].hasAttribute('poster')) {
                           // If no poster is set, seek to first frame
                           videos[i].addEventListener('loadeddata', function() {
                               this.currentTime = 0.01;
                               this.pause();
                           });
                       }
                   }
               }
               
               // Run initially and observe for new videos
               setupVideo();
               new MutationObserver(function() {
                   setupVideo();
               }).observe(document.body, {
                   childList: true,
                   subtree: true
               });
           """
           
           let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
           webView.configuration.userContentController.addUserScript(userScript)
        
         // Set navigation and UI delegates
         webView.navigationDelegate = self
         webView.uiDelegate = self
         
         loadWebPage("https://www.roomvo.com/my/refloor/")
     }
     
     override func viewWillAppear(_ animated: Bool) {
         checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
     }
    
     
     func loadWebPage(_ urlString: String) {
         guard let url = URL(string: urlString) else {
             print("Invalid URL.")
             return
         }
         
         let request = URLRequest(url: url)
         print("Loading URL: \(url)")
         self.showActivityIndicator(show: true)
         webView.load(request)
     }

     fileprivate func showActivityIndicator(show: Bool) {
         if show {
             activityIndicator.isHidden = false
             activityIndicator.startAnimating()
         } else {
             activityIndicator.stopAnimating()
             activityIndicator.isHidden = true
         }
     }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
           return .landscape
       }
       
       override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
           return .landscapeRight
       }
       
       override var shouldAutorotate: Bool {
           return true
       }
    
 }

 // MARK: - WKNavigationDelegate
 extension RoomVOWebViewViewController: WKNavigationDelegate {
     
     func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
         self.showActivityIndicator(show: false)
         print("Web page loaded successfully.")
         webView.evaluateJavaScript("preventFullscreen();", completionHandler: nil)
     }
     
     func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
         self.showActivityIndicator(show: false)
         print("Error loading web page: \(error.localizedDescription)")
     }
 }

 // MARK: - WKUIDelegate (Handling New Tab Requests)
extension RoomVOWebViewViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else { return nil }
        
        if let newWebViewController = RoomVOWebViewViewController.initialization() {
            // Set presentation style
            newWebViewController.modalPresentationStyle = .fullScreen
            
            // Set transition style to avoid bottom slide
            newWebViewController.modalTransitionStyle = .crossDissolve
            
            // Set orientation before presenting
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            
            self.present(newWebViewController, animated: false) {
                newWebViewController.loadWebPage(url.absoluteString)
            }
        }
        
        return nil
    }
}

