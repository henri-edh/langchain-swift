//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/22.
//

import Foundation
import NIOPosix
import AsyncHTTPClient
import OpenAIKit

public struct Dalle: LLM {
    let size: DalleImage.Size
    public init(size: DalleImage.Size) {
        self.size = size
    }
    
    public func send(text: String, stops: [String] = []) async -> LLMResult {
        let env = Env.loadEnv()
        
        if let apiKey = env["OPENAI_API_KEY"] {
            let baseUrl = env["OPENAI_API_BASE"] ?? "api.openai.com"
            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

            let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
            defer {
                // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
                try? httpClient.syncShutdown()
            }
            let configuration = Configuration(apiKey: apiKey, api: API(scheme: .https, host: baseUrl))

            let openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
            let reps = try! await openAIClient.images.create(prompt: text, size: dalleTo(size: size))
            return LLMResult(llm_output: reps.data.first!.url)
        } else {
            print("Please set openai api key.")
            return LLMResult(llm_output: "Please set openai api key.")
        }
        
    }
}
