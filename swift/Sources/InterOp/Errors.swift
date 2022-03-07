import Foundation

enum Errors : Error, Equatable {
    case badHeader(header: String),
         alreadyClosed,
         alreadyRunning,
         eventHasID,
         unrecognisedType,
         expectedSingleByte,
         malformedMessage(details: String)
}
