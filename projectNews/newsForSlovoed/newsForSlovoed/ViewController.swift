//: A UIKit based Playground for presenting user interface

import UIKit

import Foundation
import WebKit

class ViewController: UIViewController, UITextViewDelegate {
  override func loadView() {
    super.loadView()
    
    updateUI()
    self.tableView.dataSource = self
    self.tableView.delegate = self
    tableView.tableFooterView = UIView()
    self.edgesForExtendedLayout = []
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    self.tableView.backgroundColor = UIColor(white: 242 / 255.0, alpha: 1.0)
    self.view.add(subview: tableView, with: [.leading, .trailing, .bottom, .top])
    self.view.backgroundColor = UIColor(white: 242 / 255.0, alpha: 1.0)
    
    
    refresher.addTarget(self, action: #selector(reqestData), for: .valueChanged)
    self.tableView.refreshControl = self.refresher
    
  }
  
  private func updateUI() {
    self.newsSection = []
    self.newsSection.append(NewsSection(numberOfRows: 0, type: .work))
    guard var data =  SldNewsArticle.decode() else { print("no news"); return} //обработать
    SldNewsArticle.updateLastReadDate(of: Date())
    
    let len = "en" //здесь должно в дальнейшем происходить чтение языка
    for item in data {
      // здесь необходимо добавить локализацию для отображения информации о дате выхода новости
      //на вход необходимо отправить массив слов (по умолчанию английский язык)
      guard let message = item.message[len] else { continue }
      let news = makeNews(date: item.date.isString(with: [""]), isRead: item.isRead, message: message)
      self.newsSection.append(NewsSection(numberOfRows: 1, type: news))
    }
    for (index, _) in data.enumerated() {
      data[index].isRead = true
    }
    SldNewsArticle.encode(newsArticle: data)
    
  }
  
  private func makeNews(date: String, isRead: Bool, message: String) -> NewsSection.SectionType {
    let view = UIView(frame: .zero)
    
    
    let textView = UITextView(frame: .zero)
    textView.isEditable = false
    textView.isSelectable = true
    textView.isScrollEnabled = false
    textView.dataDetectorTypes = .link
    textView.isUserInteractionEnabled = true
    let htmlData = NSString(string: message).data(using: String.Encoding.unicode.rawValue)
    let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
    textView.attributedText = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
    textView.dataDetectorTypes = .link

    
    view.add(subview: textView, with: UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0))
//    view.layer.cornerRadius = 5
    if isRead {
      view.backgroundColor = UIColor(white: 242 / 255.0, alpha: 1.0)
    } else {
      view.backgroundColor = UIColor(red: 149 / 255, green: 202 / 255, blue: 1, alpha: 1)
    }
//    view.layer.masksToBounds = true;
    

    let textField = UITextField()
    textField.text = date
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
    print("value = \(isRead)")
    return NewsSection.SectionType.article(date: textField, message: view)
  }
  
  private let tableView = UITableView(frame: .zero, style: .plain)
  private var newsSection: [NewsSection] = []
  
  var refresher = UIRefreshControl()
  
  @objc func reqestData() {
    
    let deadLine = DispatchTime.now() + .milliseconds(500)
    DispatchQueue.main.asyncAfter(deadline: deadLine) {
//      let addNews = self.makeNews(date: "Today", isRead: false, message: "This is new news")
      //            self.newsSection.append(NewsSection(numberOfRows: 1, type: addNews))
//      self.newsSection.insert(NewsSection(numberOfRows: 1, type: addNews), at: 1)
      //            self.tableView.beginUpdates()
      //            self.tableView.insertSections(IndexSet(), with: .automatic)
      //            self.tableView.endUpdates()
//      SldNewsArticle.encode(newsArticle: [])
      self.updateUI()
      self.tableView.reloadData()
      self.refresher.endRefreshing()
    }
    
  }
  
}

fileprivate struct NewsSection {
  let numberOfRows: Int
  let type: SectionType
  
  enum SectionType {
    case work
    case article(date: UITextField, message: UIView)
  }
}
//может надо убрать
extension UITableViewCell: UITextViewDelegate {
  
  //    private func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
  //        return true
  //    }
}

extension ViewController: UITableViewDataSource {
  public func numberOfSections(in _: UITableView) -> Int {
    return self.newsSection.count
  }
  
  public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.newsSection[section].numberOfRows
  }
  
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
    
    switch newsSection[indexPath.section].type {
    case .work:
      break
    case let .article(_, messageView):
      cell.contentView.add(subview: messageView, with: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
      cell.backgroundColor = UIColor(white: 242 / 255.0, alpha: 1.0)
      cell.selectionStyle = .none
    }
    return cell
  }
  
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    switch newsSection[section].type {
    case .work:
      let get = GetNewsController()
      view.add(subview: get.view, with: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    case let .article(date, _):
      view.add(subview: date, with: UIEdgeInsets(top: 0, left: 20, bottom: 5, right: 20))
    }
    return view
  }
  
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }
  
}

extension ViewController: UITableViewDelegate {
  public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    //    switch sections[indexPath.section].type {
    //    case .custom:
    //      guard let _ = dataCells else { return }
    //      callback(self.dataCells![indexPath.row].controller())
    //    case .additionalArticles:
    //      let globalIndex = dataWordList!.list.childFor(globalIndex: nil, childIndex: indexPath.row)
    //      let identifier = dataWordList!.list.identifierForItem(at: globalIndex)
    //      callback(dataWordList!.controller(identifier))
    print("delegate")
  }
  
}



