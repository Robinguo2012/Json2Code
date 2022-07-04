//
//  Swagger.swift
//  Json2Code
//
//  Created by Sailer Guo on 2022/4/4.
//

import Foundation

class Swagger {
    var params: [ParameterType] {
        return []
    }
    
    let apiJson: (String, JSON)
    let innerUrl: String
    
    required init(json: (String, JSON), url: String) {
        self.apiJson = json
        self.innerUrl = url
    }
    
    var paths: [String] {
        var arr = self.innerUrl.components(separatedBy: "/")
        arr.removeAll { str in
            str.count == 0 || str.contains("{")
        }
        return arr
    }
    
    var name: String {
        return self.paths.map{ $0.capitalized }.joined(separator: "") as String
    }
    
    var url: String {
        if self.innerUrl.contains("{") {
            
            var paths = self.innerUrl.components(separatedBy: "/")
            paths.removeFirst()
            
            return paths.map { path in
                var newPath = path
                if path.contains("{") {
                    
                    newPath = newPath.replacingOccurrences(of: "{", with: "")
                    newPath = newPath.replacingOccurrences(of: "}", with: "")
                    
                    newPath = "\\(\(newPath))"
                }
                return newPath
            }.joined(separator: "/")
            
        } else {
            return self.innerUrl
        }
    }
    
//    var method: Method {
//        return Method.init(rawValue: apiJson.0.lowercased()) ?? Method.get
//    }
    
//    var `return`: TypeEnum {
//        let responseType = apiJson.1.responses.200.schema.originalRef.string!
//        if responseType.hasPrefix("BaseResult") {
//            var types = responseType.components(separatedBy: "«").map { inStr -> String in
//                return inStr.replacingOccurrences(of: "»", with:"")
//            }
//            types.remove(at: 0)
//
//            if types.count == 1 {
//                return types.first!.toType
//            }
//
//            if types.first == "List" {
//                return .array(types.last!.toType)
//            }
//
//            return "\(types.first!)<\(types.last!)>".toType
//        }
//        return responseType.toType
//    }
    
    var desc: String {
        return apiJson.1.summary.string ?? ""
    }
    
    var module: String {
        let tags = apiJson.1.tags.array!
        return tags.first?.string ?? ""
    }
    
//    var params: [ParameterType] {
//        let parameters = apiJson.1.parameters.array ?? []
//        return parameters.map { ParameterType.swaggerFormat(json: $0) }
//    }
}

extension APIInterface {
    
//    func getApiInfo(language: Language) -> [String: Any] {
//
//        var paramDesc: [[String: String]] = []
//        for param in self.params {
//            var params:[String: String] = [:]
//            params["name"] = param.name
//            params["type"] = param.type.mapToString(to: language)
//            paramDesc.append(params)
//        }
//
//        var returnDesc:[String: String] = [:]
//        returnDesc["type"] = self.return.mapToString(to: language)
//
//        let funcName = self.paths.map { $0.capitalized }.joined(separator: "")
//
//        let param_body = self.params.filter{ $0.inPath != .path }.map{ $0.name }.joined(separator: ",")
//
//        let param_name = self.params.map { $0.name + ":" + $0.type.mapToString(to: language)}.joined(separator: ",")
//        var returnType = self.return.mapToString(to: language)
//        if returnType == "Void" {
//            returnType = "Int"
//        }
//
//        if returnType == "Result" {
//            returnType = "Result_"
//        }
//
//        return [
//            "paramsDesc": paramDesc,
//            "returnDesc": returnDesc,
//            "desc": self.desc,
//            "param_name":param_name,
//            "func_name": funcName,
//            "requestUrl":self.url,
//            "returnType": returnType,
//            "method": self.method.rawValue.uppercased(),
//            "param_body":param_body
//        ]
//    }
}

extension ParameterType {
    
//    static func swaggerFormat(json: JSON) -> Self {
//
//        let name = json.name.string!
//        let desc = json.dictionary?["description"]?.string ?? ""
//        var type: String? = json.type.string
//        let required = json.required.bool ?? true
//        let inPath: ParameterType.InPath = InPath(rawValue: json.in.string!)!
//
//        var typeEnum: TypeEnum
//
//        switch inPath {
//        case .path, .query:
//            typeEnum = type!.toType
//            break
//        case .body:
//
//            let schema = json.schema
//
//            if schema.type.string == "array" {
//                let items = schema.items
//                let subType = items.type.string ?? items.originalRef.string!
//                typeEnum = .array(subType.toType)
//            } else if (schema.type.string ?? "").toType.isBaseType {
//                typeEnum = schema.type.string!.toType
//            } else {
//                type = schema.originalRef.string!
//                typeEnum = type!.toType
//            }
//            break
//
//        case .formData:
//            type = "File"
//            typeEnum = type!.toType
//            break
//        }
//
//        return ParameterType(name: name, type: typeEnum, requried: required, desc: desc, inPath: inPath)
//    }
}
