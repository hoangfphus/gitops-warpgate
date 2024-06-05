# Warpgate Terraform

<!-- ![banner]() -->

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

This is a repo GitOps [Warpgate](https://github.com/warp-tech/warpgate) using Terraform.

Using [terraform-provider-warpgate](https://github.com/hoangfphus/terraform-provider-warpgate) which forked from [andreee94/terraform-provider-warpgate](https://github.com/andreee94/terraform-provider-warpgate).

## Disclaimer
This repo follow `Apache-2.0 license` as [Warpgate](https://github.com/warp-tech/warpgate).
If there is any issue with this, please contact `nguyenhoangphu8936@gmail.com`.

## Table of Contents
- [Background](#background)
- [Install wg](#install)
- [Usage](#usage)
- [Known Issues](#known-issue)

## Background
- For replace [Teleport](https://goteleport.com/) and SSO purpose.
- This is using only feature HTTP, not `MySQL` or `SSH`.

## Install
> DO NOT USING LASTEST TAGS

Current version: `0.9.1`

docker-compose.yml
```yaml
version: '3'
services:
  warpgate:
    image: ghcr.io/warp-tech/warpgate:{version}
    ports:
      #- 2222:2222
      - 443:8888
      #- 33306:33306
    volumes:
      - ./wg-data:/data  
    stdin_open: true
    tty: true
```
`docker compose run warpgate setup` -> must run this one before `docker compose up -d`

over-write warpgate.yml data below ( sample, need to custom)

<details>
  <summary>data/warpgate.yaml</summary>

```yaml
---
sso_providers:
- name: keycloak #this one set in data/users, not label
  label: Example-SSO # show
  provider:
    type: custom #must have ( check in in document of WarpGate)
    client_id: warp-gate # get from keycloak
    client_secret: abcxyz # from keycloak
    issuer_url: https://keycloak.example.vn/realms/example #
    scopes: ['email'] # check for scope email only
- name: custom-v2
  label: gitlab
  provider:
    type: custom
    client_id: zxcvbnm # get from gitlab
    client_secret: asdzxcn # get from gitlab
    issuer_url: https://gitlab.example.vn
    scopes: ['email']
recordings:
  enable: true
  path: /data/recordings
external_host: domain|ip:port # replace 
database_url: "sqlite:/data/db"
ssh:
  enable: false # disable due to not using this feature
  listen: "0.0.0.0:2222"
  keys: /data/ssh-keys
  host_key_verification: prompt
http:
  enable: true
  listen: "0.0.0.0:8888"
  certificate: /data/wg.cert.pem #key letencrypt
  key: /data/wg.key.pem #key letencrypt
  trust_x_forwarded_headers: false
  session_max_age: 300m # session login last for 5hours
  cookie_max_age: 300m # same for cookie
mysql:
  enable: false # disable due to not using this feature
  listen: "0.0.0.0:33306"
  certificate: /data/tls.certificate.pem
  key: /data/tls.key.pem
log:
  retention: 7days
  send_to: ~     #to do: push log to wazuh to analyze and set active-respone to anti brute-force
config_provider: database
```

</details>

`docker compose up -d`


Ref: [warpgate-docker](https://github.com/warp-tech/warpgate/wiki/Getting-started-on-Docker)



## Usage
### Add role
- add `- role_name` in data/roles
### Add a host
- add as sample below to data/http_targets
  ```yaml
  - name: internal-tool
    options:
      url: 'https://internal-tool.example.vn' # url internal or external
      tls:
        mode: "Preferred" # 3 mode: Disabled | Preferered | Required
        verify: "false" # force validate ssl
    allow_access: # allow role for that host, do not add allow_access role if role not existed in data/roles
      - noc
      - fe
      - sre
  ```

### Add user
- add as sample below to data/users
  ```yaml
  - username: hoangfphus
    credentials:
      kind: Sso                # as default, user must have in keycloak that could login, currently not support password | kind must be `Sso` 
      provider: keycloak       # as default, if want to using another provider not keycloak, config in wg-data/config.yaml
      email: hoangfphus@example.vn # important: this one for checking in keycloak
    roles:
      - sre                   # sre could access all value as wanted
      - bigdata
  ```

### How to run
- commit to master branch.
- check stage `plan` if not conflict then manual trigger apply.

## Config in gitlab variables
- backend store terraform state .
- file `BE_TF_S3` and `KEYTFVARS` is only for example config self-hosted s3. should store it in Environment Variable.
- `KEYTFVARS` for admin connect.



# Known-issue
Currently, button redirect not working as wanted.

User have to copy and paste domain if they want to working multi http_target.