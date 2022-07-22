//
//  Model.swift
//  testSwiftyJSON
//
//  Created by Luan on 2019/1/29.
//  Copyright © 2019 Luan. All rights reserved.
//

import Foundation
import SwiftyJSON

let path = Bundle.main.path(forResource: "document", ofType: "json")
let count = 100_000

class DataManager {
    
    static func createData() -> Data? {
        guard let data = NSData(contentsOfFile: path!) as Data? else {
            print("error data")
            return nil
        }
        return data
    }
    
    static func test_SwiftyJSON() {
		let startDate = Date().timeIntervalSince1970
        guard let data = createData() else { return }
        for _ in 0...count {
            for json in JSON(data: data).arrayValue {
                let _ = Test(json: json)
            }
        }
		print("\(#function) spent time: \(Date().timeIntervalSince1970 - startDate)")
    }
    
    static func test_JSONSerialization() {
		let startDate = Date().timeIntervalSince1970
        guard let data = createData() else { return }
        do {
            if let jsons = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: AnyObject]] {
                for _ in 0...count {
                    for json in jsons {
                        let _ = Test(object: json)
                    }
                }
				print("\(#function) spent time: \(Date().timeIntervalSince1970 - startDate)")
            }
        } catch {
            print(error)
        }
    }

	static func test_SwiftyJSONWithNSDictionary() {
		let startDate = Date().timeIntervalSince1970
		guard let data = createData() else { return }
		for _ in 0...count {
			for json in JSON(data: data).arrayValue {
				let _ = Test(JSONWithNSDictionary: json)
			}
		}
		print("\(#function) spent time: \(Date().timeIntervalSince1970 - startDate)")
	}
}

struct Test {
    let id: Int
    let title: String
    let completed: Bool
    init(json: JSON) {
        self.id = json["id"].intValue
        self.title = json["title"].stringValue
        self.completed = json["completd"].boolValue
    }
    
    init(object: [String: AnyObject]) {
        self.id = object["id"] as? Int ?? 0
        self.title = object["title"] as? String ?? ""
        self.completed = object["completed"] as? Bool ?? false
    }

	init(JSONWithNSDictionary json: JSON) {
		let dict = json.dictionaryObject!
		self.id = dict["id"] as? Int ?? 0
		self.title = dict["title"] as? String ?? ""
		self.completed = dict["completed"] as? Bool ?? false
	}
}
