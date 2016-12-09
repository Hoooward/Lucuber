//
//  OpenGraph.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/7.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation
import Kanna


public struct OpenGraph {
    
    public var URL: URL
    
    public var siteName: String?
    public var title: String?
    public var description: String?
    public var previewImageURLString: String?
    public var previewViedoURLString: String?
    public var previewAudioURLString: String?
    
    public var isValid: Bool {
        guard
            let siteName = siteName?.trimming(trimmingType: .whitespaceAndNewLine), !siteName.isEmpty,
            let title = title?.trimming(trimmingType: .whitespaceAndNewLine),
                !title.isEmpty,
            let _ = previewImageURLString else {
            return false
        }
        return true
    }
    
    init(URL: URL) {
        self.URL = URL
    }
    
    static func fromHTMLString(_ HTMLString: String, forURL URL: URL) -> OpenGraph? {
        
        if let doc = Kanna.HTML(html: HTMLString, encoding: String.Encoding.utf8) {
            
            var openGraph = OpenGraph(URL: URL)
            
            if let metaSet = doc.head?.css("meta") {
                
                var openGraphInfo = [String: String]()
                
                for meta in metaSet {
                    
                    if let property = meta["property"]?.lowercased() {
                        if property.hasPrefix("og:") {
                            if let content = meta["content"] {
                                openGraphInfo[property] = content
                            }
                        }
                    }
                }
                
                openGraph.siteName = openGraphInfo["og:site_name"]
                openGraph.title = openGraphInfo["og:title"]
                openGraph.description = openGraphInfo["og:description"]
                openGraph.previewImageURLString = openGraphInfo["og:image"]
                
                if openGraph.siteName == nil {
                    openGraph.siteName = URL.host
                }
                
                if openGraph.title == nil {
                    if let title = doc.head?.css("title").first?.text, !title.isEmpty {
                        openGraph.title = title
                    }
                }
                
                if openGraph.description == nil {
                    for meta in metaSet {
                        
                        if let name = meta["name"]?.lowercased() {
                            if name == "description" {
                                if let description = meta["content"], !description.isEmpty {
                                    openGraph.description = description
                                    break
                                }
                            }
                        }
                    }
                }
                
                if openGraph.previewImageURLString == nil {
                    openGraph.previewImageURLString = HTMLString.opengraph_firstImageURL?.absoluteString
                }
                
                if openGraph.description == nil {
                    if let firstParagraph = doc.body?.css("p").first?.text {
                        openGraph.description = firstParagraph
                    }
                }
                
                openGraph.siteName = openGraph.siteName?.opengraph_removeAllWhitespaces
                openGraph.title = openGraph.title?.opengraph_removeAllWhitespaces
                openGraph.description = openGraph.description?.opengraph_removeAllNewLines
                
            }
            return openGraph
        }
        return nil
    }
    
}
