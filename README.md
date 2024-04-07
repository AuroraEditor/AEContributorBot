<p align="center">
  <img alt="Logo" src="https://avatars.githubusercontent.com/u/106490518?s=128&v=4" width="128px;" height="128px;">
</p>

<p align="center">
  <h1 align="center">AuroraEditor Contributors Bot</h1>
</p>

<p align="center">
  <a href='https://twitter.com/Aurora_Editor' target='_blank'>
    <img alt="Twitter Follow" src="https://img.shields.io/twitter/follow/Aurora_Editor?color=f6579d&style=for-the-badge">
  </a>
  <a href='https://discord.gg/5aecJ4rq9D' target='_blank'>
    <img alt="Discord" src="https://img.shields.io/discord/997410333348077620?color=f98a6c&style=for-the-badge">
  </a>
  <a href='https://twitter.com/intent/tweet?text=Try%20this%20new%20open-source%20code%20editor,%20Aurora%20Editor&url=https://auroraeditor.com&via=Aurora_Editor&hashtags=AuroraEditor,editor,AEIDE,developers,Aurora,OSS' target='_blank'><img src='https://img.shields.io/twitter/url/http/shields.io.svg?style=social'></a>
</p>

<br />

> This is the repository for the Aurora Editor Contributors list. 

## Run 

create a config.json file in the root directory with the following contents:

```json
{
    "url": "https://api.github.com/users/AuroraEditor/repos",
    "token": "GITHUB_TOKEN",
    "exclude": [
        "ImgBotApp",
        "aurora-care-bear",
        "github-actions[bot]",
        "dependabot[bot]",
        "allcontributors[bot]",
        "actions-user"
    ]
}
```

> **Note**\
> Change `GITHUB_TOKEN` to your own values.

Run it using:
    
```bash
swift application.swift
```