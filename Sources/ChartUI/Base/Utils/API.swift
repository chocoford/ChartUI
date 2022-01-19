//
//  API.swift
//  API
//
//  Created by Dove Zachary on 2021/9/7.
//


struct AvgVideoTimeData: Codable {
    let _id: String;
    let count: Int;
}

func getAvgVideoTimeByDateAPI() async -> [AvgVideoTimeData] {
    return []
}
