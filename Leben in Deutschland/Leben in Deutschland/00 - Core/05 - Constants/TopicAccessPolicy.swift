//
//  TopicAccessPolicy.swift
//  Leben in Deutschland
//
//  Access policy for Learn by Topics. Only the first category (Law & constitution) is free for study.
//

import Foundation

enum TopicAccessPolicy {
    /// First category in content order (Law & constitution in DE) is free. All others require pro.
    static func isFreeCategory(categoryName: String, categories: [CategoryModel]) -> Bool {
        guard let first = categories.first else { return false }
        return categoryName == first.name
    }
}
