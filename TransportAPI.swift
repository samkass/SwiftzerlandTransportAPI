//
//  TransportAPI.swift
//  StopCHop
//
//  Created by Sam Kass on 7/2/17.
//  Copyright © 2017 Aardustry LLC. All rights reserved.
//

import Foundation

enum BackendError: Error {
  case urlError(reason: String)
  case objectSerialization(reason: String)
}

class TransportAPI {
  enum QueryType {case all, station, poi, address }
  enum TransportationType {case ice_tgv_rj, ec_ic, ir, re_d, ship, s_sn_r, bus, cableway, arz_ext, tramway_underground }
  
  // MARK: Locations query
  
  static func endpointForLocationQuery(_ query: String, type: QueryType = .all) -> String {
    return "https://transport-beta.opendata.ch/v1/locations?"+"query=\(query)&type=\(type)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
  }
  
  static func endpointForLocationXY(_ x: Float, _ y: Float) -> String {
    return "https://transport-beta.opendata.ch/v1/locations?"+"x=\(x)&y=\(y)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
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
      // then create a Todo from the JSON
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
  
  static func xyToString(_ x : Double, _ y : Double) -> String {
    return "\(x),\(y)"
  }
  
  static func endpointForConnections(from: String, to: String, date: String = "", time: String = "", transportations: [TransportationType] = []) -> String {
    let dateParam = date == "" ? "" : "&date="+date
    let timeParam = time == "" ? "" : "&time="+time
    var transportationsParam = ""
    if transportations.count > 0 {
      for transportation in transportations {
        transportationsParam += "&transportations[]=\(transportation)"
      }
    }
    
    let url = "https://transport-beta.opendata.ch/v1/connections?"+"from=\(from)&to=\(to)\(dateParam)\(timeParam)\(transportationsParam)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
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
      // then create a Todo from the JSON
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
    case company = "operator"
  }
}

struct Walk : Codable {
  var duration : Int?
}

