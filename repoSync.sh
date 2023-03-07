#!/bin/bash

set -euo pipefail


# Being at midstream repo sync updates from upstream repo(from master branch) in branch named "syncBranch" 

# master      myChanges       syncBranch
# checkout to master branch and git push changes.
# checkout to syncBranch branch of midstream repo.
# git fetch from origin master and git merge that changes
# git fetch from upstream master and git merge the changes and look into cases of merge conflict.

repoSyncing() {
    local target_upstream_branch=$1
    local syncBranch=$2
    echo "----------------Syncing process started--------------------------------------------"

    # Cheking if working tree clean!
    local branch=$(git rev-parse --abbrev-ref HEAD)
    echo "--Current working branch = $branch"
    echo "--Cheking if there is nothing to commit"
    unstaged_num_files=$(git status --porcelain  | { egrep '^\s?[?]' || true; } | wc -l)
    staged_num_files=$(git status --porcelain  | { egrep '^\s?[MADRC]' || true; } | wc -l)
    if ((unstaged_num_files>0 || staged_num_files>0)); then
        if ((staged_num_files>0 && unstaged_num_files > 0)); then
            echo "--$unstaged_num_files Unstaged and $staged_num_files Staged files found, Cleaning working tree to proceed!"
        elif ((unstaged_num_files == 0 && staged_num_files>0)); then
            echo "--$staged_num_files Staged files found, Cleaning working tree to proceed!"
        elif ((unstaged_num_files > 0 && staged_num_files==0)); then
            echo "--$unstaged_num_files Unstaged files found, Cleaning working tree to proceed!"
        fi
        git add .
        echo "--Commiting and pushing all changes made, with DCO sign"
        git commit -s -m "commiting all changes b4 starting sync process"
        git push -u origin ${branch}
    else
        echo "----Working tree clean!----"
    fi

    echo "----switching to master branch----"
    git checkout master
    echo "--Branches List"
    git branch
    echo "----switching to sync branch----"
    git checkout ${syncBranch}
    echo "--fetching + merging changes from ORIGIN master"
    git fetch origin master
    git merge origin/master
    echo "--fetching + merging changes from UPSTREAM master"
    git fetch upstream ${target_upstream_branch}
    git merge --strategy-option=ours upstream/${target_upstream_branch}
    echo "--Logging recent details for you."
    git log --oneline --max-count=10
    git push -u origin ${syncBranch}
    
    echo "---------------Process End------------------------------------------"
}

show_help() {
    echo ""
    echo "Usage: ./repoSync [sync branch] [target branc]"
    echo ""
    echo "sync branch     branch in where you want to sync upstream"
    echo "target branch   upstream branch from where you wanna pick up sync"
    echo ""
}


main() {
    if [ $# -lt 1 ]; then
        echo "Use as: $0 [sync Branch] [target Branch]"
        echo "pass -h|--help for in detail description"
        exit 1
    fi

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -h|--help) show_help; exit 0;;
            *)
                target_upstream_branch=$1
                syncBranch=$2
                repoSyncing ${syncBranch} ${target_upstream_branch}
        esac
        shift
    done
}

main $*