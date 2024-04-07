import Foundation

#if canImport(FoundationNetworking)
// Support network calls in Linux.
import FoundationNetworking
#endif

/// Define the Contributor structure.
///
/// This structure will hold the information about the contributors.
/// 
/// Note: This is a class because of the need to update the contributions.
/// 
/// - Parameters:
///   - login: The GitHub login of the contributor.
///   - avatar_url: The URL of the avatar of the contributor.
///   - contributions: The number of contributions of the contributor.
class Contributor: Codable {
    let login: String
    let avatar_url: String
    let html_url: String
    var contributions: Int

    init(login: String, avatar_url: String, html_url: String, contributions: Int) {
        self.login = login
        self.avatar_url = avatar_url
        self.html_url = html_url
        self.contributions = contributions
    }
}

struct Configuration: Codable {
    let url: String
    let token: String
    let exclude: [String]
}

struct GitHubRepo: Codable {
    let name: String
    let contributors_url: String
}

// Fail if the config file doesn't exist.
if !FileManager.default.fileExists(atPath: "config.json") {
    print("Config file not found.")
    exit(1)
}

// Load the configuration.
let configuration = try JSONDecoder().decode(
    Configuration.self,
    from: Data(contentsOf: URL(fileURLWithPath: "config.json"))
)

var contributors: [Contributor] = []

// Load the data from GitHub.
if let githubData: [GitHubRepo] = fetchData(url: configuration.url) {

    // Walk through the repos.
    for repo in githubData {
        // Parse the repo.
        print("Parsing \(repo.name)")
        parseRepo(repo: repo)
    }
} else {
    print("Unable to parse the data from \(configuration.url)")
}

func parseRepo(repo: GitHubRepo) {
    // Get the contributors.

    guard let contributorsInRepo: [Contributor]? = fetchData(
        url: repo.contributors_url + "?per_page=500"
    ) else {
        print("Unable to parse the data from \(repo.contributors_url)")
        return
    }

    // Walk through the contributors.
    for contributor in contributorsInRepo ?? [] 
        where configuration.exclude.contains(contributor.login) == false {
        // Check if the contributor is already in the list.
        if let selectedContributor = contributors.first(where: {
            $0.login == contributor.login
        }) {
            // Update the contributions.
            selectedContributor.contributions += contributor.contributions
        } else {
            // Add the contributor.
            contributors.append(.init(
                login: contributor.login,
                avatar_url: contributor.avatar_url,
                html_url: contributor.html_url,
                contributions: contributor.contributions
            ))
        }
    }
}


print("Contributors:")
dump(contributors)

// Encode the contributors to JSON.
if let jsonData = try? JSONEncoder().encode(contributors) {
    // Write the data to a file.
    try? jsonData.write(to: URL(fileURLWithPath: "contributors.json"))
}

// WARNING: BAD PRACTICE, I'M FORCING THE PROGRAM TO WAIT FOR THE DATA.
func fetchData<T: Codable>(url fromURL: String) -> T? {
    guard let url = URL(string: fromURL) else {
        print("Invalid URL")
        return nil
    }

    var wait = true
    var data: Data?

    var request = URLRequest(url: url)
    request.setValue("en", forHTTPHeaderField: "Accept-language")
    request.setValue("Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us)", forHTTPHeaderField: "User-Agent")

    if configuration.token != "" {
        request.setValue("Bearer \(configuration.token)", forHTTPHeaderField: "Authorization")
    }

    request.httpMethod = "GET"

    let task = URLSession.shared.dataTask(with: request) { ddata, response, error in
        guard
            let ddata = ddata,
            let response = response as? HTTPURLResponse,
            error == nil
        else {
            print("HTTP ERROR")
            print(error!.localizedDescription)
            wait = false
            return
        }

        guard (200 ... 299) ~= response.statusCode else {
            print("statusCode should be 2xx, but is \(response.statusCode)")
            print("response = \(response)")
            wait = false
            return
        }

        data = ddata
        wait = false
    }

    task.resume()

    while (wait) { }

    do {
        let json = try JSONDecoder().decode(
            T.self,
            from: data!
        )

        return json
    } catch {
        print(error)
    }

    return nil
}

// Tell the OS that the program exited successfully.
exit(0)
