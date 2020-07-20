#!/bin/bash


on_pull_request_close_del_branch_if_need() {
  PR_ACTION=$(jq -r .action < "${GITHUB_EVENT_PATH}")
  if [[ "${PR_ACTION}" != "closed" ]];then
    return 0
  fi

  PR_HEAD_REF=$(jq -r .pull_request.head.ref < "${GITHUB_EVENT_PATH}")

  if [[ ! "${PR_HEAD_REF}" =~ 'pr_' ]];then
    echo "Not a valid pull request branch, exit"
    return 0
  fi

  PR_HEAD_BRANCH_URL=$(jq -r .pull_request.head.repo.git_refs_url < "${GITHUB_EVENT_PATH}" |sed "s@{.*}@/heads/$PR_HEAD_REF@g")

  curl \
        --fail \
        -X DELETE \
        -H 'Content-Type: application/json' \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        "${PR_HEAD_BRANCH_URL}"
}


on_pull_request_open_edit_auto_label_it() {
  PR_ACTION=$(jq -r .action < "${GITHUB_EVENT_PATH}")
  if [[ "${PR_ACTION}" != "edited" && "${PR_ACTION}" != "opened" ]];then
    return 0
  fi
  PR_TITLE=$(jq -r .pull_request.title < "${GITHUB_EVENT_PATH}")
  PR_ISSUE_URL=$(jq -r .pull_request.issue_url < "${GITHUB_EVENT_PATH}")

  label=""

  if [[ "${PR_TITLE}" =~ "fix" ]];then
    label="fix"
  elif [[ "${PR_TITLE}" =~ "feat" ]];then
    label="新功能"
  elif [[ "${PR_TITLE}" =~ "perf" || ${PR_TITLE} =~ "refactor" ]];then
    label="优化"
  elif [[ "${PR_TITLE}" =~ "ci" ]];then
    label="无需处理"
  fi
  if [[ -z "${label}" ]];then
    return 0
  fi

  data='{"labels":["'"${label}"'"]}'

  curl \
        --fail \
        -X PATCH \
        --data ${data} \
        -H 'Content-Type: application/json' \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        "${PR_ISSUE_URL}"
}


if [[ "${GITHUB_EVENT_NAME}" != "pull_request" ]];then
  exit 0
fi

on_pull_request_close_del_branch_if_need
on_pull_request_open_edit_auto_label_it