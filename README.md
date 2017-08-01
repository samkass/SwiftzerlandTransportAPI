# SwiftzerlandTransportAPI

A Swift 4 Codeable API for the [OpendataCH TransportAPI](https://github.com/OpendataCH/Transport), which offers free REST access to public transportation timetables in Switzerland. Note that I am not affiliated with the TransportAPI library, service, or system; I'm just a user who wanted to use it via Swift.

The Swift interface provided will only work with Swift 4, which corresponds to iOS 11 and watchOS 4. It contains very little error checking, depending on the calling functions to ensure appropriate values for the parameters and passing them straight through to the foundation calls.

## How to install

To use SwiftzerlandTransportAPI, check out the project then drag the folder into your project in XCode. TransportAPI.swift contains all the code and data model.

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
    
An example of using a latitude and longitude is below. This call asks for the next S-Bahn trains to Zürich HB from myLocation (note the "transportations" selector is inoperative in the current TransportAPI service, so for now we will get all transportation types):

    // Note myLocation is a CLLocationCoordinate2D here
    TransportAPI.connectionsForLocations(from: TransportAPI.xyToString(myLocation.latitude, myLocation.longitude),
                                           to: "Zürich HB",
                              transportations: [.s_sn_r],
                            completionHandler:
      { (connections: Connections?, error) in
        // ...
      })
      
## License

Please feel free to use any portion of this code, in whole or in part, in your own project. This project is licensed under the (included) MIT license, which is very permissive, and basically says you can't sue me if anything goes wrong and that if you distribute copies of the whole thing or a "substantial part" of it, you have to also include the MIT copyright notice in it.

