import Foundation
import UIKit
import MediaPlayer

class CustomAudioPlayer: NSObject {
    
    class var shared: CustomAudioPlayer {
        get {
            struct Single {
                static var shared = CustomAudioPlayer()
            }
            return Single.shared
        }
    }
    
    var player: AVAudioPlayer?
    var downloadTask: URLSessionDownloadTask?
    
    func setMediaItemProperties(_ url: URL) {
        let mpic = MPNowPlayingInfoCenter.default()
        var playerInfo: [String: Any] = [: ]
        let playerItem = AVPlayerItem(url: url)
        let metadataList = playerItem.asset.metadata
        
        for item in metadataList {
            if let stringValue = item.value {
                if item.commonKey == "title" {
                    playerInfo[MPMediaItemPropertyTitle] = stringValue
                }
                if item.commonKey  == "artist" {
                    playerInfo[MPMediaItemPropertyArtist] = stringValue
                }
                if item.commonKey  == "artwork" {
                    if let audioImage = UIImage(data: item.value as! Data) {
                        playerInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: audioImage)
                    }
                }
            }
        }
        playerInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        playerInfo[MPMediaItemPropertyPlaybackDuration] = self.player!.duration
        playerInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.player!.currentTime
        mpic.nowPlayingInfo = playerInfo
    }
    
    func playAudio(_ filePath: String) {
        let url = URL(fileURLWithPath: filePath)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            if let player = self.player {
                player.stop()
            }
            self.player = try AVAudioPlayer(contentsOf: url)
            self.player!.numberOfLoops = -1
            self.player!.prepareToPlay()
            self.player!.play()
            self.setMediaItemProperties(url)
        } catch {
            // couldn't load file :(
        }
    }
    
    func pausePlayer() {
        if let player = CustomAudioPlayer.shared.player {
            if player.rate != 0 && player.isPlaying == true {
                player.pause()
            }
        }
    }
    
    func isPaused() -> Bool {
        if let player = CustomAudioPlayer.shared.player {
            if player.rate != 0 && player.isPlaying == false {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func resume() {
        if let player = CustomAudioPlayer.shared.player {
            if player.rate != 0 && player.isPlaying == false {
                player.play()
            }
        }
    }
    
    func isPlaying() -> Bool {
        if let player = CustomAudioPlayer.shared.player {
            if player.rate != 0 && player.isPlaying == true {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func updateSeekBarToTime(_ time: TimeInterval) {
        if let player = CustomAudioPlayer.shared.player {
            if player.rate != 0 && player.isPlaying == true {
                player.currentTime = time
                self.setMediaItemProperties(player.url!)
            }
        }
    }
    
    func downloadAndPlayAudio(_ urlString: String, timeOut: Int, handler: @escaping (_ hasErrors: Bool) -> Void) {
        if let task = self.downloadTask {
            task.cancel()
        }
        let mpic = MPNowPlayingInfoCenter.default()
        mpic.nowPlayingInfo = nil
        self.downloadTask = CustomAudioPlayer.loadCachedFile(urlString, timeout: timeOut) { (filePath: String) -> Void in
            OperationQueue.main.addOperation {
                if filePath.characters.count > 0 {
                    let docDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
                    CustomAudioPlayer.shared.playAudio( docDir + "/" + filePath)
                    handler(false)
                } else {
                    handler(true)
                }
            }
        }
        if let task = self.downloadTask {
            task.priority = 1.0
        }
    }
}

extension CustomAudioPlayer {
    
    class func removeURLEncoding(_ string: String) -> String {
        return string.removingPercentEncoding!
    }
    
    class func generatedLocalURL(_ urlString: String) -> String {
        var anotherStr = CustomAudioPlayer.removeURLEncoding(urlString).replacingOccurrences(of: ":", with: "_")
        anotherStr = anotherStr.replacingOccurrences(of: "/", with: "_")
        anotherStr = anotherStr.replacingOccurrences(of: "\\", with: "_")
        anotherStr = anotherStr.replacingOccurrences(of: "%", with: "_")
        return anotherStr
    }
    
    class func writeFile(_ tempFilePathURL: URL, fileName: String) throws {
        let fm = FileManager.default
        let docDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let filePath = docDir + "/" + fileName
        let docDirFileURL = URL(fileURLWithPath: filePath)
        do {
            try fm.copyItem(at: tempFilePathURL, to: docDirFileURL)
        } catch {
            throw error
        }
    }
    
    @discardableResult class func downloadFile(_ urlString: String, timeout: Int, handler: @escaping (String) -> Void) -> URLSessionDownloadTask? {
        if let url = URL(string: urlString) {
            let rqst = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: TimeInterval(timeout))
            let downloadtask = URLSession.shared.downloadTask(with: rqst) { (location: URL?, response: URLResponse?, error: Error?) -> Void in
                if location != nil {
                    print("Local file url is \(location)")
                    let anotherStr = self.generatedLocalURL(urlString)
                    do {
                        try self.writeFile(location!, fileName: anotherStr)
                        handler(anotherStr)
                    } catch {
                        handler("")
                    }
                }
            }
            downloadtask.resume()
            return downloadtask
        } else {
            return nil
        }
    }
    
    class func isFileDownloaded(_ urlString: String) -> Bool {
        let anotherStr = CustomAudioPlayer.generatedLocalURL(urlString)
        let fm = FileManager.default
        let docDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let filePath = docDir + "/" + anotherStr
        return fm.fileExists(atPath: filePath)
    }
    
    class func loadCachedFile(_ forURLString: String, timeout: Int, handler: @escaping (String) -> Void) -> URLSessionDownloadTask? {
        if CustomAudioPlayer.isFileDownloaded(forURLString) {
            handler(CustomAudioPlayer.generatedLocalURL(forURLString))
            return nil
        } else {
            return CustomAudioPlayer.downloadFile(forURLString, timeout: timeout, handler: handler)
        }
    }
}

public class CustomAudioManager: NSObject {
    public var index = 0
    public class var shared: CustomAudioManager {
        get {
            struct Single {
                static var shared = CustomAudioManager()
            }
            return Single.shared
        }
    }
    
    func setupRemoteCommandCenter() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(CustomAudioManager.actionNextAudio(_:handler:)))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(CustomAudioManager.actionPreviousAudio(_:handler:)))
        commandCenter.pauseCommand.addTarget(self, action: #selector(CustomAudioManager.actionPauseAudio))
        commandCenter.playCommand.addTarget(self, action: #selector(CustomAudioManager.actionPlayAudio(_:handler:)))
        if #available(iOS 9.1, *) {
            commandCenter.changePlaybackPositionCommand.addTarget(self, action: #selector(CustomAudioManager.seekBarSlidingEventHandler(_:)))
        }
    }
    
    override init() {
        super.init()
        self.setupRemoteCommandCenter()
    }
    
    public var audios: [String] = []
    
    func downloadAndPlayAudio(_ timeOut: Int, handler: @escaping (_ hasErrors: Bool) -> Void) {
        CustomAudioPlayer.shared.downloadAndPlayAudio(CustomAudioManager.shared.audios[CustomAudioManager.shared.index], timeOut: timeOut, handler: handler)
    }
    
    func seekBarSlidingEventHandler(_ event: MPChangePlaybackPositionCommandEvent) {
        CustomAudioPlayer.shared.updateSeekBarToTime(event.positionTime)
    }
    
    func playAudioUsingCurrentIndex(_ timeOut: Int, handler: @escaping (_ hasErrors: Bool) -> Void) {
        CustomAudioPlayer.shared.pausePlayer()
        CustomAudioManager.shared.downloadAndPlayAudio(timeOut, handler: handler)
    }
    
    public func actionPlayAudio(_ timeOut: Int, handler: @escaping (_ hasErrors: Bool) -> Void) {
        if CustomAudioPlayer.shared.isPaused() {
            CustomAudioPlayer.shared.resume()
        } else if CustomAudioPlayer.shared.isPlaying() {
            print("Do nothing. Already playing.")
        } else {
            CustomAudioManager.shared.playAudioUsingCurrentIndex(timeOut, handler: handler)
        }
    }
    
    public func actionPauseAudio() {
        CustomAudioPlayer.shared.pausePlayer()
    }
    
    public func actionNextAudio(_ timeOut: Int, handler: @escaping (_ hasErrors: Bool) -> Void) {
        if CustomAudioManager.shared.index + 1 >= CustomAudioManager.shared.audios.count {
            CustomAudioManager.shared.index = 0
        } else {
            CustomAudioManager.shared.index = CustomAudioManager.shared.index + 1
        }
        CustomAudioManager.shared.playAudioUsingCurrentIndex(timeOut, handler: handler)
    }
    
    public func actionPreviousAudio(_ timeOut: Int, handler: @escaping (_ hasErrors: Bool) -> Void) {
        if CustomAudioManager.shared.index - 1 < 0 {
            CustomAudioManager.shared.index = CustomAudioManager.shared.audios.count - 1
        } else {
            CustomAudioManager.shared.index = CustomAudioManager.shared.index - 1
        }
        CustomAudioManager.shared.playAudioUsingCurrentIndex(timeOut, handler: handler)
    }
    
}
