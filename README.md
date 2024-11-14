# Gurney

Gurney is a small tool to extract dependencies from project files and report
them to a web API. Modes:
- normal
- local pre-push hook
- remote post-receive hook
Usually, we configure the latter on our Git server to automatically run on each
push, with the API url passed as command line option.

When run as a post-receive hook, Gurney will make a bare copy of the project and 
look for a gurney.yml file. If present, Gurney looks at the configured branches
and collects their dependencies. These are reported to the web API.

## Usage
```
Usage: gurney [options]
        --api-url [API URL]          Url for web API call, can have parameters for <project_id> and <branch>
                                     Example: --api-url "https://example.com/project/<project_id>/branch/<branch>"
        --api-token [API TOKEN]      Token to be sent to the API in the X-AuthToken header
    -c, --config [CONFIG FILE]       Config file to use
    -h, --hook                       Run as a Git post-receive hook
        --client-hook                Run as a Git pre-push hook
    -p, --project-id [PROJECT ID]    Specify project id for API
        --help                       Print this help
```

## Sample Config
```yaml
project_id: 1
branches:
  - master
  - production
api_url: http://example.com/dep_reporter/project/<project_id>/branch/<branch>
api_token: 1234567890
```

## Running as a global Git hook
See https://docs.gitlab.com/ee/administration/server_hooks.html#create-global-server-hooks-for-all-repositories

## Development
You can run Gurney locally from another directory like this:

```bash
cd some/real/project
ruby -I path/to/gurney/lib path/to/gurney/exe/gurney
```
