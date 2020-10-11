/*
* SwiftMsgPack
* Lightweight MsgPack for Swift
*
* Created by:	Daniele Margutti
* Email:			hello@danielemargutti.com
* Web:			http://www.danielemargutti.com
* Twitter:		@danielemargutti
*
* Copyright © 2017 Daniele Margutti
*
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*
*/

import Foundation

import XCTest
@testable import SwiftMsgPack

class SwiftMsgPackTests_Data: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}

	static let allTests = [
		("test_shortData", test_shortData),
		("test_mediumData", test_mediumData),
		("test_bigData", test_bigData),
	];

	// MARK: - Test Data

	func test_shortData() {
		let len = 6
		let (rawBytes, packedBytes) = generateTestData(len)
		performTestData(name: "Test Short Data", value: rawBytes, expected: packedBytes)
	}
	
	func test_mediumData() {
		let len = Int( UInt16(UInt16.max - 1) )
		let (rawBytes, packedBytes) = generateTestData(len)
		performTestData(name: "Test Medium Data", value: rawBytes, expected: packedBytes)
	}
	
	func test_bigData() {
		let len = Int( UInt32(UInt16.max) + 1 )
		let (rawBytes, packedBytes) = generateTestData(len)
		performTestData(name: "Test Long Data", value: rawBytes, expected: packedBytes)
	}
	
	// MARK: - Helper Functions
	
    func generateTestData(_ length: Int) -> (rawBytes: [UInt8], packedBytes: [UInt8]) {
		var packedBytes: [UInt8] = []
		let rawBytes: [UInt8] = generateRandomNumberSequence(length)
		
		if length < Int(UInt8.max) {
			// Header
			packedBytes.append(UInt8(0xc4))
			// Length
			packedBytes.append(UInt8(length))
		}
		else if length < Int(UInt16.max) {
			// Header
			packedBytes.append(UInt8(0xc5))
			// Length (big endian)
			packedBytes.append(UInt8((length >> 8) & 0xff))
			packedBytes.append(UInt8(length & 0xff))
		}
		else if length < Int(UInt32.max) {
			packedBytes.append(UInt8(0xc6))
			// Length (big endian)
			packedBytes.append(UInt8((length >> 24) & 0xff))
			packedBytes.append(UInt8((length >> 16) & 0xff))
			packedBytes.append(UInt8((length >> 8) & 0xff))
			packedBytes.append(UInt8(length & 0xff))
		}
		// Append real data
		packedBytes.append(contentsOf: rawBytes)

		return (rawBytes, packedBytes)
	}
	
	func generateRandomNumberSequence(_ length: Int) -> [UInt8] {
		var items: [UInt8] = []
		for _ in 0..<length {
			items.append(UInt8.random(in: 0..<UInt8.max))
		}
		return items
	}
	
	func performTestData(name testName: String, value: [UInt8], expected bytes: [UInt8]) {
		var packed = Data()
		
		do {
			try packed.pack(value)
			
			// Check resulting data size
			guard bytes.count == packed.count else {
				XCTFail("[\(testName)] Resulting packed data is different in byte size than expected (\(packed.count), \(bytes.count) expected)")
				return
			}
			
			// Validate each byte
			var idx = 0
			for byte in packed {
				guard byte == bytes[idx] else {
					XCTFail("[\(testName)] Byte \(idx) is different from expected (\(byte), \(bytes[idx]) expected)")
					return
				}
				idx += 1
			}
			
			// Unpack data
			guard let unpacked = try packed.unpack() else {
				XCTFail("[\(testName)] Failed to unpack data")
				return
			}
			
			// Cast to Data object
			guard let unpacked_data = unpacked as? [UInt8] else {
				XCTFail("[\(testName)] Failed to cast unpacked data to `Data` instance")
				return
			}
			
			// Check if data is equal
			guard unpacked_data == value else {
				XCTFail("[\(testName)] Unpackaed data is different from expected")
				return
			}
			
		} catch let err {
			// Something went wrong while packing data
			XCTFail("[\(testName)] Failed to pack data: \(err) (src='\(value)')")
			return
		}
	}
	
}
