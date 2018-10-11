using GitHub

using JSON

function get_github_repos(username::String = "jgoldfar")
    repoVec = first(repos(username)) # First element is repository vector
    Dict(repo.name => (repo.language, repo.description, repo.html_url.uri) for repo in repoVec)
end

function init_repoListing(filename::String, repoData)
    outputData = (Dict(
                    "name" => k,
                    "language" => v[1],
                    "description" => v[2],
                    "url" => v[3],
                    "showOSSListing" => true,
                    "showReadme" => true,
                    "showLocalPage" => "") for (k, v) in repoData
                    )
#     open(filename, "w") do st
    JSON.print(outputData, 2)
#     end
    return nothing
end

function ingest_repoListing(filename::String)
    JSON.parsefile(filename)
end

function usage()
    println(
    "usage: julia $(basename(@__FILE__)) json-data-file [--github|--bitbucket]\n",
    "\t Read repositories from the given service, and update the given JSON file with\n",
    "\t any new repositories; old information should not be touched.\n",
    "\t if --github is given, read from Github, or if --bitbucket is given, read from Bitbucket."
    )
end

function main(args=ARGS)
    if isempty(ARGS)
        usage()
        return 0
    end
    jsonDataFile = first(ARGS)
    if "--github" in ARGS
        newData = get_github_repos()
    elseif "--bitbucket" in ARGS
        newData = get_bitbucket_repos()
    else
        usage()
        return 0
    end
    if !isfile(jsonDataFile)
        println(stderr, "Creating new repository data file $(jsonDataFile)")
        init_repoListing(jsonDataFile, newData)
        return 0
    end
    
    println(stderr, "Updating repository data file $(jsonDataFile)")
    existingData = ingest_repoListing(jsonDataFile)
#     newData = get_all_repos()
end
main()