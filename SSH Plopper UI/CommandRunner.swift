import Foundation

class SSHHelper {
    func addKey(data: NSData) -> Int {
        let task = NSTask()
        task.launchPath = "/usr/bin/ssh-add"
        task.arguments = ["-t", "1m", "-"]
        let pipe = NSPipe()
        pipe.fileHandleForWriting.writeData(data)
        pipe.fileHandleForWriting.closeFile()
        task.standardInput = pipe
        task.launch()
        task.waitUntilExit()
        return Int(task.terminationStatus)
    }
}
