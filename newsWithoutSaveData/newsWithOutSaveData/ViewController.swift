//: A UIKit based Playground for presenting user interface

//здесь должно в дальнейшем происходить чтение языка

  // здесь необходимо добавить локализацию для отображения информации о дате выхода новости
  //на вход необходимо отправить массив слов (по умолчанию английский язык)


import UIKit

import Foundation
import WebKit

class ViewController: UIViewController, UITextViewDelegate, UITableViewDelegate {
  override func loadView() {
    super.loadView()
    
    connectAndSaveNewsData(callback: updateString)
    self.tableView.dataSource = self
    self.tableView.delegate = self

    tableView.tableFooterView = UIView()
    self.edgesForExtendedLayout = []
    self.tableView.register(CellNews.self, forCellReuseIdentifier: "cell")
    self.tableView.backgroundColor = UIColor(white: 242 / 255.0, alpha: 1.0)
//    self.view.add(subview: tableView, with: [.leading, .trailing, .bottom, .top])
    self.view.backgroundColor = UIColor(white: 242 / 255.0, alpha: 1.0)
    self.tableView.tag = 1488
    refresher.addTarget(self, action: #selector(reqestData), for: .valueChanged)
    self.tableView.refreshControl = self.refresher
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 30
    
//    let heightStatusBar = UIApplication.shared.statusBarFrame.height
//    let inset = UIEdgeInsets(top: heightStatusBar, left: 0, bottom: 0, right: 0)
//    tableView.contentInset = inset
//    tableView.scrollIndicatorInsets = inset
  }
  
  private var newsStruct: [SldNewsArticle] = []
  
  private func updateString(data: String) {
    
    let dataToNews = parseData(data: data)
    self.view.removeAllSubviews()
    newsStruct = dataToNews
    self.view.add(subview: tableView, with: [.leading, .trailing, .bottom, .top])
    tableView.reloadData()
    SldNewsArticle.updateLastReadDate(of: Date())
  }

  
  @objc func reqestData() {
    let deadLine = DispatchTime.now() + .milliseconds(500)
    DispatchQueue.main.asyncAfter(deadline: deadLine) {
      connectAndSaveNewsData(callback: self.updateString)
      self.refresher.endRefreshing()
    }
  }
  
  private let tableView = UITableView(frame: .zero, style: .plain)
  private let refresher = UIRefreshControl()
 
}



extension ViewController: UITableViewDataSource {
  public func numberOfSections(in _: UITableView) -> Int {
    return self.newsStruct.count
  }
  
  public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellNews
    cell.createCellNews(message: newsStruct[indexPath.section].message["en"]!, isRead: newsStruct[indexPath.section].isRead)
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = CustomSection(date: newsStruct[section].date, isRead: newsStruct[section].isRead)
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
//  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//    print(newsInfo[indexPath.section].message.bounds.size.height)
//
//    return 100
//  }
}

class CellNews: UITableViewCell {
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    textView.isEditable = false
    textView.isSelectable = true
    textView.isScrollEnabled = false
    textView.dataDetectorTypes = .link
    textView.isUserInteractionEnabled = true
    textView.dataDetectorTypes = .link
    
