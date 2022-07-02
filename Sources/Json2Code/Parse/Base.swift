//
//  Base.swift
//  Json2Code
//
//  Created by Sailer Guo on 2022/4/3.
//

import Foundation

// typeGraph 是一个字典，key 是typeId， value 是vertex
typealias HTTPClientInfo = (apis: [APIInterface], typeGraph: [String: Vertex])

// 如何构建类型的图
class Vertex {
    //    var type: TypeEnum
    //    var edges: [Edge]?
    //
    //    init(type: TypeEnum, edges: [Edge]?) {
    //        self.type = type
    //        self.edges = edges
    //    }
}

struct Edge: Hashable {
    
    var typeId: String
    var propertyName: String
    var isRequired: Bool
    var description: String
    var example: AnyHashable
}

enum Method: String {
    case get = "get"
    case post = "post"
    case delete = "delete"
    case put = "put"
    case head = "head"
    case options = "options"
    case patch = "patch"
}


struct ParameterType {
    
    // 参数在链接里，还是一个object
    enum InPath: String {
        case path
        case body
        case query
        case formData
    }
    
    var name: String
    //    var type: TypeEnum
    var requried: Bool
    
    var desc: String
    var inPath: InPath
}

/**
 生成特定格式的json 文件，如swagger 和postman
 */
struct APIInterface {
    
    var url: String     // 请求参数
    var apiInfo: JSON   // api 信息
    var method: String
    
    // 方法名
    var name: String {
        // 链接中需要传参
        //        var url =
        let url = self.url.replacingCharacters(in: url.startIndex..<url.index(url.startIndex, offsetBy: 1), with: "")
        let pathSlice = url.components(separatedBy: "/")
        
        return pathSlice.reduce("") { partialResult, next in
            return partialResult + (next.contains("{") ? "" : next.capitalized)
        }
    }
    
    var requestUrl: String {
        let paramArr = (self.apiInfo.dictionary?["parameters"]?.array ?? []).filter{ $0.dictionary!["in"] == "path" }.map{ "\\(\($0["name"].string!))" }
        if paramArr.count == 0 {
            return self.url
        }
        
        var pathItems = self.url.components(separatedBy: "/")
        pathItems.removeFirst()
        var resultUrl = pathItems.filter { !$0.contains("{") }
        resultUrl.append(contentsOf: paramArr)
        let url = "/" + resultUrl.joined(separator: "/")
        
        return url
        
//        return paramArr.filter{ $0.dictionary!["in"] != "path" }.map{ $0["name"].string! }.joined(separator: ",")
        
//        let url = self.url.replacingCharacters(in: url.startIndex..<url.index(url.startIndex, offsetBy: 1), with: "")
//        let pathSlice = url.components(separatedBy: "/")
//
//        return pathSlice.reduce("") { partialResult, next in
//            if next.contains("{") {
//                let next0 = next.replacingOccurrences(of: "{", with: "(")
//                let next1 = next0.replacingOccurrences(of: "}", with: ")")
//                return partialResult + "\\\(next1)"
//            }
//            return partialResult + next
//        }
    }
    
    // 参数
    var params_name: [String] {
        let paramArr = self.apiInfo.dictionary?["parameters"]?.array ?? []
        
        if paramArr.count == 0 {
            return []
        }
        
        return paramArr.map { json in
            let dict = json.dictionary!
            let name = dict["name"]?.string ?? ""
            
            var realType: String = ""
            
            let type = dict["type"]?.string
            
            if let type = type {
                let format = dict["format"]?.string
                realType = type
                
                if let format = format {
                    realType = "\(type)_\(format)"
                }
                
            } else {

                let schema = dict["schema"]?.dictionary!
                
                realType = schema!["originalRef"]?.string ?? ""
                
                if realType.count == 0  {
                    let items = schema?["items"]?.dictionary

                    let pType = schema?["type"]?.string

                    // 是数组
                    let elementType = items!["type"]?.string ?? items!["originalRef"]?.string ?? ""

                    realType = "\(pType!)|\(elementType)"
                }
            }
            
//            let required = (dict["required"]?.bool ?? true) ? "" : "?"
            
            return "\(name):\(realType)"
        }
    }
    
    var param_body: String {
        let paramArr = self.apiInfo.dictionary?["parameters"]?.array ?? []
        return paramArr.filter{ $0.dictionary!["in"] != "path" }.map{ $0["name"].string! }.joined(separator: ",")
    }
    
    // 返回类型
    var `return`: String {
        let res_200 = self.apiInfo.dictionary?["responses"]?.dictionary?["200"]!.dictionary
        let schema = res_200!["schema"]?.dictionary!
        let type = schema!["originalRef"]?.string ?? ""
        
        if type == "Result" {
            return "Result_"
        } else if type == "APIResult" {
            return type
        } else {
            // (?<=().+(?=))
//            let patten = "(?<=«)(.+?)(?=»)"
            let patten = "(?<=«).+(?=»)"
            let res = type.regex(patten: patten).first!
            if res.contains("«") {
               
                if res.hasPrefix("List") {
                    
                    let inners = res.regex(patten: patten).first!
                    return "array|\(inners)"
//                    return type.typeMapper(lan: .swift)
                } else {
                    let t0 = res.replacingOccurrences(of: "«", with: "<")
                    let t1 = t0.replacingOccurrences(of: "»", with: ">")
                    return t1
                }
                
            } else {
                return res
            }
        }
    }
    
