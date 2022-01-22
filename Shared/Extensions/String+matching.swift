import Foundation

extension String {
    
    // function that can easily perfom regex and grab groups
    func matching(regexPattern: String) -> [[String]]? {
        
        // attempt to create an NSRegular expression object
        guard let regex = try? NSRegularExpression(pattern: regexPattern) else { return nil }
        
        // grab all matches
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        
        // create empty two dimensional array
        var results: [[String]] = []
        
        // loop through matches and grab all captured groups
        for match in matches {
            var result: [String] = []
            
            // figure out how many ranges exist and subtract it by one
            let lastRange = match.numberOfRanges-1
            
            // loop through every range
            for i in 0...lastRange {
                // attempt to grab a group
                guard let groupRange = Range(match.range(at: i), in: self) else { continue }
                
                // add group to array
                result.append(String(self[groupRange]))
            }
            
            // add stored groups to 2 dimensional array
            results.append(result)
        }
        
        // return all matches
        return results
    }
}

// the commented code below demonstrates how groups can be extracted easily
/* let TV_EPISODE = "S01 - E02"

if let episodeData = TV_EPISODE.matching(regexPattern: "^S(\\d{2})\\s-\\sE(\\d{2})") {
    for episode in episodeData {
        for group in episode {
            print(group)
        }
    }
} */

/* below code shows example of grabbing data manually, to easily conform to the LosslessStringConvertible protocol.

code is based on demonstration found at the address below on October 23, 2019: 

https://medium.com/@dennisvennink/all-about-losslessstringconvertible-d67ff52986d8
*/

/* struct Person: LosslessStringConvertible {
    let NAME: String
    var age: Int
    var description: String {
        return "Person(name: \(NAME), age: \(age))"
    }
    
    init(name: String, age: Int) {
        NAME = name
        self.age = age
    }
    
    init?(_ description: String) {
        
        // use added function to do regex matching and retrieve age
        guard let personString = description.matching(regexPattern: "^Person\\(name:\\s(\\w*),\\sage:\\s(\\d*)\\)$"), let age = Int(personString[0][2]) else { return nil }
        
        // retrieve name
        let name = personString[0][1]
        
        // initialize object
        self.init(name: name, age: age)
    }
}

let SAM = Person(name: "Sam", age: 50)

let SAM_STRING = SAM.description

print(SAM)

if let person = Person(SAM_STRING) {
    print(person)
} */