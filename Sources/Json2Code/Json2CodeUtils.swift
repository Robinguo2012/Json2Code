//
//  Json2CodeUtils.swift
//  Json2Code
//
//  Created by Sailer Guo on 2022/4/4.
//

import Foundation

let fm = FileManager.default

struct Config: Decodable {
    let author: String
    let api_url: String
}

class JContext {
    var requestModels: Set<String> = []
    var responseModels: Set<String> = []
    
    var generateModelState:[String:Bool] = [:]
    var jsonFormat: JsonFormat?

    // 获取到json，赋值给枚举进行解析
    var json: JSON? {
        
        didSet {
            let swagger = json?.dictionary?[JsonFormat.postman(nil).formatName]
            let postman = json?.dictionary?[JsonFormat.swagger(nil).formatName]
            if swagger != nil {
                jsonFormat = .swagger(json!)
            } else if postman != nil {
                jsonFormat = .postman(json!)
            } else {
                fatalError("Unsupported json format.")
            }
        }
    }
}

public class JsonToCodeUtils {
    
    var context: JContext = .init()
    var config: Config

    private let arguments: [String]
    
    public init(arguments: [String] = CommandLine.arguments) throws {
        self.arguments = arguments
        
        let configFile = "/Users/sailerguo/config.json"
        let jsonDecoder = JSONDecoder()
        let data = try Data(contentsOf: URL(fileURLWithPath: configFile))
        config = try jsonDecoder.decode(Config.self, from: data)
    }
    
    // 文件夹主目录
    var parent: URL {
        return fm.urls(for: .desktopDirectory, in: .userDomainMask)[0]
    }
    
    // 模板文件目录
    var templatePath: URL {
        return parent.appendingPathComponent("Template")
    }
    
    // 模板文件
    let templateFiles:(api: String, domain: String, endPoint: String, base: String) = ("Api.mustache", "Domain.mustache", "Endpoint.mustache", "BaseInterface.mustache")
    
    // 结果文件目录
    var apiFilePath: URL {
        return parent.appendingPathComponent("API_\(context.json!.info.version.string!)")
    }
    
    // 结果文件夹
//    let apiSubpaths:(endPoint: String, inputModel: String, outputModel: String) = ("EndPoints", "InputModel", "OutputModel")
}

