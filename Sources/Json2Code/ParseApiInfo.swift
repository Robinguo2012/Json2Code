//
//  ParseApiInfo.swift
//  Json2Code
//
//  Created by Sailer Guo on 2022/4/1.
//

import Foundation

// 解析json 数据
extension JsonToCodeUtils {
    
//    func parseApi(json: JSON, language: Language) async throws -> ([String: [String?]], [String: String], [String: String]) {
//
//        return await withUnsafeContinuation { continuation in
//
//            var allApis:[APIInterface] = []
//            var tagMap:[String: [String?]] = [:]
//
//            let jpaths = json.paths
//
//            var requestModel:[String: String] = [:]
//            var responseModel: [String: String] = [:]
//
//            jpaths.dictionary?.forEach({ (key: String, value: JSON) in
//
//                let apiInfo = value.dictionary?.first
//
//                // 接口是否已经废弃，已经废弃的接口不生成相应的文件
//                if value.deprecated.bool ?? false == false {
//
//                    let apiModel = language.apiType.init(json: apiInfo!, url: key)
//                    allApis.append(apiModel)
//
//                    var tagArr = tagMap[apiModel.module!]
//                    if tagArr == nil {
//                        tagArr = []
//                    }
////
////                    let templateUrl = self.templatePath.appendingPathComponent("\(language.rawValue)/\(templateFiles.api)")
////                    let domainTemplateUrl = self.templatePath.appendingPathComponent("\(language.rawValue)/\(templateFiles.domain)")
////
////                    let apiInfo = try? language.parser?.getApiInfo(endPointTemplate: templateUrl, modelTemplate: domainTemplateUrl, api: apiModel)
////
////                    requestModel.merge(apiInfo?.1 ?? [:]) { $1 }
////                    responseModel.merge(apiInfo?.2 ?? [:]) { $1 }
////
////                    tagArr?.append(apiInfo?.0!)
////                    tagMap[apiModel.module!] = tagArr
//                }
//            })
//
//            let parseInfo:([String: [String?]], [String: String], [String: String]) = (tagMap, requestModel, responseModel)
//
//            continuation.resume(with: .success(parseInfo))
//        }
//    }
    
}

