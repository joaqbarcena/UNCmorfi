//
//  URLSessionBackground.swift
//  UNCmorfi
//
//  Created by Joaquin Barcena on 8/27/19.
//  Copyright © 2019 George Alegre. All rights reserved.
//

import Foundation

class URLSessionBackground : NSObject, URLSessionDownloadDelegate {
    private static let uid = "uncmorfi.background.id"
    static var finishHandlers:[String:()->Void] = [:]
    //static var finishHandler:(()->Void)?
    var urlSession:URLSession!
    let suffixId:String
    let closureHandler:(Data?,URLResponse?,Error?) -> Void
    
    init(withId:String, completionHandler: @escaping (Data?,URLResponse?,Error?) -> Void) {
        //super.init()
        closureHandler = completionHandler
        suffixId = withId
        super.init()
        urlSession = URLSession(
            configuration: URLSessionConfiguration.background(withIdentifier: URLSessionBackground.uid + suffixId),
            delegate: self, delegateQueue: nil)
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        let id = URLSessionBackground.uid + suffixId
        DispatchQueue.main.async {
//            URLSessionBackground.finishHandler?()
//            URLSessionBackground.finishHandler = nil
        if let finisher = URLSessionBackground.finishHandlers[id] {
                finisher()
                URLSessionBackground.finishHandlers.removeValue(forKey: id)

            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            closureHandler(nil, task.response, error)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        closureHandler(try? Data(contentsOf: location), downloadTask.response, nil)
    }
    
    
}
