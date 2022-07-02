import Foundation
import Mustache


let toCodeUtils = try JsonToCodeUtils()

func main() {
    
    Task {
        
        do {
            
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            let dateStr = df.string(from: Date())
            let defaultConfig = [
                "date": dateStr,
                "author": toCodeUtils.config.author
            ]
            
            DefaultConfiguration.contentType = .text
            DefaultConfiguration.baseContext = Context(defaultConfig)
            
            // 请求接口数据
            let json = try await toCodeUtils.requestData(from: toCodeUtils.config.api_url)
            
            toCodeUtils.context.json = json
        
            // 创建文件夹
            let _ = try await toCodeUtils.createFolder()
            
            let typeGraph = toCodeUtils.context.jsonFormat!.typeGraph
            let apiInfo = toCodeUtils.context.jsonFormat!.apiMap
            
//            print(typeGraph, apiInfo)
            
//            for language in Language.allCases {
//            }
            
            try Language.swift.generatePlatformAPI(apis: apiInfo, vertex: typeGraph)

            
            // 解析文件
//            for language in toCodeUtils.config.languages {
//                
//                let parseInfo = try await toCodeUtils.parseApi(json: json, language: language)
//                
//                // 通过模板创建文件，保存到文件夹中
//                let _ = try await toCodeUtils.generateFile(parseInfo: parseInfo, language: language)
//            }
            
        } catch {
            print("\(error)")
        }
    }
}

main()

RunLoop.main.run()
