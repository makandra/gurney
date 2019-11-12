##Gurney

Gurney is a small tool to extract dependencies from project files and report them to a web api.
It can either run locally or as a git post-receive hook in gitlab.

When run as a git hook, the project gets cloned on the git server and gurney then looks for a `gurney.yml` within the project files. 
If its present gurney looks at the pushed branches and analyses the ones specified in the config for dependencies. 
It then reports them to the web api also specified in the config.

#### Usage:
```
Usage: gurney [options]
        --api-url [API URL]
                                     Url for web api call, can have parameters for <project_id> and <branch>
                                     example: --api-url "http://example.com/project/<project_id>/branch/<branch>"
        --api-token [API TOKEN]
                                     Token to be send to the api in the X-AuthToken header
    -c, --config [CONFIG FILE]       Config file to use
    -h, --hook                       Run as a git post-receive hook
    -p, --project-id [PROJECT ID]    Specify project id for api
    -t, --tmp-dir [TMP DIR]          Temp dir location for cloning when running as a git hook
        --help
                                     Prints this help
```

#### Sample Config:
```yaml
project_id: 1
branches:
  - master
  - production
api_url: http://example.com/dep_reporter/project/<project_id>/branch/<branch>
api_token: 1234567890
```

##### Running as a global git hook
To run as a global git hook in your gitlab see https://docs.gitlab.com/ee/administration/custom_hooks.html#set-a-global-git-hook-for-all-repositories
