# SwiftzerlandTransportAPI
A Swift 4 Codeable API for the [OpendataCH TransportAPI](https://github.com/OpendataCH/Transport), which offers free REST access to public transportation timetables in Switzerland.

The Swift interface provided will ony work with Swift 4. It contains very little error checking, depending on the calling functions to ensure appropriate values for the parameters and passing them straight through to the foundation calls.

## How to call

To call the API, call TransportAPI.connectionsForLocations. If you have a lat/lon location, pass in TransportAPI.xyToString into one of the arguments. For a list of locations based on an arbitrary query, use TranportAPI.locationsForQuery.

    TransportAPI.connectionsForLocations(from: "Zürich HB", to: "Oberrieden", completionHandler: { (connections, error) in
      if let error = error {
        // got an error in getting the data, need to handle it
        print(error)
        return
      }
      guard let connections = connections else {
        print("error getting location: result is nil")
        return
      }
      // success :)
      print(connections.connections?.last)
    }
