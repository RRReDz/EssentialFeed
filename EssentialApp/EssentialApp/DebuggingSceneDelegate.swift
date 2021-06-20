//
//  DebuggingSceneDelegate.swift
//  EssentialApp
//
//  Created by Riccardo Rossi - Home on 20/06/21.
//

#if DEBUG
import UIKit
import EssentialFeed

class DebuggingSceneDelegate: SceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: storeURL)
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeRemoteClient() -> HTTPClient {
        if let connectivity = UserDefaults.standard.string(forKey: "connectivity") {
            return DebuggingHTTPClient(connectivity: connectivity)
        }
        return super.makeRemoteClient()
    }
    
    private class DebuggingHTTPClient: HTTPClient {
        private let connectivity: String
        
        init(connectivity: String) {
            self.connectivity = connectivity
        }
        
        private class Task: HTTPClientTask {
            func cancel() {}
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            switch connectivity {
            case "online":
                completion(.success(makeSuccessfulResponse(for: url)))
            case "offline":
                completion(.failure(NSError(domain: "offline", code: 0)))
            default: break
            }
           
            return Task()
        }
        
        private func makeSuccessfulResponse(for url: URL) -> (HTTPURLResponse, Data) {
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = makeData(for: url)
            return (response, data)
        }
        
        private func makeData(for url: URL) -> Data {
            switch url.absoluteString {
            case "http://image.com":
                return makeImageData()
            default:
                return makeFeedData()
            }
        }
        
        private func makeImageData() -> Data {
            let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
            UIGraphicsBeginImageContext(rect.size)
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(UIColor.red.cgColor)
            context.fill(rect)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return img!.pngData()!
        }
        
        private func makeFeedData() -> Data {
            return try! JSONSerialization.data(
                withJSONObject: ["items": [
                    ["id": UUID().uuidString, "image": "http://image.com"],
                    ["id": UUID().uuidString, "image": "http://image.com"]
                ]])
        }
    }
}
#endif

