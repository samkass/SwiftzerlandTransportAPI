//
//  SwiftzerlandTransportAPI.swift
//
//  MIT License
//
//  Copyright (c) 2017 Sam Kass
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Sam Kass on 7/2/17.

// TODO: Support more parameters
// TODO: Correctly identify required fields (remove some of the ?'s)
// TODO: Better error handling

import Foundation

enum BackendError: Error {
  case urlError(reason: String)
  case objectSerialization(reason: String)
}

extension String {
  static func xyToString(_ x : Double, _ y : Double) -> String {
    return "\(x),\(y)"
  }
}

class TransportAPI {
  
  enum QueryType {case all, station, poi, address }
  
  // Transportation types are not supported by new TransportAPI back end; ignored for now
  enum TransportationType {case all, ice_tgv_rj, ec_ic, ir, re_d, ship, s_sn_r, bus, cableway, arz_ext, tramway_underground }
  
  // MARK: Locations query
  
  static func endpointForLocationQuery(_ query: String, type: QueryType = .all) -> String {
    return "https://transport.opendata.ch/v1/locations?"+"query=\(query)&type=\(type)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
  }
  
  static func endpointForLocationXY(_ x: Float, _ y: Float) -> String {
    return "https://transport.opendata.ch/v1/locations?"+"x=\(x)&y=\(y)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
  }
  
  static func locationsForQuery(_ query: String, type: QueryType = .all, completionHandler: @escaping (Locations?, Error?) -> Void) {
    // set up URLRequest with URL
    let endpoint = TransportAPI.endpointForLocationQuery(query, type: type)
    guard let url = URL(string: endpoint) else {
      print("Error: cannot create locations URL")
      let error = BackendError.urlError(reason: "Could not construct URL")
      completionHandler(nil, error)
      return
    }
    let urlRequest = URLRequest(url: url)
    
    // Make request
    let session = URLSession.shared
    let task = session.dataTask(with: urlRequest, completionHandler: {
      (data, response, error) in
      // handle response to request
      // check for error
      guard error == nil else {
        completionHandler(nil, error!)
        return
      }
      // make sure we got data in the response
      guard let responseData = data else {
        print("Error: did not receive data")
        let error = BackendError.objectSerialization(reason: "No locations data in response")
        completionHandler(nil, error)
        return
      }
      
      // parse the result as JSON
      // then create a Locations object from the JSON
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      
      do {
        let locations = try decoder.decode(Locations.self, from: responseData)
        completionHandler(locations, nil)
      } catch {
        print("error trying to convert locations data to JSON")
        print(error)
        completionHandler(nil, error)
      }
      
    })
    task.resume()
  }
  
  // MARK: Locations query
  
  static func endpointForConnections(from: String, to: String, date: String = "", time: String = "", transportations: [TransportationType] = []) -> String {
    let dateParam = date == "" ? "" : "&date="+date
    let timeParam = time == "" ? "" : "&time="+time
    var transportationsParam = ""
    if transportations.count > 0 {
      for transportation in transportations {
        transportationsParam += "&transportations[]=\(transportation)"
      }
    }
    
    let url = "https://transport.opendata.ch/v1/connections?"+"from=\(from)&to=\(to)\(dateParam)\(timeParam)\(transportationsParam)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    return url
  }
  
  static func connectionsForLocations(from: String, to: String, date: String = "", time: String = "", transportations: [TransportationType] = [], completionHandler: @escaping (Connections?, Error?) -> Void) {
    // set up URLRequest with URL
    let endpoint = TransportAPI.endpointForConnections(from: from, to: to, date: date, time: time, transportations: transportations)
    NSLog("Making request "+endpoint)
    guard let url = URL(string: endpoint) else {
      print("Error: cannot create connections URL")
      let error = BackendError.urlError(reason: "Could not construct URL")
      completionHandler(nil, error)
      return
    }
    let urlRequest = URLRequest(url: url)
    
    // Make request
    let session = URLSession.shared
    let task = session.dataTask(with: urlRequest, completionHandler: {
      (data, response, error) in
      // handle response to request
      // check for error
      guard error == nil else {
        completionHandler(nil, error!)
        return
      }
      // make sure we got data in the response
      guard let responseData = data else {
        print("Error: did not receive data")
        let error = BackendError.objectSerialization(reason: "No data in connections response")
        completionHandler(nil, error)
        return
      }
      
      // parse the result as JSON
      // then create a Connections object from the JSON
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      
      do {
        let connections = try decoder.decode(Connections.self, from: responseData)
        completionHandler(connections, nil)
      } catch {
        print("error trying to convert connections data to JSON")
        print(error)
        completionHandler(nil, error)
      }
      
    })
    task.resume()
  }
  
  
}

// MARK: Object model

struct Locations: Codable {
  var stations: [Location]?
}

struct Coordinates: Codable {
  var type: String?
  var x: Double?
  var y: Double?
}

struct Location: Codable {
  var id: String?
  var type: String?
  var name: String?
  var score: Int?
  var coordinates: Coordinates?
  var distance: Int?
}

struct Connections : Codable {
  var connections: [Connection]?
}

struct Connection : Codable {
  var from: Checkpoint?
  var to: Checkpoint?
  var duration: String?
  var service : Service?
  var products : [String]?
  var capacity1st : Int?
  var capacity2nd : Int?
  var sections : [Section]?
}

struct Checkpoint : Codable {
  var station : Location?
  var arrival : Date?
  var departure : Date?
  var delay : Int?
  var platform : String?
  var prognosis : Prognosis?
}

struct Prognosis : Codable {
  var platform : String?
  var departure : Date?
  var arrival : Date?
  var capacity1st : Int?
  var capacity2nd : Int?
}

struct Service : Codable {
  var regular : String?
  var irregular : String?
}

struct Section : Codable {
  var journey : Journey?
  var walk: Walk?
  var departure: Checkpoint?
  var arrival: Checkpoint?
}

struct Journey : Codable {
  var name : String?
  var category : String?
  var categoryCode : Int?
  var number : String?
  var company : String?
  var to: String?
  var passList: [Checkpoint]?
  var capacity1st: Int?
  var capacity2nd: Int?
  
  enum CodingKeys: String, CodingKey {
    case name
    case category
    case categoryCode
    case number
    case company = "operator" // needed since "operator" is a Swift keyword
  }
}

struct Walk : Codable {
  var duration : Int?
}