private class GetNewsController: UIViewController {
  override func loadView() {
    super.loadView()
    let switchGetNews = UISwitch()
    self.view.add(subview: switchGetNews, with: [])
    switchGetNews.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    switchGetNews.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    let label = UILabel()
    self.view.add(subview: label, with: [])
    label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    label.rightAnchor.constraint(equalTo: switchGetNews.leftAnchor, constant: -10).isActive = true
    label.text = "Получать новости"
    
  }
  
  deinit {
    print("off switch")
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
  
  static func encode(newsArticle: [SldNewsArticle]) {
    let classObject = HelperClass(newArticle: newsArticle)
    NSKeyedArchiver.archiveRootObject(classObject, toFile: HelperClass.path())
  }
  
  static func decode() -> [SldNewsArticle]? {
    let classObject = NSKeyedUnarchiver.unarchiveObject(withFile: HelperClass.path()) as? HelperClass
    return classObject?.newArticle
  }
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

extension SldNewsArticle {
  @objc(SldKitCore11NewsArticle11HelperClass)class HelperClass: NSObject, NSCoding {
    var newArticle: [SldNewsArticle]?
    
    init(newArticle: [SldNewsArticle]) {
      self.newArticle = newArticle
      super.init()
    }
    
    class func path() -> String {
      let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
      return (url!.appendingPathComponent("file.archive1").path)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
      var newArticle: [SldNewsArticle] = []
      var index = 0
      while true {
        
        guard let id = aDecoder.decodeObject(forKey: "identificator\(index)") as? String else { break }
        guard let date = aDecoder.decodeObject(forKey: "date\(id)") as? Date else { break }
        guard let message = aDecoder.decodeObject(forKey: "message\(id)") as? [String: String] else { break }
        let isRead = aDecoder.decodeBool(forKey: "isRead\(id)")
        newArticle.append(SldNewsArticle(identificator: id, date: date, message: message, isRead: isRead))
        index += 1
      }
      self.init(newArticle: newArticle)
    }
    func encode(with aCoder: NSCoder) {
      guard let news = newArticle else { return }
      for (index, article) in news.enumerated() {
        let id = article.identificator
        aCoder.encode(article.identificator, forKey: "identificator\(index)")
        aCoder.encode(article.date, forKey: "date\(id)")
        aCoder.encode(article.message, forKey: "message\(id)")
        aCoder.encode(article.isRead, forKey: "isRead\(id)")
      }
    }
  }
}



public func connectAndSaveNewsData() {
  guard let url = URL(string: "http://ads.penreader.com/?protocol=2&catalog_id=27") else { return } //&catalog_id=27
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
        DispatchQueue.main.async {
          SldNewsArticle.encode(newsArticle: parseData(data: dataString))
          printData()
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
        print("parse = \(isRead)\n dataNews = \(calculatedDate) dataRead \(lastReadDate)")
        newsArticle.append(SldNewsArticle(identificator: id,
                                          date: calculatedDate,
                                          message: localeForMessage, isRead: isRead))
      }
    }
  }
  
  return newsArticle
}

func printData(){
  guard let getArticle = SldNewsArticle.decode() else { return }
  for new in getArticle {
    print(new.identificator)
    print(new.date)
    //        print(new.isRead)
  }
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

enum Anchor {
  case leading
  case trailing
  case top
  case bottom
}

extension UIView {
  func add(subview: UIView, with anchors: [Anchor]) {
    self.addSubview(subview)
    subview.translatesAutoresizingMaskIntoConstraints = false
    for anchor in anchors {
      applyAnchor(anchor: anchor, view: subview)
    }
  }
  
  func centerSubviewsVertically() {
    self.subviews.forEach({ $0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true })
  }
  
  func removeView(with tag: Int) {
    if let view = self.viewWithTag(tag) {
      if
        let bar = self as? UINavigationBar,
        !ProcessInfo().isOperatingSystemAtLeast(
          OperatingSystemVersion(majorVersion: 11, minorVersion: 0, patchVersion: 0)) {
        // avoiding NSInternalInconsistencyException on iOS 10.3-
        bar.constraints.forEach({ $0.isActive = false })
      }
      view.removeFromSuperview()
    }
  }
  
  func removeAllSubviews() {
    let toRemove = self.subviews
    for v in toRemove {
      v.removeFromSuperview()
    }
  }
  
  func add(subview: UIView, with insets: UIEdgeInsets) {
    self.addSubview(subview)
    subview.translatesAutoresizingMaskIntoConstraints = false
    
    subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insets.left).isActive = true
    subview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -insets.right).isActive = true
    subview.topAnchor.constraint(equalTo: self.topAnchor, constant: insets.top).isActive = true
    subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -insets.bottom).isActive = true
  }
}

private func applyAnchor(anchor: Anchor, view: UIView) {
  switch anchor {
  case .leading:
    view.leadingAnchor.constraint(equalTo: view.superview!.leadingAnchor).isActive = true
  case .trailing:
    view.trailingAnchor.constraint(equalTo: view.superview!.trailingAnchor).isActive = true
  case .top:
    view.topAnchor.constraint(equalTo: view.superview!.safeAreaLayoutGuide.topAnchor).isActive = true
  case .bottom:
    view.bottomAnchor.constraint(equalTo: view.superview!.bottomAnchor).isActive = true
  }
}
