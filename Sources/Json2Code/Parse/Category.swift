//
//  Category.swift
//  Json2Code
//
//  Created by Sailer Guo on 2022/4/20.
//

import Foundation
import CloudKit

extension String {
    
    func isArray() -> Bool {
        return self.contains("[")
    }
    
    func typeMapper(lan: Language) -> Self {
        
        if lan == .swift {
            
            if self.contains("array") {
                let innerType = self.components(separatedBy: "|").last!
                return "[\(innerType.typeMapper(lan: lan))]"
            }
            
            // 这种情况是非标准情况，实际中可以和服务的不要用这种方式
            if self == "int" {
                return "Int"
            }
            
            if self.contains("integer") {
                let arr = self.components(separatedBy: "_")
                if arr.last!.contains("32") {
                    return "Int32"
                } else if arr.last!.contains("64") {
                    return "Int64"
                } else {
                    return "Int"
                }
            }
            
            
            
            if self.contains("number") {
                return self.contains("float") ? "Float": "Double"
            }
            
            if self.contains("boolean") {
                return "Bool"
            }
            
            if self.contains("string") {
                return "String"
            }
            
            if self.contains("object") || self.contains("JSONObject") {
                return "AnyObject"
            }
            
            return self
            
        } else {
            return ""
        }
    }
    
    // 通过正则表达式匹配特定字符串
    func regex(patten: String) -> [Self] {
        do {
            let regex = try NSRegularExpression(pattern: patten, options: NSRegularExpression.Options.init(rawValue: 0))
            return regex.matches(in: self, options: [], range: NSRange(self.startIndex..., in: self)).map { checkResult in
                return String(self[Range(checkResult.range, in: self)!])
            }
        } catch  {
            return []
        }
       
    }
    
}


extension Array {
    
    func sortSlice<K: Hashable>(by keyPath: KeyPath<Element, K>) -> [K:[Element]] {
        var sortedMap:[K: [Element]] = [:]
        
        for item in self {
           let key = item[keyPath: keyPath]
            var tagArr:[Element] = sortedMap[key] ?? []
            tagArr.append(item)
            sortedMap[key] = tagArr
        }
        return sortedMap
    }
}

