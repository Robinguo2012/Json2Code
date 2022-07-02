//
//  CreateFolder.swift
//  Json2Code
//
//  Created by Sailer Guo on 2022/4/6.
//

import Foundation

extension JsonToCodeUtils {
    
    func createFolder() async throws -> [URL] {
        
        return await withUnsafeContinuation { continuation in
            
            let parentPath = apiFilePath
            
            if fm.fileExists(atPath: parentPath.absoluteString) {
                try? fm.removeItem(at: parentPath)
            }
            
            try? fm.createDirectory(at: parentPath, withIntermediateDirectories: true, attributes: nil)

            var pathArr:[URL] = []
            pathArr.append(parentPath)
            
            let dict = [
                "EndPoint":[:],
                "UserDomain": [
                    "Input":[:],
                    "Output":[:]
                ]
            ] as [String: Any]
            
            var tempDict: [String: Dictionary<String,Any>] = [:]
            
            Language.allCases.forEach { value in
                tempDict[value.rawValue] = dict
            }
            
            _createFolder(tempPath: parentPath, pathInfo: tempDict)
            continuation.resume(with: .success(pathArr))
        }
    }
    
    private func _createFolder(tempPath: URL, pathInfo: [String: Dictionary<String,Any>]) {
        
        if pathInfo.count == 0 {
            return
        }
        
        for path in pathInfo {
            let url = tempPath.appendingPathComponent(path.key)
            try? fm.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            _createFolder(tempPath: url, pathInfo: path.value as! Dictionary<String, Dictionary<String,Any>>)
        }
        
    }
}


