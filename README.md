# JumpServer 项目的一些通用功能

- 当 push 了一个分支名称为 pr_${TO_BRANCH}_other 时自动向 ${TO_BRANCH} 发起 pull request
- 当 pull request 创建时，如果 pull request title 中包含 fix, feat, perf时自动会为该PR打标签
- 当 pull request 关闭时，如果分支名称是 pr_.* 会自动删除该分支


## Inputs

无

## Example usage

```yaml
on: [push, pull_request, release]

name: JumpServer generic action handler

jobs:
  generic_handler:
    name: Generic handler for JumpServer Repos
    runs-on: ubuntu-latest
    steps:
      - name: Add labels
        uses: jumpserver/action-generic-handler@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
