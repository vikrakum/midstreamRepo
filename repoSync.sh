#!/bin/bash

set -euxo pipefail


# Being at midstream repo sync updates from upstream repo(from master branch) in branch named "syncBranch" 

# master      myChanges       syncBranch
# checkout to master branch and git push changes.
# checkout to syncBranch branch of midstream repo.
# git fetch from origin master and git merge that changes
# git fetch from upstream master and git merge the changes and look into cases of merge conflict.

repoSyncing() {
    echo "----------------Syncing process started--------------------------------------------"

    # Cheking if working tree clean!
    local branch=$(git rev-parse --abbrev-ref HEAD)
    echo "Current working branch = $branch"
    echo "Cheking if there is nothing to commit"
    unstaged_num_files=$(git status --porcelain  | { egrep '^\s?[?]' || true; } | wc -l)
    staged_num_files=$(git status --porcelain  | { egrep '^\s?[MADRC]' || true; } | wc -l)
    if ((unstaged_num_files>0 || staged_num_files>0)); then
        if ((staged_num_files>0 && unstaged_num_files > 0)); then
            echo "$unstaged_num_files Unstaged and $staged_num_files Staged files found, Cleaning working tree to proceed!"
        elif ((unstaged_num_files == 0 && staged_num_files>0)); then
            echo "$staged_num_files Staged files found, Cleaning working tree to proceed!"
        elif ((unstaged_num_files > 0 && staged_num_files==0)); then
            echo "$unstaged_num_files Unstaged files found, Cleaning working tree to proceed!"
        fi
        git add .
        echo "Enter commit message"
        read message
        echo "Commiting and pushing all changes made, with DCO sign"
        git commit -s -m "$message"
        git push -u origin ${branch}
    else
        echo "----Working tree clean!----"
    fi

    echo "----switching to master branch----"
    git checkout master
    echo "Branches List"
    git branch
    echo "Enter sync branch name"
    read syncBranch
    echo "----switching to sync branch----"
    git checkout ${syncBranch}
    echo "fetching + merging changes from ORIGIN master"
    git fetch origin master
    git merge origin/master
    echo "fetching + merging changes from UPSTREAM master"
    git fetch upstream master
    git rebase upstream/master
    echo "Logging recent details for you."
    git log --oneline
    git push -u origin ${syncBranch}
    
    echo "---------------Process End------------------------------------------"
}

main() {
    repoSyncing
    exit 0
}

main $*