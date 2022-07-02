//
//  Request.swift
//  Json2Code
//
//  Created by Sailer Guo on 2022/3/28.
//

import Foundation

extension JsonToCodeUtils {
    
    func requestData(from urlString: String) async throws -> JSON {
        
        return await withUnsafeContinuation{ continuation in
            let url = fm.urls(for: .desktopDirectory, in: .userDomainMask).first?.appendingPathComponent("api.json")
            let data = try? Data(contentsOf: url!)
            let api = try! JSON(data: data ?? Data())
            continuation.resume(with: .success(api))
        }
        
//        let url = URL(string: urlString)!
//        let request = URLRequest(url: url)
//
//        return await withUnsafeContinuation { continuation in
//           let task = URLSession.shared.dataTask(with: request) { data, response, error in
//
//                if let error = error {
//                    continuation.resume(with: .failure(error as! Never))
//                } else {
//                    let swaggerAPI = try! JSON(data: data ?? Data())
//                    continuation.resume(with: .success(swaggerAPI))
//                }
//            }
//
//            task.resume()
//        }
        
    }
}
