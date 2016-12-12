//
//  RequestManager.swift
//
//

import UIKit
//import RNCryptor

public enum RequestType: String {
	case Get = "GET"
	case Post = "POST"
	case Delete = "DELETE"
	case Put = "PUT"
}

public enum Response {
	case result(Data, URLResponse?)
	case error(URLResponse?, Error)
}

public enum JSONResponse {
	case array([AnyObject], URLResponse?)
	case dictionary([String: AnyObject], URLResponse?)
	case error(URLResponse?, Error)
}

public enum ImageResponse {
	case image(UIImage)
	case error(Error)
}

public enum RMError: Error {
	case InvalidResponseReceived
	case InvalidRequestReceived
	case CustomMessage(String)
	case Error(Error)
}

public enum RMResponse {
	case error(RMError)
	case successWithDictionary([String: AnyObject])
	case successWithArray([[String: AnyObject]])
}

@objc open class RequestManager: NSObject {
	
	// MARK:- Query String generator
	open class func generateQueryString(_ dictionary: [String: String]) -> String {
		var str: String = ""
		for (key, value) in dictionary {
			str = str + "&" + key + "=" + value
		}
		return "?" + str.trimmingCharacters(in: CharacterSet(charactersIn: "&"))
	}
	
	open class func addURLEncoding(_ string: String) -> String {
		return string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
	}
	
	open class func removeURLEncoding(_ string: String) -> String {
		return string.removingPercentEncoding!
	}
	
	/*
	// MARK:- Encryption and decryption
	
	open class func decryptData(_ data: Data, password: String) throws -> Data {
		do {
			let encryptedText = String(data: data, encoding: String.Encoding.utf8)
			let encryptedData = Data(base64Encoded: encryptedText!,
										options: NSData.Base64DecodingOptions(rawValue: 0))
			let plainText = try RNCryptor.decrypt(data: encryptedData!, withPassword: password)
			return plainText
		} catch {
			throw error
		}
	}
	
	open class func encryptData(_ data: Data, password: String) -> Data {
		let encryptedData = RNCryptor.encrypt(data: data, withPassword: password)
		let base64EncodingOption = NSData.Base64EncodingOptions(rawValue:0)
		let encryptedString = encryptedData.base64EncodedString(options: base64EncodingOption)
		let base64Data = encryptedString.data(using: String.Encoding.utf8)
		return base64Data!
	}
	*/
	
	// MARK:- NSMutableURLRequest generator
	open class func generateRequest(_ urlString: String,
	                                  dictionaryOfHeaders: [String: String]?,
	                                  postData: Data?,
	                                  requestType: RequestType,
	                                  timeOut: Int) -> URLRequest {
		
		// Create Request using URL Sent
		var mRqst = URLRequest(url: URL(string: urlString)!)
		
		// set the request type
		mRqst.httpMethod = requestType.rawValue
		
		// set the content length & content
		if postData != nil {
			mRqst.setValue("\(postData!.count)", forHTTPHeaderField: "Content-Length")
			mRqst.httpBody = postData!
		}
		
		// set the request headers
		if let headers = dictionaryOfHeaders {
			for (key, value) in headers {
				mRqst.setValue(value, forHTTPHeaderField: key)
			}
		}
		
		// set the request time-out
		mRqst.timeoutInterval = TimeInterval(timeOut)
		return mRqst
	}
	
