![](workflows/notat-web-CI/badge.svg)
![](workflows/notat-api-CI/badge.svg)


# Notes app
A simple sticky-note application. It consists of a REST API service (`notat-api`) and a single-page
web-application (`notat-web`). The `notat-api` service has an in-memory store, so don't expect much,
and please don't attempt to scale it with multiple instances.


## Step 1: Fork it
The first step is to fork this GitHub Repository into your own space. When you've forked it you're 
welcome to clone it to your computer and follow the rest of the instructions by performing the changes 
locally and pushing them to GitHub, but it isn't necessary as all the instructions assumes that you
work from the website.

## Step 2: Setup CI
As with most DevOps oriented projects, we need some CI workflows/pipelines/jobs. Writing such pipelines
for a CI framework you haven't used before is always a big hassle, so don't worry - we've got you covered.
In your forked repository you'll find a branch named `add-ci-workflows` where we've prepared the GitHub
Actions workflows for you. You only need to do some small modifications.

### GitHub API token
The CI workflows we've set up requires a Personal Access Token with access to the GitHub API with 
repository and package scopes. The workflows use this token to publish container images (on your behalf)
to your package registry. We'll need the container images later when we setup deployment to kubernetes.

First go to your personal GitHub [token settings](https://github.com/settings/tokens) and click on 
`Generate new token`. Give it a sensible name, e.g. notes-app-ci, and make sure to check `write:packages`
(which will automatically select some other scopes for you as well). Click on the `Generate token` button
on the bottom of the page and then you should see your new token. Copy it.

Then go back to your repository and navigate to the `Settings` tab, and again to the `Secrets` view. Click
on `New secret`, name it `CR_PAT`, paste the token you copied into the value input and add the secret.

### Adapt the workflows
Before we merge the workflow declarations to the master branch of your repository we'll need to adapt
the workflows so that they will work for your fork of notes-app. Navigate back to the `Code` tab of
your repository and switch to the `add-ci-workflows` branch. You should now see a directory in the
`.github/workflows` directory, so navigate to it. We need to edit both `notat-api-ci.yaml` and 
`notat-web-ci.yaml`, so do the following for both files. 

1. Navigate to the file, i.e click on it.
1. Click on edit (the pencil in the top-right corner of the file view).
1. Replace all `<github username>` with your GitHub username.
1. Save and commit the change.

As a side-note, in each of the files you can find a reference to the secret we added earlier:
`password: ${{ secrets.CR_PAT }}`. 

### Merge the workflows
To add the workflows so that GitHub Actions executes them when changes are made to either of the
applications (notat-api or notat-web), we must create a pull-request and merge it. Navigate to the
`Pull requests` tab and click on `New pull request`. GitHub will automatically assume that you want to merge
your branch into the repository you forked, but we actually want to merge the `add-ci-workflows`-branch to our
own master-branch. To change that click on `base repository: cx-devops-101/notes-app` and select 
`<username>/notes-app`. The view should change entirely and you should see a list of branches, select `add-ci-workflows`.
Create the pull-request, review the changes (i.e. make sure that you replaced `<github username>`) and merge it.

### Trigger the workflows
Now that you've merged the workflow declarations into your master branch, you should see them in the `Actions` tab.
Navigate to the `Actions` tab and verify that you can see `notat-web-CI` and `notat-api-CI` in the workflows list.
So how do we trigger them? If you studied the workflow declarations you might have noticed the `on` declaration:

```
## file: .github/workflows/notat-api-ci.yaml
on:
  push:
    branches: [ master ]
    paths: 
      - 'notat-api/**'

  pull_request:
    branches: [ master ]
    paths: 
      - 'notat-api/**'
```

With these two declarations, `push` and `pull_requests`, we have declared that the jobs in the workflow `notat-api-CI` should 
only be executed when either of the following apply:
1. There is a new commit to the `master`-branch and any file in the path `notat-api/` has changes.
1. There is a pull-request from a branch to the `master`-branch and there are changes to any files in the path `notat-api/`.

Let's make a change to a file in the `notat-api` application and see if we can trigger the workflow:
1. Navigate to `notat-api/src/main/kotlin/com/computas/devops101/notatapi/HealthController.kt` and edit it.
1. Change `Healthy` to `Not healthy`.
1. Scroll down to `Commit changes`.
1. Do not commit directly to the `master` branch, but rather select `Create a new branch for this commit and start a pull request`.
1. Create the pull request.
1. Wait a few seconds and you should see that the workflow has been triggered.

The workflow that we triggered is executed because (2) from the `on`-declaration applies in this case. It will verify that our
changes does not break anything by compiling the code, running tests and building the container image. Note that the difference
between executions where (1) and (2) apply is the `push: ${{github.ref == 'refs/heads/master'}}` which will evaluate to false when 
executed for pull-requests.

What happened? The job failed right? The reason? Well, we broke a unit test with our change and we might also have broken other 
the expecation other applications has about the API. The API specification in our case states that valid answers for that endpoint
is `Ok` or `Healthy`. We still want to make a change so that we will trigger a build so, let's change it to `Ok` instead.

1. Navigate to the `Code` tab.
1. Switch to the branch you created for the pull-request, e.g. `<username>-patch-1`
1. Navigate to `notat-api/src/main/kotlin/com/computas/devops101/notatapi/HealthController.kt` and edit it.
1. Change `Not healthy` to `Ok`.
1. Scroll down to `Commit changes`
1. This time we want to commit directly to the `<username>-patch-1` branch.
1. Commit.

And voilà, the workflow should be successful and we can go ahead and merge the pull-request. This will trigger the `notat-api-CI`
workflow for the master branch, which will push the container image to your GitHub package registry. When the workflow is successful
you can verify this by going to your GitHub profile page and navigate to the `Packages` tab, where you should find the 
`notes-app/notat-api` container. We also have to change the visibility of the container from private to public.

1. Click on the `notes-app/notat-api` container.
1. Click on `Package Settings`.
1. Scroll down to the `Danger Zone` and click on `Make public`.
1. If you have docker on your computer you can verify that it is public if you want to:
  - `docker run --rm -it ghcr.io/mapster/notes-app/notat-api`

Let's trigger the `notat-web-CI` workflow as well, but this time we'll skip the failing test step.

1. Navigate to the master branch and the file `notat-web/index.html`, and edit it.
1. Add a new-line at the end of the file.
1. Do not commit directly to the `master` branch, but rather select `Create a new branch for this commit and start a pull request`.
1. Create the pull request
1. Wait a few seconds and you should see that the workflow has been triggered.

The workflow should execute successfully, and when it is you can safly approve and merge the pull-request. Which, again, should
trigger the workflow, and when it's successful we should find the container in the `Packages` list. Go ahead and change the 
visibility to public for it as well. And similarily, if you want to, you can verify that it is public with docker locally:
`docker run --rm -it ghcr.io/mapster/notes-app/notat-web`.

## Step 3: Deploy to the cluster
