//
//  JsonFormat.swift
//  Json2Code
//
//  Created by Sailer Guo on 2022/4/12.
//

import Foundation

// 构造类型的图结构，最后遍历这个图结构然后生成所有的自定义数据结构。
enum JsonFormat {
    
    case swagger(JSON?)
    case postman(JSON?)
    
    var formatName: String {
        switch self {
        case .swagger(_):
            return "swagger"
        case .postman(_):
            return "postman"
        }
    }
    
    var typeGraph: [String: UserDomain] {
        switch self {
            case .postman(let json):
                let dict = json!.definitions
                return buildUserDomainGraph(json: dict)
            case .swagger(let json):
                let dict = json!.definitions
                return buildUserDomainGraph(json: dict)
        }
    }
    
    var apiMap: [APIInterface] {
        switch self {
        case .swagger(let json):
            return buildApiMap(json!)
        case .postman(let json):
            return buildApiMap(json!)
        }
    }
}

extension JsonFormat {
    
    // definitions，遍历
    func buildUserDomainGraph(json: JSON) -> [String: UserDomain] {
        
        var targetMap:[String: UserDomain] = [:]
        
        let definitions = json.dictionary!
        
//        let exceptArr:[String] = [] , 记录的状态越少越好。想得太复杂了
        for domain in definitions.keys {
            
            let object = definitions[domain]?.dictionary
            let properties = object?["properties"]?.dictionary ?? [:]
            
            // 没有属性，可能是JSONObject
            if properties.count == 0 {
                continue
            }
            
            var firstLevelDomain = domain
            if domain.contains("«") {
                firstLevelDomain = domain.components(separatedBy: "«").first!
            }
            
            var userDomain = targetMap[firstLevelDomain]
            if userDomain == nil {
                userDomain = UserDomain(domainName: firstLevelDomain)
            }
            
            for key in properties.keys {
                let propertyInfo = properties[key]
                let property = Property(name: key, info: propertyInfo!)
                userDomain!.addNewProp(p: property)
            }
            
            targetMap[firstLevelDomain] = userDomain
        }
         
        return targetMap
    }

    /**
     BaseResult«BasePageListResult«CollectGoodsVo»»
     BasePageListResult«CollectGoodsVo»
     CollectGoodsVo
     String
     */
//    private func buildTree(type: String, targetMap: inout [String: Vertex], definitions: [String: JSON], hasRead:inout [String: Bool]) {
//
//        let typeId = type.toType.typeID
//
//        // 该类型已经被读取了
//        if hasRead[type] ?? false {
//            return
//        }
//
//        hasRead[type] = true
//
//        if type.toType.isBaseType {
//            // 基本类型
//            if targetMap[type.toType.typeID] == nil {
//                let baseVertex = Vertex(type: type.toType, edges: nil)
//                targetMap[type.toType.typeID] = baseVertex
//            }
//            return
//        }
//
//        // 数组类型，再次递归生成数组中的元素类型
////        if type.toType.isArray {
////            let elementType = type.components(separatedBy: ",").last!
////            if targetMap[elementType.toType.typeID] == nil {
////                buildTree(type: elementType, targetMap: &targetMap, definitions: definitions, hasRead: &hasRead)
////            }
////            return
////        }
//
//        // 字典类型，递归取出value 的元素类型
////        if type.toType.isMap {
////            let valueType = typeId.components(separatedBy: ",").last!
//////            print(valueTypes)
////            if targetMap[valueType.toType.typeID] == nil {
////                buildTree(type: valueType, targetMap: &targetMap, definitions: definitions, hasRead: &hasRead)
////            }
////            return
////        }
//
//        var vertex = targetMap[typeId]
//        var edges = vertex?.edges ?? []
//
//        let typeInfo = definitions[type]
//
//        guard let typeInfo = typeInfo else {
//            return
//        }
//
//        let requiredStrs:[String] = (typeInfo.required.array ?? []).map { $0.string! }
//
//        // 取对象的属性
//        let properties = typeInfo.properties.dictionary ?? [:]
//
//        // 没有属性值，可能是Map 或者JSONObject 类型，需要单独处理
//
//        // 观察swagger 的api 信息可知此规律
//        for (name, propertyInfo) in properties {
//            let isRequired = requiredStrs.contains(name)
//
//            let desc = propertyInfo["description"].string ?? ""
//            let example = propertyInfo.example
//
////            print("example>> \(example)")
//
//            var subType = propertyInfo.type.string
//            // 基本类型或者集合类型
//            if subType != nil  {
//                // 数组
//                if subType == "array" {
//                    var itemType = propertyInfo.items.type.string
//                    if itemType == nil {
//                        itemType = propertyInfo.items.originalRef.string
//                    }
//                    // array|element
//                    subType = "array|\(itemType!.toType.typeID)"
//                }
//
//            } else {
//
//                subType = propertyInfo.originalRef.string
//                if subType!.hasPrefix("Map") {
//                    let getMap = subType!.regex(patten: "«\\w+?»")
//                    let keyValues = getMap.first!.components(separatedBy: ",")
//                    // map<key, value> 表示
//                    subType = "map<\(keyValues.first!), \(keyValues.last!)>"
//                }
//            }
//
//            // 递归构造类型图
//            buildTree(type: subType!, targetMap: &targetMap, definitions: definitions, hasRead: &hasRead)
//
//            let correctExample = getCorrectExample(type: subType!, value: example)
//
//            // 记录类型的属性
//            let edge = Edge(typeId: subType!.toType.typeID, propertyName: name, isRequired: isRequired, description: desc, example: correctExample)
//            edges.append(edge)
//        }
//
//        if vertex == nil {
//            vertex = Vertex(type: type.toType, edges: edges)
//        } else {
//            let preEdges = vertex?.edges
//
//            let preSet: Set<Edge> = Set.init(preEdges ?? [])
//            let set: Set<Edge> = Set.init(edges)
//            let resultSet = preSet.union(set)
//            vertex?.edges = Array.init(resultSet)
//        }
//        targetMap[typeId] = vertex
//    }
    
    func getCorrectExample(type:String, value: JSON) -> String {
        
//        switch type.toType {
//        case .integer(format: _):
//            let res = Int(value.string ?? "0") ?? 0
//            return "\(res)"
//
//        case .number(_):
//            let res = Float(value.string ?? "0.0") ?? 0
//            return "\(res)"
//
//        case .boolean(_):
//            let res = Bool(value.bool ?? true)
//            return "\(String(describing: res))"
//
//        case .custom(_):
//            return ".live"
//
//        case .string(_):
//            return "\"\(value.str)\""
//
//        case .array(let type):
//            if type.isBaseType {
//
//                let res = value.array?.map({ js in
//                    return getCorrectExample(type: type.typeID, value: js)
//                })
//                return "[\(res?.joined(separator: ",") ?? "")]"
//            } else {
//                return "[.live]"
//            }
//
//        case .void(_):
//            return "Void"
//        case .object(_):
//            return ""
//        case .unknown(_):
//           return ""
//        case .map(_, _):
//           return "[:]"
//        }
        return ""
    }
    
    func buildApiMap(_ json: JSON) -> [APIInterface] {
        let paths = json.paths.dictionary!
        
        return paths.map { (key: String, value: JSON) in
            
            let apiJson: (String, JSON)
            if value.dictionary?["get"] != nil {
                let api = value.dictionary!["get"]!
                apiJson = ("get", api)
            } else {
                let api = value.dictionary!["post"]!
                apiJson = ("post", api)
            }
            
            return APIInterface.init(json: apiJson, url: key)
        }
    }
}




