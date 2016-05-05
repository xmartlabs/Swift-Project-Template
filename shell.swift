#!/usr/bin/env xcrun swift

import Foundation

let templateProjectName = "XLProjectName"
let templateBundleDomain = "XLOrganizationIdentifier"
let templateAuthor = "XLAuthorName"
let templateAuthorWebsite = "XLAuthorWebsite"
let templateUserName = "XLUserName"
let templateOrganizationName = "XLOrganizationName"

var projectName = "MyProject"
var bundleDomain = "com.xmartlabs"
var author = "Xmartlabs SRL"
var authorWebsite = "https://xmartlabs.com"
var userName = "xmartlabs"
var organizationName = "Xmartlabs SRL"

let fileManager = NSFileManager.defaultManager()

let runScriptPathURL = NSURL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
let currentScriptPathURL = NSURL(fileURLWithPath: NSURL(fileURLWithPath: Process.arguments[0], relativeToURL: runScriptPathURL).URLByDeletingLastPathComponent!.path!, isDirectory: true)
let iOSProjectTemplateForlderURL = NSURL(fileURLWithPath: "Project-iOS", relativeToURL: currentScriptPathURL)
var newProjectFolderPath = ""
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
    if let _ = fileName.rangeOfString("XLProjectName") {
      let renamedFileName = fileName.stringByReplacingOccurrencesOfString("XLProjectName", withString: projectName)
      try! NSFileManager.defaultManager().moveItemAtURL(self, toURL: NSURL(fileURLWithPath: renamedFileName, relativeToURL: URLByDeletingLastPathComponent))
    }
  }

  func updateContent() {
    guard let path = path, let content = try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding) else {
      print("ERROR READING: \(self)")
      return
    }
    var newContent = content.stringByReplacingOccurrencesOfString(templateProjectName, withString: projectName)
    newContent = newContent.stringByReplacingOccurrencesOfString(templateBundleDomain, withString: bundleDomain)
    newContent = newContent.stringByReplacingOccurrencesOfString(templateAuthor, withString: author)
    newContent = newContent.stringByReplacingOccurrencesOfString(templateUserName, withString: userName)
    newContent = newContent.stringByReplacingOccurrencesOfString(templateAuthorWebsite, withString: authorWebsite)
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

func checkThatProjectForlderCanBeCreated(projectURL: NSURL){
  var isDirectory: ObjCBool = true
  if fileManager.fileExistsAtPath(projectURL.path!, isDirectory: &isDirectory){
      printErrorAndExit("\(projectName) \(isDirectory.boolValue ? "folder already" : "file") exists in \(runScriptPathURL.path) directory, please delete it and try again")
  }
}

func shell(args: String...) -> (output: String, exitCode: Int32) {
    let task = NSTask()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.currentDirectoryPath = newProjectFolderPath
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

print("\nLet's go over some question to create your base project code!")

projectName = prompt("Project name", defaultValue: projectName)

// Check if folder already exists
let newProjectFolderURL = NSURL(fileURLWithPath: projectName, relativeToURL: runScriptPathURL)
newProjectFolderPath = newProjectFolderURL.path!
checkThatProjectForlderCanBeCreated(newProjectFolderURL)

bundleDomain = prompt("Bundle domain", defaultValue: bundleDomain)
author       = prompt("Author", defaultValue: author)
authorWebsite  = prompt("Author Website", defaultValue: authorWebsite)
userName     = prompt("Github username", defaultValue: userName)
organizationName = prompt("Organization Name", defaultValue: organizationName)

// Copy template folder to a new folder inside run script url called projectName
do {
  try fileManager.copyItemAtURL(iOSProjectTemplateForlderURL, toURL: newProjectFolderURL)
} catch let error as NSError {
  printErrorAndExit(error.localizedDescription)
}

// rename files and update content
let enumerator = fileManager.enumeratorAtURL(newProjectFolderURL, includingPropertiesForKeys: [NSURLNameKey, NSURLIsDirectoryKey], options: [], errorHandler: nil)!
var directories = [NSURL]()
print("\nCreating \(projectName) ...")
while let fileURL = enumerator.nextObject() as? NSURL {
    guard !ignoredFiles.contains(fileURL.fileName) else { continue }
    if fileURL.isDirectory {
      directories.append(fileURL)
    }
    else {
      fileURL.updateContent()
      fileURL.renameIfNeeded()
    }
}
for fileURL in directories.reverse() {
  fileURL.renameIfNeeded()
}

print("git init\n")
print(shell("git", "init").output)
print("git add .\n")
print(shell("git", "add", ".").output)
print("git commit -m 'Initial commit'\n")
print(shell("git", "commit", "-m", "'Initial commit'").output)
print("git remote add origin git@github.com:\(userName)/\(projectName).git\n")
print(shell("git", "remote", "add", "origin", "git@github.com:\(userName)/\(projectName).git").output)
print("pod install --project-directory=\(projectName)\n")
print(shell("pod", "install", "--project-directory=\(projectName)").output)
print("open \(projectName)/\(projectName).xcworkspace\n")
print(shell("open", "\(projectName)/\(projectName).xcworkspace").output)