    // 描述
    var desc: String {
        return self.apiInfo.dictionary?["summary"]?.string ?? ""
    }
    
    // 所属模块
    var module: String {
        return self.apiInfo.dictionary?["tags"]?.array?.first?.string ?? ""
    }
    
    init(json: (String, JSON), url: String) {
        self.url = url
        self.apiInfo = json.1
        self.method = json.0
    }
    
    func generateSingleAPI(for lan: Language) -> [String: Any] {
        var apiInfo:[String: Any] = [:]
        
        let params = params_name.map { value in
            let arr = value.components(separatedBy: ":")
            let platformType = arr.last?.typeMapper(lan: lan)
            return "\(arr.first!):\(platformType!)"
        }.joined(separator: ", ")
        
        apiInfo["func_name"] = name
        apiInfo["param_name"] = params
        apiInfo["returnType"] = `return`.typeMapper(lan: lan)
        apiInfo["method"] = method.uppercased()
        apiInfo["requestUrl"] = requestUrl
        apiInfo["param_body"] = param_body
        
        return apiInfo
    }
}

struct UserDomain {
    var domainName: String
    var props:[Property] = []
    
    mutating func addNewProp(p: Property) {
        if self.props.contains(p) {
            return
        }
        props.append(p)
    }
    
    func domainInfo(lan: Language) -> [String: Any] {
        
        var generateProps:[[String: String]] = []
        var generics:[String] = []
        
        let genericsValues = ["T", "U", "V"]
        var genericsCount = 0
        
        let sortSlice = props.sortSlice(by: \.name)
        for prop in sortSlice {
            
            var correctProps:[String: String] = [:]
            
            correctProps["name"] = prop.key
            
            let type = prop.value.first!.formatType().typeMapper(lan: lan)
            
            let propArr = prop.value
            if propArr.count > 1 {
                // 一个属性对应多个类型，是个泛型
                // 这里还需要考虑一个问题，那就是泛型属性还是泛型类型。特别是对于BaseResult 这个类型，它可能是泛型类型，也可能是泛型数组。此时如何做区分。
                
                let generic = genericsValues[genericsCount]
                correctProps[prop.key] = generic
                genericsCount += 1
                generics.append(generic)
                
                //                var typeEqual = true
                //
                //                for propV in propArr {
                //                    let curr = propV.formatType().typeMapper(lan: lan)
                //                    if curr != type {
                //                        typeEqual = false
                //                        break
                //                    }
                //                }
                
                if type.isArray() {
                    let e = type.replacingCharacters(in: type.index(type.startIndex, offsetBy: 1)..<type.index(before: type.endIndex), with: generic)
                    correctProps["type"] = e
                    
                } else {
                    correctProps["type"] = generic
                }
                
            } else {
                correctProps["type"] = type
            }
            
            correctProps["param_desc"] = prop.value.first!.desc
            
            generateProps.append(correctProps)
        }
        
        var genericsDeclare = generics.count > 0 ? generics.map { g in
            "\(g): Decodable"
        }.joined(separator: ",") : ""
        
        if genericsDeclare.count > 0 {
            genericsDeclare = "<\(genericsDeclare)>"
        }
        
        return [
            "title": domainName,
            "properties": generateProps,
            "generics": genericsDeclare
        ]
    }
}

struct Property: Equatable {
    var name: String
    var desc: String {
        get {
            return info.dictionary?["description"]?.string ?? ""
        }
    }
    
    var example = ""
    
    var info: JSON
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.formatType() == rhs.formatType() && lhs.name == rhs.name
    }
    
    func domainName() -> String {
        if name.contains("«") {
            return name.components(separatedBy: "«").first!
        }
        return name
    }
    
    func formatType() -> String {
        let dict = info.dictionary!
        let type = dict["type"]?.string ?? dict["originalRef"]?.string ?? ""
        
        switch type {
            
        case "integer":
            let format = dict["format"]?.string ?? ""
            return "\(type)_\(format)"
            
        case "string", "boolean", "object":
            return "\(type)"
            
        case "number":
            let format = dict["format"]?.string ?? "float"
            return "\(type)_\(format)"
            
        case "array":
            let items = dict["items"]?.dictionary!
            let item = items?["originalRef"]?.string ?? (items?["type"]?.string ?? "Any" + (items?["format"]?.string ?? "") )
            return "\(type)|\(item)"
            
        default:
            // 自定义类型
            if type.contains("«") {
                
                let temp0 = type.replacingOccurrences(of: "«", with: "<")
                let temp1 = temp0.replacingOccurrences(of: "»", with: ">")
                return temp1
                
            } else {
                return "\(type)"
            }
        }
    }
}



/**
 解析成特定平台的文件格式，如swift 或者java
 */
protocol ParserInterface {
    // 返回接口信息，接口关联的input model 和output model 的信息
    func getApiInfo(endPointTemplate: URL, modelTemplate: URL, api: APIInterface) throws -> (String?, [String: String], [String: String])
}


