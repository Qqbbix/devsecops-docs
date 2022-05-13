# Local Development Preparation

## Prepare Git Repository

* You have to config git user and email data for first time uses

```bash
git config --global user.name "training[X]"
git config --global user.email "training[X]@opsta.net"
git config --global init.defaultBranch "main"
git config --global pull.rebase false
# See your git config
git config --list
```

* Initial ratings service repository by putting the following commands

```bash
mkdir ratings
cd ratings
# Initial git repository
git init
```

* Click on `pencils icon` on the top right to open text editor
* Right click on ratings folder and `New File` to create `README.md` file and put below text

````markdown
# Bookinfo Rating Service

Rating service has been developed on NodeJS

## License

Apache-2.0 license

## Prerequisite

* Node 14+

## How to run ratings service

```bash
npm install
node ratings.js 8080
```
````

## Practice Markdown

* <https://www.markdowntutorial.com>

## First Git Commit

* Put command `git status` to see repository status
* Put commands below for first commit

```bash
git add README.md
git status
git commit -m "Initial commit"
git status
```

## Push Repository to GitLab

### Add your SSH Public Key to GitLab

* On Cloud Shell

```bash
cat ~/.ssh/id_rsa.pub
# Copy your public key
```

> You can copy text on Cloud Shell by just drag on text your want to copy and it will copy to your clipboard automatically

* Go to <https://git.demo.opsta.co.th> and login with your credential
* Go to <https://git.demo.opsta.co.th/-/profile/keys> or menu `Preferences` on your avatar icon on the top right and choose menu `SSH Keys` on the left
* Put your public key on the `Key` textbox and click `Add key`

### Create your own subgroup

* Go to `Groups` > `Your groups` menu on the top left
* Click on `CDG DevSecOps Bootcamp 2022` group
* Click on `New subgroup` button
* Click on `Create group`
* Create your own group
  * Group name: `training[X]`
  * Group URL: `training[X]`
  * Leave the rest default

### Create your first project

* Make sure you are on your newly created subgroup
* Click on `New project` button
* Click on `Create blank project`
* Create rating project
  * Project name: `ratings`
  * Project URL: `cdb22/training[X]`
  * Project slug: `ratings`
  * Initialize repository with a README: `Unchecked`
  * Leave the rest default

### Add remote repository and push code

* Copy `git remote add origin ...` command in `Push an existing folder` section and put the following commands

```bash
git remote add origin git@git.demo.opsta.co.th:cdb22/training[X]/ratings.git
# To see remote repository has been added
git remote -v
git push -u origin main
# Maybe you need to answer yes for the first time push
```

* Refresh ratings main page on GitLab again to see change

## Adding ratings source code to repository

* Copy these files to your root directory
  * [LICENSE](../src/ratings/LICENSE)
  * [.gitignore](../src/ratings/.gitignore)
* On Cloud Shell, `mkdir src` to create src directory
* Copy these files to your `src` directory
  * [package.json](../src/ratings/package.json)
  * [ratings.js](../src/ratings/ratings.js)
  
* Commit and push the code

```bash
git status

git add .
git status
git commit -m "Add source code"

git push origin main
```

## Fork dev branch for develop

* Put these commands to create dev branch

```bash
git branch
git branch dev
git branch
git checkout dev
git branch
# Use --set-upstream so next time you can just use git push
git push --set-upstream origin dev
# Check branch on GitLab
```

## Protect your master branch from direct pushing

* Go to menu `Settings` > `Repository` on GitLab
* Expand `Protected Branches`
* Change `Allowed to push` to `No one`
* This will allow no one to direct push to master branch but you have to change via merge request only

## Change setting not to delete source branch by default

* Go to menu `Setting` > `General` on GitLab
* Expand `Merge requests`
* Unchecked `Enable 'Delete source branch' option by default`
* Click `Save changes`

## Create Docker Image and Container to run Ratings service

* Copy these files to your root directory
  * [Dockerfile](../src/ratings/Dockerfile)
  * [docker-compose.yaml](../src/ratings/docker-compose.yaml) (Don't forget to change [X] to your training user number)
* Add initial database script directory

```bash
mkdir ~/ratings/databases
```

* Copy database script files to `databases` directory
  * [ratings_data.json](../src/ratings/databases/ratings_data.json)
  * [script.sh](../src/ratings/databases/script.sh)
* Run the following commands

```bash
cd ~/ratings/
docker compose up
```
* Click on icon `Web preview` and `Preview on port 8080` on the top right of Cloud Shell to access to ratings service container
* Try Web Preview with /health or /ratings/1 as path
* Ctrl + C to exit from Docker Compose
* Commit and push your repository

## Merge Requests

* Go to your repository <https://git.demo.opsta.co.th/cdb22/training[X]/ratings>
* Go to menu `Merge requests` on the left
* Click on `New merge request`
* Choose `Source branch` to be `dev` and Target branch is `main`
* Click on `Compare branches and continue`
* See `Commits` and `Changes` tabs. You can leave everything default and click on `Submit merge request`
* Click on `Merge`
* Check your repository to see update on `main` branch

## Navigation

* Previous: [Prerequisites](01-prerequisites.md)
* [Home](../README.md)
* Next: [Kubernetes Command Line Workshop](03-k8s-cli.md)
