# SwiftzerlandTransportAPI

The [SwiftzerlandTransportAPI](https://github.com/samkass/SwiftzerlandTransportAPI) is a Swift 4 Codeable API for the [OpendataCH TransportAPI](https://github.com/OpendataCH/Transport), which offers free REST access to public transportation timetables in Switzerland. Note that I am not affiliated with the TransportAPI library, service, or system; I'm just a user of theirs who wanted to use it via Swift, and thought others might also find the Swift Codable implementation handy.

The Swift interface provided will only work with Swift 4, which corresponds to iOS 11 and watchOS 4. It contains little error checking, depending on the calling functions to ensure appropriate values for the parameters and passing them straight through to the foundation calls.

Please report any problems as an issue to this project on GitHub.

## How to install

To use SwiftzerlandTransportAPI, check out the project then drag the folder into your project in XCode. TransportAPI.swift contains all the code and data model.

## How to call

To get a list of transportation options from the API, call TransportAPI.connectionsForLocations.

    TransportAPI.connectionsForLocations(from: "Zürich HB",
                                           to: "Oberrieden",
                            completionHandler:
      { (connections, error) in
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
      })
    
An example of using a latitude and longitude is below. The TransportAPI.swift file extends String with a xyToString function. This call asks for the next S-Bahn trains to Zürich HB from myLocation (note the "transportations" selector is inoperative in the current TransportAPI service, so for now we will get all transportation types):

    // Note myLocation is a CLLocationCoordinate2D here
    TransportAPI.connectionsForLocations(from: .xyToString(myLocation.latitude, myLocation.longitude),
                                           to: "Zürich HB",
                              transportations: [.s_sn_r],
                            completionHandler:
      { (connections: Connections?, error) in
        // ...
      })
      
For a list of locations for a query, use TranportAPI.locationsForQuery. The below code finds nearby points of interest to me:

    TransportAPI.locationsForQuery(.xyToString(myLocation.latitude, myLocation.longitude),
                                   type: .poi,
                                   completionHandler:
      { (connections: Locations?, error) in
        // ...
      })
      
The completion will either have a value connections/locations object, or a valid error. If the error is nil, the object will be present. Once you have the objects, they can be treated just like any other Swift object. Currently all fields are optionals, so will need to be guarded when accessed.
      
## License

Please feel free to use any portion of this code, in whole or in part, in your own project. This project is licensed under the (included) MIT license, which is very permissive, and basically says you can't sue me if anything goes wrong and that if you distribute copies of the whole thing or a "substantial part" of it, you have to also include the MIT copyright notice in it.

