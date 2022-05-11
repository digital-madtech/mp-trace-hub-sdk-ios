//
//  LogInterceptor.swift
//

import Foundation

class LogInterceptor: NSObject {
    // consumes logs from STDOUT
    let inputPipe: Pipe = Pipe()
    
    // consumes logs from STDERR
    let inputErrPipe: Pipe = Pipe()
    
    // sends logs back to STDOUT
    let outputPipe: Pipe = Pipe()
    
    // sends logs back to STDERR
    let outputErrPipe: Pipe = Pipe()
    
    private var didListenerStart: Bool = false
    
    override init() {
    }
    
    func initialize() {
        
        strongify(self) { strongSelf in
            strongSelf.inputPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
                
                let data = fileHandle.availableData
                if let string = String(data: data, encoding: String.Encoding.utf8) {
                    if Config.shared.listenerMode == THListenerMode.on {
                        WebSocketService.shared.send(data: string, messageType: MessageType.log)
                    }
                }
                
                // Write input back to stdout
                strongSelf.outputPipe.fileHandleForWriting.write(data)
            }
            
            strongSelf.inputErrPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
                
                let data = fileHandle.availableData
                if let string = String(data: data, encoding: String.Encoding.utf8) {
                    if Config.shared.listenerMode == THListenerMode.on {
                        WebSocketService.shared.send(data: string, messageType: MessageType.log)
                    }
                }
                
                // Write input back to stdout
                strongSelf.outputErrPipe.fileHandleForWriting.write(data)
            }
        }
    }
}

extension LogInterceptor {
    
    func startListening() -> THResponse {
        
        if didListenerStart {
            return THResponse.alreadyStarted
        }
        
        didListenerStart = true
        
        dup2(stdoutFileDescriptor, outputPipe.fileHandleForWriting.fileDescriptor)
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, stdoutFileDescriptor)
        
        dup2(stderrFileDescriptor, outputErrPipe.fileHandleForWriting.fileDescriptor)
        dup2(inputErrPipe.fileHandleForWriting.fileDescriptor, stderrFileDescriptor)
        
        return THResponse.success
    }
    
    func stopListening() {
//        freopen("/dev/stdout", "a", stdout)
//
//        [inputPipe.fileHandleForReading, outputPipe.fileHandleForWriting].forEach { file in
//            file.closeFile()
//        }
    }
    
    var stdoutFileDescriptor: Int32 {
        return FileHandle.standardOutput.fileDescriptor
    }
    
    var stderrFileDescriptor: Int32 {
        return FileHandle.standardError.fileDescriptor
    }
    
    func strongify<Context: AnyObject, Arguments>(_ context: Context?,
                                                  closure: @escaping (Context, Arguments) -> Void) -> (Arguments) -> Void {
        return { [weak context] arguments in
            guard let strongContext = context else { return }
            closure(strongContext, arguments)
        }
    }
    
    func strongify<Context: AnyObject>(_ context: Context?, closure: @escaping (Context) -> Void) {
        guard let strongContext = context else { return }
        closure(strongContext)
    }
}

