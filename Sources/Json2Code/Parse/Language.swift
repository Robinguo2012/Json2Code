//
//  Language.swift
//  Json2Code
//
//  Created by Sailer Guo on 2022/4/12.
//

import Foundation
import Mustache

enum Language: String, CaseIterable {
    
    case swift
    case java
    
    
    func generatePlatformAPI(apis:[APIInterface], vertex: [String: UserDomain]) throws {
        
        do {
            try generateAPI(apis: apis)
            try generateModel(domainList: vertex)
        } catch {
            print("生成\(self.rawValue)平台接口报错")
        }
    }
    
    func generateAPI(apis: [APIInterface]) throws {
        
        let mApis = apis.filterDuplicates(\.name)
        
        let apiTemplate = try! Template(URL: self.apiTempFilePath)
        let endPoints = try! Template(URL: self.endPointTempFilePath)
        
        try mApis.sortSlice(by: \.module).map { (module, moduleApis) -> ( String, [String]) in
            let moduleApis = try moduleApis.map { api -> String in
                let singleApi = api.generateSingleAPI(for: self)
                return try apiTemplate.render(singleApi)
            }
            return (module, moduleApis)
        }.map({ value -> (String, String) in
            let endPointValue:[String: Any] = [
                "description":value.0,
                "values":value.1
            ]
            let templateRes = try endPoints.render(endPointValue)
            return (value.0, templateRes)
        }).forEach({ value in
            let dstFilePath = self.dstEndPointPath.appendingPathComponent("\(value.0).\(self.rawValue)")
            try! value.1.write(to: dstFilePath, atomically: true, encoding: .utf8)
        })
    }
    
    // 生成模型数据
    func generateModel(domainList: [String: UserDomain]) throws {
        
//        var inputModels:[String: ([[String: Any]],[String])] = [:]
//        var outputModels:[String: ([[String: Any]],[String])] = [:]
//        var generateStatus: [String: Bool] = [:]

        // 先不区分input 和output 类型，统一为一种类型降低复杂度
        let modelTemplate = try! Template(URL: modelTempFilePath)

        // 遍历每个接口，生成其中的model>> 这种方式有问题
        try domainList.values.map { domain -> (title: String, renderTemplate: String) in
             
             let renderRes = try modelTemplate.render(domain.domainInfo(lan: self))

             return (title: domain.domainName, renderTemplate: renderRes)
             
         }.forEach({ value in
             let dstFilePath = self.dstOutputPath.appendingPathComponent("\(value.0).\(self.rawValue)")
             try! value.renderTemplate.write(to: dstFilePath, atomically: true, encoding: .utf8)
         })
    }
    
    func generateSwiftFile(modelMap: [String: ([[String: Any]],[String])], dstFilePath: URL) throws {
        // 生成输入的模板字符串
        let modelTemplate = try! Template(URL: modelTempFilePath)
        
        try modelMap.map { (key, value) -> (title: String, renderTemplate: String) in
            
            var generics: [String] = []
            for propertyInfo in value.1 {
                let genericStr = "\(propertyInfo):Decodable"
                generics.append(genericStr)
            }
        
            var genericStr = ""
            if generics.count > 0 {
                genericStr = "<" + generics.joined(separator: ",") + ">"
            }
            
            // Result_已经被占用了，转化一下名称
            var key_ = key
            if key == "Result" {
                key_ = "Result_"
            }
            
            let modelInfo:[String: Any] = [
                "title":key_,
                "properties": value.0,
                "generics": value.1,
                "genericDeclare": genericStr
            ]
            
            let renderRes = try modelTemplate.render(modelInfo)
            return (title: key, renderTemplate: renderRes)
            
        }.forEach({ value in
            let dstFilePath = dstFilePath.appendingPathComponent("\(value.0).\(self.rawValue)")
            try! value.renderTemplate.write(to: dstFilePath, atomically: true, encoding: .utf8)
        })
    }
}

//
extension Language {
    
    func formatExample(lan: Language, type: String, example: JSON) -> String {
        
        if lan == .swift {
            switch type {
            case "integer":
                return "\(example.int ?? 0)"
            case "string":
                return "\"\(type)\""
            case "boolean":
                return "\((example.bool ?? false) ? "true": "false")"
                
            case "number":
                return "\(example.double ?? 0.0)"
                
            case "object":
                return ""
                
            case "array":
                let items = dict["items"]?.dictionary!
                let item = items?["originalRef"]?.string ?? (items?["type"]?.string ?? "Any" + (items?["format"]?.string ?? "") )
                return "\(type)|\(item)"
                
            default:
                
            }
        }
        
    }
}

extension Language {
    
    var apiTempFilePath: URL {
        let tempfilePath = toCodeUtils.parent.appendingPathComponent("Template").appendingPathComponent("\(self.rawValue)")
        
        switch self {
        case .swift:
            return tempfilePath.appendingPathComponent("Api.mustache")
        case .java:
            return tempfilePath.appendingPathComponent("Api.mustache")
        }
    }
    
    var endPointTempFilePath: URL {
        let tempfilePath = toCodeUtils.parent.appendingPathComponent("Template").appendingPathComponent("\(self.rawValue)")

        switch self {
        case .swift:
            return tempfilePath.appendingPathComponent("Endpoint.mustache")
        case .java:
            return tempfilePath.appendingPathComponent("Endpoint.mustache")
        }
    }
    
    var modelTempFilePath: URL {
        let tempfilePath = toCodeUtils.parent.appendingPathComponent("Template").appendingPathComponent("\(self.rawValue)")

        switch self {
        case .swift:
            return tempfilePath.appendingPathComponent("Domain.mustache")
        case .java:
            return tempfilePath.appendingPathComponent("Domain.mustache")
        }
    }
}

extension Language {
    var dstEndPointPath: URL {
        let tempfilePath = toCodeUtils.apiFilePath.appendingPathComponent("\(self.rawValue)")
        return tempfilePath.appendingPathComponent("EndPoint")
    }
    
    var dstInputPath: URL {
        let tempfilePath = toCodeUtils.apiFilePath.appendingPathComponent("\(self.rawValue)")
        return tempfilePath.appendingPathComponent("UserDomain").appendingPathComponent("Input")
    }
    
    var dstOutputPath: URL {
        let tempfilePath = toCodeUtils.apiFilePath.appendingPathComponent("\(self.rawValue)")
        return tempfilePath.appendingPathComponent("UserDomain").appendingPathComponent("Output")
    }
    
}


