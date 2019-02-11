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
    self.view.backgroundColor = UIColor(white: 242 / 255.0, alpha: 1.0)
    self.tableView.tag = 1488
    refresher.addTarget(self, action: #selector(reqestData), for: .valueChanged)
    self.tableView.refreshControl = self.refresher
    self.view.add(subview: self.tableView, with: [.leading, .trailing, .bottom, .top])
    self.font = UIFont.systemFont(ofSize: 15)
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
  
  
  
  private func updateString(status: SectionTable) {

    newsVersionTwo = status
    tableView.reloadData()
    if case .isOk = status.type {
      SldNewsArticle.updateLastReadDate(of: Date())
    }
    
  }
  
  
  @objc func reqestData() {
    let deadLine = DispatchTime.now() + .milliseconds(500)
    DispatchQueue.main.asyncAfter(deadline: deadLine) {
      connectAndSaveNewsData(callback: self.updateString)
      self.refresher.endRefreshing()
    }
  }
  
  private var font = UIFont()
  private let tableView = UITableView(frame: .zero, style: .plain)
  private let refresher = UIRefreshControl()
  private var newsStruct: [SldNewsArticle] = []
  private var newsVersionTwo: SectionTable!
  
  
}



extension ViewController: UITableViewDataSource {
  public func numberOfSections(in _: UITableView) -> Int {
    guard let news = newsVersionTwo else { return 0 }
    switch news.type {
    case let .isOk (newsStruct):
      return newsStruct.count
    case .isError:
      return 1
    }
  }
  
  public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let news = newsVersionTwo else { return 0 }
    return news.section
  }
  
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if case .isOk (let value) = newsVersionTwo.type {
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellNews
      cell.createCellNews(message: value[indexPath.section].message["en"]!,
                          isRead: value[indexPath.section].isRead,
                          font: self.font)
      return cell
    }
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let news = newsVersionTwo else { return nil }
    switch news.type {
    case let .isOk(data):
      let view = CustomSection(date: data[section].date, isRead: data[section].isRead)
      return view
    case let .isError (message):
      let view = CustomSection(message: message)
      return view
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard let news = newsVersionTwo else { return 0 }
    switch news.type {
    case .isOk:
      return 30
    case .isError:
      return self.tableView.bounds.height
    }
  }
  
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
  
  public func createCellNews(message: String, isRead: Bool, font: UIFont) {
    textView.font =  font
    let modifiedFont = NSString(format:"<span style=\"font-family: \(textView.font!.fontName); font-size: \(textView.font!.pointSize)\">%@</span>" as NSString, message)
    
    textView.attributedText = try! NSAttributedString(
      data: modifiedFont.data(using: String.Encoding.unicode.rawValue, allowLossyConversion: true)!,
      options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html,
                NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue],
      documentAttributes: nil)

    
    if isRead {
      view.backgroundColor = UIColor(white: 242 / 255.0, alpha: 1.0)
    } else {
      view.backgroundColor = UIColor(red: 149 / 255, green: 202 / 255, blue: 1, alpha: 1)
    }
  }
  public func createCellError(message: String, font: UIFont) {
    textView.font =  font
    
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
  
  init(message: String) {
    super.init(frame: .zero)
    textField.text = message
    textField.isEnabled = false
    textField.isSelected = false
    textField.textAlignment = .center
    textField.contentVerticalAlignment = .center
    textField.backgroundColor = UIColor(white: 242 / 255.0, alpha: 1.0)
//    self.add(subview: textField, with: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    self.add(subview: textField, with: [.leading, .trailing, .top, .bottom])
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

struct SectionTable {
  let section: Int
  let type: TypeData
  enum TypeData {
    case isOk(data: [SldNewsArticle])
    case isError(message: String)
  }
}

fileprivate func connectAndSaveNewsData(callback: @escaping (SectionTable) -> Void) {
  //  guard let url = URL(string: "http://ads.penreader.com/?protocol=2&catalog_id=27") else { return } //&catalog_id=27
  guard let url = URL(string: "http://ads.penreader.com/?protocol=2&catalog_id=27&from=1970-01-01&devel=1&lang=ru") else { return }
  let task = URLSession.shared.dataTask(with: url) { data, response, error in
    var errorMessage: String = "Unknown error"
    if error != nil {
      errorMessage = error!.localizedDescription
    }
    if let httpResponse = response as? HTTPURLResponse {
      switch  httpResponse.statusCode {
      case 200:
        guard let data = data else { return }
        let dataString = String(data: data, encoding: .utf8)!
        let dataToNews = parseData(data: dataString)
        DispatchQueue.main.async {
          
          callback(SectionTable(section: 1, type: .isOk(data: dataToNews)))
        }
        return
      case 300:
        errorMessage = "The request does not match the protocol"
        return
      default:
        errorMessage = "An unexpected server-side error occurred"
      }
    }
    DispatchQueue.main.async {
      callback(SectionTable(section: 0, type: .isError(message: errorMessage)))
    }
  }
  task.resume()
}

func findText(with regex: String, for text: String) -> [String] {
  let regex = try! NSRegularExpression(pattern: regex, options: [])
  let matches = regex.matches(in: text,
                              options: [],
                              range: NSMakeRange(0, text.count))
  
  let stringArray = matches.map { String(text[Range($0.range, in: text)!]) }
  if stringArray.isEmpty {
    return []
  }
  return stringArray
}

func replaceTag(for oldTag: String, on newTag: String, in text: String) -> String {
  let mutableText = NSMutableString(string: text)
  do {
    var regex = try NSRegularExpression(pattern: "<\(oldTag)>", options: [])
    regex.replaceMatches(in: mutableText, options: [],
                              range: NSMakeRange(0, mutableText.length),
                              withTemplate: "<\(newTag)>")
    
    regex = try NSRegularExpression(pattern: "</\(oldTag)>", options: [])
    regex.replaceMatches(in: mutableText, options: [],
                            range: NSMakeRange(0, mutableText.length),
                            withTemplate: "</\(newTag)>")
  } catch {
    print("Not found title")
    return text
  }
  
  return String(mutableText)
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
      let mutableMessage = replaceTag(for: "title", on: "h4", in: message)
      let keyLocale = findText(with: "(?s)(?<=locale=\")(.*?)(?=\")", for: mutableMessage)
      if let key = keyLocale.first {
        localeForMessage[key] = mutableMessage
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
  if !items.isEmpty {
    newsArticle.sort { return $0.date > $1.date }
  } else {
    newsArticle.append(SldNewsArticle(identificator: "FUCK", date: Date(), message: ["en": data], isRead: false))
  }
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