	open class func invokeRequestForData(_ request: URLRequest,
	                                       handler: @escaping (Response) -> Void) -> URLSessionDataTask {
		let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
			if let r = error {
				handler(Response.error(response, r))
			} else if let dataReceived = data {
				handler(Response.result(dataReceived, response))
			} else {
				let erroR = NSError(domain: "RequestManager",
				                    code: 500,
				                    userInfo: ["Some error occured": NSLocalizedDescriptionKey])
				handler(Response.error(response!, erroR))
			}
		}
		task.resume()
		return task
	}
	
	open class func parseJSONData(_ data: Data, urlresponse: URLResponse?) -> JSONResponse {
		do {
			let obj = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
			if let dictionary = obj as? [String: AnyObject] {
				return JSONResponse.dictionary(dictionary, urlresponse)
			} else if let array = obj as? [AnyObject] {
				return JSONResponse.array(array, urlresponse)
			} else {
				let erroR = NSError(domain: "RequestManager",
				                    code: 501,
				                    userInfo: ["Error occured in JSON Parsing": NSLocalizedDescriptionKey])
				return JSONResponse.error(urlresponse, erroR)
			}
		} catch {
			let erroR = NSError(domain: "RequestManager",
			                    code: 501,
			                    userInfo: ["Error occured in JSON Parsing": NSLocalizedDescriptionKey])
			return JSONResponse.error(urlresponse, erroR)
		}
	}
	
	/*
	public class func invokeRequestForJSON(request: NSMutableURLRequest, password: String?, handler: @escaping (JSONResponse) -> Void) -> URLSessionDataTask {
		let task = self.invokeRequestForData(request as URLRequest) { (response: Response) in
			switch (response) {
			case let .result(data, urlresponse):
				if let pswd = password {
					do {
						let decryptedData = try self.decryptData(data, password: pswd)
						handler(self.parseJSONData(decryptedData, urlresponse: urlresponse))
					} catch {
						let erroR = NSError(domain: "RequestManager",
						                    code: 502,
						                    userInfo: ["Error occured in Decrypting Data": NSLocalizedDescriptionKey])
						handler(JSONResponse.error(urlresponse, erroR))
					}
				} else {
					handler(self.parseJSONData(data, urlresponse: urlresponse))
				}
			case let .error(urlresponse, error):
				handler(JSONResponse.error(urlresponse, error))
			}
		}
		return task
	}
	*/
	
	open class func handleResponse(_ jsonResponse: JSONResponse) -> RMResponse {
		switch jsonResponse {
		case let .array(array, _):
			print("Invalid array received \(array)")
			return RMResponse.error(RMError.InvalidResponseReceived)
		case let .dictionary(dictionaryOfResponse, _):
			if let success = dictionaryOfResponse["success"] as? Bool, success == true {
				if let response = dictionaryOfResponse["response"] {
					if let res = response as? [String: AnyObject] {
						return RMResponse.successWithDictionary(res)
					}
					if let res = response as? [[String: AnyObject]] {
						return RMResponse.successWithArray(res)
					}
				}
				return RMResponse.error(RMError.InvalidResponseReceived)
			}
			return RMResponse.error(RMError.InvalidResponseReceived)
		case let .error(_, error):
			return RMResponse.error(RMError.Error(error))
		}
	}
	
	open class func invokeRequestForJSON(_ request: URLRequest, handler: @escaping (JSONResponse) -> Void) -> URLSessionDataTask {
		let task = self.invokeRequestForData(request) { (response: Response) in
			switch (response) {
			case let .result(data, urlresponse):
				handler(self.parseJSONData(data, urlresponse: urlresponse))
			case let .error(urlresponse, error):
				handler(JSONResponse.error(urlresponse, error))
			}
		}
		return task
	}
	
	open class func uploadPhoto(_ request:URLRequest, image:UIImage, Handler:@escaping (Response) -> Void) -> URLSessionDataTask {
		var rqst = request
		let imageData = UIImagePNGRepresentation(image)
		rqst.httpMethod = "POST"
		let boundry = "---------------------------14737809831466499882746641449"
		let stringContentType = "multipart/form-data; boundary=\(boundry)"
		rqst.addValue(stringContentType, forHTTPHeaderField: "Content-Type")
		
		let dataToUpload = NSMutableData()
		
		// add boundry
		let boundryData = "\r\n--" + boundry + "\r\n"
		dataToUpload.append(boundryData.data(using: String.Encoding.utf8)!)
		
		// add file name
		let fileName = "Content-Disposition: form-data; name=\"uploadedfile\"; filename=\"abc.png\"\r\n"
		dataToUpload.append(fileName.data(using: String.Encoding.utf8)!)
		
		// add content type
		let contentType = "Content-Type: application/octet-stream\r\n\r\n"
		dataToUpload.append(contentType.data(using: String.Encoding.utf8)!)
		
		// add UIImage-Data
		dataToUpload.append(imageData!)
		
		// add end boundry
		let boundryEndData = "\r\n--" + boundry + "--\r\n"
		dataToUpload.append(boundryEndData.data(using: String.Encoding.utf8)!)
		
		// set HTTPBody to Request
		rqst.httpBody = dataToUpload as Data
		
		return self.invokeRequestForData(rqst, handler: Handler)
	}

	open class func invokeRequestToDownloadImage(_ stringURLOfImage: String, handler: @escaping (ImageResponse) -> Void) -> URLSessionDataTask? {
		var anotherStr = self.removeURLEncoding(stringURLOfImage).replacingOccurrences(of: ":", with: "_")
		anotherStr = anotherStr.replacingOccurrences(of: "/", with: "_")
		anotherStr = anotherStr.replacingOccurrences(of: "\\", with: "_")
		anotherStr = anotherStr.replacingOccurrences(of: "%", with: "_")
		
		let fm = FileManager.default
		let docDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
		let filePath = docDir + "/" + anotherStr
		if fm.fileExists(atPath: filePath) == true {
			if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
				if let img = UIImage(data: data) {
					handler(ImageResponse.image(img))
					return nil
				}
			}
		}
		
		let req = self.generateRequest(stringURLOfImage, dictionaryOfHeaders: nil, postData: nil, requestType: .Get, timeOut: 60)
		let task = self.invokeRequestForData(req) { (response: Response) in
			switch (response) {
			case let .result(data, _):
				if let img = UIImage(data: data) {
					try? data.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
					handler(ImageResponse.image(img))
				} else {
					let erroR = NSError(domain: "RequestManager",
					                    code: 502,
					                    userInfo: ["Error generating image from specified url.": NSLocalizedDescriptionKey])
					handler(ImageResponse.error(erroR))
				}
			case let .error(_, error) :
				handler(ImageResponse.error(error))
			}
		}
		task.resume()
		return task
	}
	
	open class func generatedLocalURL(_ urlString: String) -> String {
		var anotherStr = self.removeURLEncoding(urlString).replacingOccurrences(of: ":", with: "_")
		anotherStr = anotherStr.replacingOccurrences(of: "/", with: "_")
		anotherStr = anotherStr.replacingOccurrences(of: "\\", with: "_")
		anotherStr = anotherStr.replacingOccurrences(of: "%", with: "_")
		return anotherStr
	}
	
	open class func writeFile(_ tempFilePathURL: URL, fileName: String) throws {
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
	
	@discardableResult open class func downloadFile(_ urlString: String, handler: @escaping (String) -> Void) -> URLSessionDownloadTask? {
		if let url = URL(string: urlString) {
			let downloadtask = URLSession.shared.downloadTask(with: url) { (location: URL?, response: URLResponse?, error: Error?) -> Void in
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
	
	open class func isFileDownloaded(_ urlString: String) -> Bool {
		let anotherStr = self.generatedLocalURL(urlString)
		let fm = FileManager.default
		let docDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
		let filePath = docDir + "/" + anotherStr
		return fm.fileExists(atPath: filePath)
	}
	
	open class func loadCachedFile(_ forURLString: String, handler: @escaping (String) -> Void) -> URLSessionDownloadTask? {
		if self.isFileDownloaded(forURLString) {
			handler(self.generatedLocalURL(forURLString))
			return nil
		} else {
			return self.downloadFile(forURLString, handler: handler)
		}
	}
}
