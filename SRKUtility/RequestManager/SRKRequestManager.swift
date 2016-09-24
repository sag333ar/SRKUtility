//
//  SRKRequestManager.swift
//  Pods
//
//  Created by Sagar on 12/31/15.
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

@objc open class SRKRequestManager: NSObject {
	
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
			let plainText = try RNCryptor.decryptData(encryptedData!, password: password)
			return plainText
		} catch {
			throw error
		}
	}
	
	open class func encryptData(_ data: Data, password: String) -> Data {
		let encryptedData = RNCryptor.encryptData(data, password: password)
		let base64EncodingOption = NSData.Base64EncodingOptions(rawValue:0)
		let encryptedString = encryptedData.base64EncodedStringWithOptions(base64EncodingOption)
		let base64Data = encryptedString.dataUsingEncoding(String.Encoding.utf8)
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
				let erroR = NSError(domain: "SRKRequestManager",
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
				let erroR = NSError(domain: "SRKRequestManager",
				                    code: 501,
				                    userInfo: ["Error occured in JSON Parsing": NSLocalizedDescriptionKey])
				return JSONResponse.error(urlresponse, erroR)
			}
		} catch {
			let erroR = NSError(domain: "SRKRequestManager",
			                    code: 501,
			                    userInfo: ["Error occured in JSON Parsing": NSLocalizedDescriptionKey])
			return JSONResponse.error(urlresponse, erroR)
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
					let erroR = NSError(domain: "SRKRequestManager",
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
	
}
