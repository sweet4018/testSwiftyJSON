# testSwiftyJSON
看到網友說 SwifyJSON 的雷，所以想測試了一下到底是不是很慢，實際結果真的有差異，比較慢一些。
https://www.slideshare.net/hokilaj/swiftyjson-72240783

主要測試方法：
* Model 方面

```swift
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
```

* 執行內容：先產生 Data

```swift
    static func createData() -> Data? {
        guard let data = NSData(contentsOfFile: path!) as Data? else {
            print("error data")
            return nil
        }
        return data
    }
```
* 再來實際測試方法，每個過程都會有一個開始時間，最後再減去完成時間，就可以得到總花費時間

```swift
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
```

* 執行 `let count = 100_000` 次

* 結果：
```
test_JSONSerialization() spent time: 0.16343
test_SwiftyJSON() spent time: 2.36988
test_SwiftyJSONWithNSDictionary() spent time: 1.12207
```

![image](https://cdn-images-1.medium.com/max/1600/1*8raHWwyyFQ034M-SXwtkIA.png)

## 結論
假設你的資料量沒有很大，那這 parse 的時間就沒什麼差異了，應該可以繼續安心使用。

但假設真的遇到資料很大很複雜，且團隊就是要用 `SwiftyJSON` 的話，可以試試看剛剛混合的版本，先轉成 `json.dictionaryObject` 後續再繼續解析，可以看到時間省下一半（詳細請看：test_SwiftyJSONWithNSDictionary）。

另外那還有一個小技巧是 parse 走過的 node 要 cache 起來，之後好 reuse 。
例如：
```swift
    init(json: JSON) {
        self.value1 = json["setting"]["value1"].string
        self.value2 = json["setting"]["value2"].string
        self.value3 = json["setting"]["value3"].string
    }
```
上面就是一個不好的做法，每次都要在讀取一次 `json["setting"]`。

好的做法應該是：
```swift
    init(json: JSON) {
        let setting = json["setting"]
        self.value1 = setting["value1"].string
        self.value2 = setting["value2"].string
        self.value3 = setting["value3"].string
    }
```

最後就是不常使用，且需要高複雜運算的 property ，最好使用 `lazy` ，這樣就不用在 `init` 時耗能。
