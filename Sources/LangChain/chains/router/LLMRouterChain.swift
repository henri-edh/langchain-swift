//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/7.
//

import Foundation

public struct Route {
    let destination: String
    let next_inputs: String
}

public class LLMRouterChain: DefaultChain {
    let llmChain: LLMChain
    
    public init(llmChain: LLMChain, memory: BaseMemory? = nil, outputKey: String? = nil, callbacks: [BaseCallbackHandler] = []) {
        self.llmChain = llmChain
        super.init(memory: memory, outputKey: outputKey, callbacks: callbacks)
    }
    
    public func route(args: [String: String]) async -> Route {
        let parsed = await llmChain.predict_and_parse(args: args)
        // check and route
        switch parsed {
            case .dict(let d):
                return Route(destination: d["destination"]!, next_inputs: d["next_inputs"]!)
            default:
                return Route(destination: "", next_inputs: "")
        }
        
    }
    
}