    view.add(subview: textView, with: UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0))
    self.contentView.add(subview: view, with: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    self.backgroundColor = UIColor(white: 242 / 255.0, alpha: 1.0)
    self.selectionStyle = .none
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func createCellNews(message: String, isRead: Bool) {
    let htmlData = NSString(string: message).data(using: String.Encoding.unicode.rawValue)
    let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
    textView.attributedText = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
    if isRead {
      view.backgroundColor = UIColor(white: 242 / 255.0, alpha: 1.0)
    } else {
      view.backgroundColor = UIColor(red: 149 / 255, green: 202 / 255, blue: 1, alpha: 1)
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    textView.adjustsFontForContentSizeCategory = true
  }
  public var textView = UITextView()
  public var view = UIView()
}

class CustomSection: UIView {
  init(date: Date, isRead: Bool) {
    super.init(frame: .zero)
    
    textField.text = date.isString(with: [""])
    textField.isEnabled = false
    textField.isSelected = false
    textField.textAlignment = .right
    if isRead {
      textField.font = UIFont.systemFont(ofSize: 12)
      textField.textColor = .lightGray
    } else {
      textField.font = UIFont.boldSystemFont(ofSize: 12)
    }
    
    textField.contentVerticalAlignment = .bottom
    textField.backgroundColor = UIColor(white: 242 / 255.0, alpha: 1.0)
    self.add(subview: textField, with: UIEdgeInsets(top: 0, left: 20, bottom: 5, right: 20))
  }
  private let textField = UITextField(frame: .zero)
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}






extension String {
  var htmlToAttributedString: NSAttributedString? {
    guard let data = data(using: .utf8) else { return NSAttributedString() }
    do {
      return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
    } catch {
      return NSAttributedString()
    }
  }
  var htmlToString: String {
    return htmlToAttributedString?.string ?? ""
  }
}

extension NSMutableAttributedString {
  
  public func setAsLink(textToFind:String, linkURL:String) -> Bool {
    
    let foundRange = self.mutableString.range(of: textToFind)
    if foundRange.location != NSNotFound {
      self.addAttribute(.link, value: linkURL, range: foundRange)
      return true
    }
    return false
  }
}

func filePath(key:String) -> String {
  let manager = FileManager.default
  let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
  return (url!.appendingPathComponent(key).path)
}

struct SldNewsArticle {
  var identificator: String
  var date: Date
  var message: [String: String]
  var isRead: Bool
  
  static func updateLastReadDate(of date: Date) {
    UserDefaults.standard.setValue(date, forKey: "lastDateReadNews")
  }
  
  static func loadLastReadDate() -> Date {
    guard let date = UserDefaults.standard.object(forKey: "lastDateReadNews") as? Date else {
      return Date(timeIntervalSince1970: 0)
    }
    return date
  }
}

fileprivate func connectAndSaveNewsData(callback: @escaping (String) -> Void) {
//  guard let url = URL(string: "http://ads.penreader.com/?protocol=2&catalog_id=27") else { return } //&catalog_id=27
  guard let url = URL(string: "http://ads.penreader.com/?protocol=2&catalog_id=27&from=1970-01-01&devel=1&lang=ru") else { return }
  let task = URLSession.shared.dataTask(with: url) { data, response, error in
    if error != nil {
      print(error!)
      return
    }
    if let httpResponse = response as? HTTPURLResponse {
      switch  httpResponse.statusCode {
      case 200:
        guard let data = data else { return }
        let dataString = String(data: data, encoding: .utf8)!
//        let dataToNews = parseData(data: dataString)
//        print("first array count =  \(dataToNews.count)")
        DispatchQueue.main.async {
          callback(dataString)
//          callback(dataToNews)
        }
      case 300:
        print("The request does not match the protocol")
        return
      default:
        print("An unexpected server-side error occurred")
        return
      }
    }
  }
  task.resume()
}

func findText(with regex: String, for text: String) -> [String] {
  let regex = try! NSRegularExpression(pattern: regex, options: [])
  let matches = regex.matches(in: text,
                              options: [],
                              range: NSRange(text.startIndex..., in: text))
  
  let stringArray = matches.map { String(text[Range($0.range, in: text)!]) }
  if stringArray.isEmpty {
    return []
  }
  return stringArray
}

func parseData(data: String) -> [SldNewsArticle] {
  
  var  newsArticle: [SldNewsArticle] = []
  let items = findText(with: "(?s)(?=<item)(.*?)(/item>)", for: data)
  
  for item in items {
    let id = findText(with: "(?s)(?<=id=\")(.*?)(?=\")", for: item)
    let utime = findText(with: "(?s)(?<=utime=\")(.*?)(?=\")", for: item)
    
    let messages = findText(with: "(?s)(?=<message )(.*?)(/message>)", for: item)
    var localeForMessage: [String: String] = [:]
    for message in messages {
      let keyLocale = findText(with: "(?s)(?<=locale=\")(.*?)(?=\")", for: message)
      if let key = keyLocale.first {
        localeForMessage[key] = message
      }
    }
    if !localeForMessage.isEmpty {
      if let id = id.first, let utime = utime.first {
        let calculatedDate = Date(timeIntervalSince1970: Double(utime)!)
        let lastReadDate = SldNewsArticle.loadLastReadDate()
        let isRead = calculatedDate < lastReadDate
        newsArticle.append(SldNewsArticle(identificator: id,
                                          date: calculatedDate,
                                          message: localeForMessage, isRead: isRead))
      }
    }
  }
  newsArticle.sort { return $0.date > $1.date }
  return newsArticle
}

extension Date {
  fileprivate struct DateOfString {
    var ranges = [CountableRange<Int>]()
    var descriptions = [String]()
    init(with array: [CountableRange<Int>: String]){
      for item in array {
        ranges.append(item.key)
        descriptions.append(item.value)
      }
    }
    subscript(value: Int) -> String? {
      for (i, range) in self.ranges.enumerated() {
        if range ~= value {
          return descriptions[i]
        }
      }
      return nil
    }
  }
  
  fileprivate func isString(with dateLocalizationStrings: [String]) -> String {
    let defaultRangeOfStrings = [0..<1: "Today",
                                 1..<2: "Yesterday",
                                 2..<7: "This week",
                                 7..<14: "Last week",
                                 14..<21: "2 week ago",
                                 21..<30: "This month",
                                 30..<60: "Last month",
                                 60..<90: "2 month ago",
                                 90..<120: "4 month ago",
                                 120..<150: "5 month ago",
                                 150..<365: "This year",
                                 365..<730: "Last year",
                                 730..<5000: "More than two years ago"]
    
    var dictionaryRangeOfStrings: [CountableRange<Int>: String] = [:]
    
    if dateLocalizationStrings.count == defaultRangeOfStrings.count {
      let rangeArray = Array(defaultRangeOfStrings.keys).sorted{$0.startIndex < $1.startIndex}
      for (index, item) in rangeArray.enumerated() {
        dictionaryRangeOfStrings[item] = dateLocalizationStrings[index]
      }
    } else {
      dictionaryRangeOfStrings = defaultRangeOfStrings
    }
    
    let numberOfDays = Int(Date().timeIntervalSince(self)) / (60 * 60 * 24)
    let dateOfString = DateOfString(with: dictionaryRangeOfStrings)
    
    guard let result = dateOfString[numberOfDays] else {return "Unknown date"}
    return result
  }
}

