#!/usr/bin/env xcrun swift

import Foundation

let templateFrameworkName = "XLProductName"
let templateBundleDomain = "XLOrganizationIdentifier"
let templateAuthor = "XLAuthorName"
let templateAuthorEmail = "XLAuthorEmail"
let templateUserName = "XLUserName"
let templateOrganizationName = "XLOrganizationName"

var frameworkName = "MyFramework"
var bundleDomain = "com.xmartlabs"
var author = "Xmartlabs SRL"
var authorEmail = "swift@xmartlabs.com"
var userName = "xmartlabs"
var organizationName = "Xmartlabs SRL"

let fileManager = NSFileManager.defaultManager()

let runScriptPathURL = NSURL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
let currentScriptPathURL = NSURL(fileURLWithPath: NSURL(fileURLWithPath: Process.arguments[0], relativeToURL: runScriptPathURL).URLByDeletingLastPathComponent!.path!, isDirectory: true)
let iOSFrameworkTemplateForlderURL = NSURL(fileURLWithPath: "Project-iOS", relativeToURL: currentScriptPathURL)
var newFrameworkFolderPath = ""
let ignoredFiles = [".DS_Store", "UserInterfaceState.xcuserstate"]

extension NSURL {
  var fileName: String {
    var fileName: AnyObject?
    try! getResourceValue(&fileName, forKey: NSURLNameKey)
    return fileName as! String
  }

  var isDirectory: Bool {
    var isDirectory: AnyObject?
    try! getResourceValue(&isDirectory, forKey: NSURLIsDirectoryKey)
    return isDirectory as! Bool
  }

  func renameIfNeeded() {
    if let _ = fileName.rangeOfString("XLProductName") {
      let renamedFileName = fileName.stringByReplacingOccurrencesOfString("XLProductName", withString: frameworkName)
      try! NSFileManager.defaultManager().moveItemAtURL(self, toURL: NSURL(fileURLWithPath: renamedFileName, relativeToURL: URLByDeletingLastPathComponent))
    }
  }

  func updateContent() {
    guard let path = path, let content = try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding) else {
      print("ERROR READING: \(self)")
      return
    }
    var newContent = content.stringByReplacingOccurrencesOfString(templateFrameworkName, withString: frameworkName)
    newContent = newContent.stringByReplacingOccurrencesOfString(templateBundleDomain, withString: bundleDomain)
    newContent = newContent.stringByReplacingOccurrencesOfString(templateAuthor, withString: author)
    newContent = newContent.stringByReplacingOccurrencesOfString(templateUserName, withString: userName)
    newContent = newContent.stringByReplacingOccurrencesOfString(templateAuthorEmail, withString: authorEmail)
    newContent = newContent.stringByReplacingOccurrencesOfString(templateOrganizationName, withString: organizationName)
    try! newContent.writeToURL(self, atomically: true, encoding: NSUTF8StringEncoding)
  }
}

func printInfo<T>(message: T)  {
  print("\n-------------------Info:-------------------------")
  print("\(message)")
  print("--------------------------------------------------\n")
}

func printErrorAndExit<T>(message: T) {
  print("\n-------------------Error:-------------------------")
  print("\(message)")
  print("--------------------------------------------------\n")
  exit(1)
}

func checkThatFrameworkForlderCanBeCreated(frameworkURL: NSURL){
  var isDirectory: ObjCBool = true
  if fileManager.fileExistsAtPath(frameworkURL.path!, isDirectory: &isDirectory){
      printErrorAndExit("\(frameworkName) \(isDirectory.boolValue ? "folder already" : "file") exists in \(runScriptPathURL.path) directory, please delete it and try again")
  }
}

func shell(args: String...) -> (output: String, exitCode: Int32) {
    let task = NSTask()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.currentDirectoryPath = newFrameworkFolderPath
    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()
    task.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = NSString(data: data, encoding: NSUTF8StringEncoding) as? String ?? ""
    return (output, task.terminationStatus)
}

func prompt(message: String, defaultValue: String) -> String {
  print("\n> \(message) (or press Enter to use \(defaultValue))")
  let line = readLine()
  return line == nil || line == "" ? defaultValue : line!
}

print("\nLet's go over some question to create your framework base project!")

frameworkName = prompt("Framework name", defaultValue: frameworkName)

// Check if folder already exists
let newFrameworkFolderURL = NSURL(fileURLWithPath: frameworkName, relativeToURL: runScriptPathURL)
newFrameworkFolderPath = newFrameworkFolderURL.path!
checkThatFrameworkForlderCanBeCreated(newFrameworkFolderURL)

bundleDomain = prompt("Bundle domain", defaultValue: bundleDomain)
author       = prompt("Author", defaultValue: author)
authorEmail  = prompt("Author Email", defaultValue: authorEmail)
userName     = prompt("Github username", defaultValue: userName)
organizationName = prompt("Organization Name", defaultValue: organizationName)

// Copy template folder to a new folder inside run script url called frameworkName
do {
  try fileManager.copyItemAtURL(iOSFrameworkTemplateForlderURL, toURL: newFrameworkFolderURL)
} catch let error as NSError {
  printErrorAndExit(error.localizedDescription)
}

// rename files and update content
let enumerator = fileManager.enumeratorAtURL(newFrameworkFolderURL, includingPropertiesForKeys: [NSURLNameKey, NSURLIsDirectoryKey], options: [], errorHandler: nil)!
var frameworkDirectories = [NSURL]()
print("\nCreating \(frameworkName) ...")
while let fileURL = enumerator.nextObject() as? NSURL {
    guard !ignoredFiles.contains(fileURL.fileName) else { continue }
    if fileURL.isDirectory {
      frameworkDirectories.append(fileURL)
    }
    else {
      fileURL.updateContent()
      fileURL.renameIfNeeded()
    }
}
for fileURL in frameworkDirectories.reverse() {
  fileURL.renameIfNeeded()
}

print(shell("carthage", "update", "--platform", "iOS").output)
print(shell("git", "init").output)
print(shell("git", "add", ".").output)
print(shell("git", "commit", "-m", "'Initial commit'").output)
print(shell("git", "remote", "add", "origin", "git@github.com:\(userName)/\(frameworkName).git").output)
print(shell("open", "\(frameworkName).xcworkspace").output)
