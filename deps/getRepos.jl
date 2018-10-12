using GitHub

using JSON
using Dates

const githubDate = dateformat"Y-m-dTH:M:S"
function get_github_repos(username::String = "jgoldfar")
    try
        repoVec = first(repos(username)) # First element is repository vector
        return Dict(repo.name => (repo.language, repo.description, repo.html_url.uri, repo.updated_at) for repo in repoVec)
    catch e
        @show e
        return nothing
    end
end

const bitbucketDate = dateformat"Y-m-dTH:M:S.s"
function get_bitbucket_repos(username::String = "jgoldfar")
    try
        repos = Dict{String, Any}()
        tmp = JSON.parse(readchomp(`curl "https://api.bitbucket.org/2.0/repositories/$(username)"`))
        while (length(tmp["values"]) > 0) && haskey(tmp, "next")
            for v in tmp["values"]
                # tmp["values"] is equivalent to first(repos(username)) above.
                if v isa Dict{String, Any} && (v["type"] == "repository") && (v["is_private"] == false)
                    dt = v["updated_on"][1:end-13]
                    repos[v["name"]] = (v["language"], v["description"], v["links"]["html"]["href"], DateTime(dt, bitbucketDate))
                end
            end
            tmp = JSON.parse(readchomp(`curl $(tmp["next"])`))
        end
        return repos
    catch e
        @show e
        return nothing
    end
end

function update_repoListing(filename::String, repoData)
    open(filename, "w") do st
        JSON.print(st, repoData, 2)
    end
    return nothing
end

# Ingest repository data in `filename`; comes in "internal" format
function ingest_repoListing(filename::String)
    JSON.parsefile(filename)
end

# Convert all output from github API into our internal, annotated format
function githubFormat_to_internal(repoData)
    [_to_internal(k, v) for (k, v) in repoData]
end

# Internal, annotated format
_to_internal(k, v) = Dict(
        "name" => k,
        "language" => v[1],
        "description" => v[2],
        "url" => v[3],
        "updated" => (length(v) > 3 ? v[4] : Dates.now()),
        "showOSSListing" => true,
        "showReadme" => true,
        "showLocalPage" => "",
        "weight" => 0)

function internal_to_githubFormat(repoJsonData)
    Dict(v["name"] => (v["language"], v["description"], v["url"], v["updated"]) for v in repoJsonData)
end

# Just grab vector of project names
internal_to_name_vector(repoJsonData) = [v["name"] for v in repoJsonData]

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
    newData = if "--github" in ARGS
        newData = get_github_repos()
    elseif "--bitbucket" in ARGS
        newData = get_bitbucket_repos()
    else
        usage()
        return 0
    end
    
    if (newData == nothing)
        println(stderr, "Failed to download repository information.")
        return -1
    end
    
    if !isfile(jsonDataFile)
        println(stderr, "Creating new repository data file $(jsonDataFile)")
        update_repoListing(jsonDataFile, githubFormat_to_internal(newData))
        return 0
    end
    
    println(stderr, "Updating repository data file $(jsonDataFile)")
    existingData = ingest_repoListing(jsonDataFile)
    
    ## To test: comment out null check for newData, and uncomment the next 3 lines
    # newData = internal_to_githubFormat(existingData)
    # pop!(existingData)
    # pop!(existingData)

    existingDataKeys = internal_to_name_vector(existingData)
    
    for (k, v) in newData
        if !(k in existingDataKeys)
            println(stderr, "Found new repository: $(k)")
            push!(existingData, _to_internal(k, v))
        end
    end
    
    update_repoListing(jsonDataFile, existingData)
end
main()
