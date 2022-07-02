//
//  Generate.swift
//  Json2Code
//
//  Created by Sailer Guo on 2022/3/30.
//

import Foundation
import Mustache

extension JsonToCodeUtils {
//    ([String: [String?]], [String: String], [String: String])
    func generateFile(parseInfo : ([String: [String?]], [String: String], [String: String]), language: Language) async throws  -> Bool {
        
        let tagMap = parseInfo.0
        
        return await withUnsafeContinuation { contination in
            
           let _ = tagMap.forEach { value in
                
//               let mustache_file_path = templatePath.appendingPathComponent("\(language.rawValue)/\(templateFiles.endPoint)")

               let mustache_file_path = URL(string: "")

               
               let template = try? Template(URL: mustache_file_path!)

                let apiInfo = value.value
                let renderRes = try? template?.render([
                    "values": apiInfo,
                    "description": value.key
                ])
                
//               let endPointSwift = apiFilePath.appendingPathComponent("\(language.rawValue)/EndPoint").appendingPathComponent("\(value.key).swift")
               let endPointSwift = URL(string: "")


               try? renderRes?.write(to: endPointSwift!, atomically: true, encoding: .utf8)
            }
            
            
            // 写入基类信息
            
//            let baseTemplateFile = templatePath.appendingPathComponent("\(language.rawValue)/BaseInterface.mustache")
//
//            let baseFilePath = apiFilePath.appendingPathComponent("\(language.rawValue)/UserDomain/BaseDomain.swift")
            
            let baseTemplateFile = URL(string: "")!
            
            let baseFilePath = URL(string: "")!
            
            
            let baseTemplate = try? Template(URL: baseTemplateFile)
            let baseTemplateStr = try? baseTemplate?.render()
            try? baseTemplateStr?.write(to: baseFilePath, atomically: true, encoding: .utf8)

            let requestModels = parseInfo.1
            requestModels.forEach { (key,value) in
//                let inputFilePath = apiFilePath.appendingPathComponent("\(language.rawValue)/UserDomain/Input/\(key).swift")

                let inputFilePath = URL(string: "")!

                
                try? value.write(to: inputFilePath, atomically: true, encoding: .utf8)
            }
            
            let responseModels = parseInfo.2
            responseModels.forEach { (key,value) in
//                let inputFilePath = apiFilePath.appendingPathComponent("\(language.rawValue)/UserDomain/Output/\(key).swift")
                let inputFilePath = URL(string: "")!

                try? value.write(to: inputFilePath, atomically: true, encoding: .utf8)
            }
            
            
            contination.resume(with: .success(true))
        }
    }
    

    
}
