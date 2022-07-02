//
//  Type.swift
//  Json2Code
//
//  Created by Sailer Guo on 2022/4/12.
//

import Foundation

// 每个类型都是唯一的
//enum TypeEnum: Hashable {
//    case integer(format: String?)
//    case number(format:  String?)
//    case string(String?)
//    case void(String?)
//    case boolean(String?)
//    case object(String?)
//
////    case custom(String?)
//    case custom(Array<Edge>)
//    case unknown(String?)
//    
//    indirect case map(TypeEnum, TypeEnum)
//    indirect case array(TypeEnum)
//
//    var typeID: String {
//        switch self {
//        case .integer(_):
//            return "integer"
//        case .number(_):
//            return "number"
//        case .string(_):
//            return "string"
//        case .void( _):
//            return "void"
//        case .boolean( _):
//            return "boolean"
//        case .array(let type):
//            return "array|\(type.typeID)"
//        case .map(let key, let value):
//            return "map<\(key.typeID),\(value.typeID)>"
//        case .custom(let typeName):
//            return typeName!
//            
//        case .object(_):
//            return "object"
//
//        case .unknown(_):
//            return "unknown type"
//        }
//    }
//    
//    var isBaseType: Bool {
//        switch self {
//        case .custom(_):
//            return false
//        case .array(_):
//            return false
//        case .map(_, _):
//            return false
//        default:
//            return true
//        }
//    }
//    
//    var isArray: Bool {
//        switch self {
//        case .array(_):
//            return true
//        default:
//            return false
//        }
//    }
//    
//    var isMap: Bool {
//        switch self {
//        case .map(_, _):
//            return true
//        default:
//            return false
//        }
//    }
//}

//extension TypeEnum {
//
//    func mapToString(to langauge: Language) -> String {
//        switch self {
//        case .custom(let name):
//            return name!
//        case .array(let itemType):
//            return langauge.arrayTypeMap(itemType.mapToString(to: langauge))
//        case .map(let keyType, let valueType):
//            return langauge.mapTypeMap(key: keyType.mapToString(to: langauge), valueType: valueType.mapToString(to: langauge))
//        default:
//            return langauge.baseTypeMap[self] ?? "Any"
//        }
//    }
//}






