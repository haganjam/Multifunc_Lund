Instruction to use GitHub
================
Fabian Roger
2019-09-03

You will need:

**Step1:** make a GitHub account: <https://github.com/>

**Step2:** Download Git from <https://git-scm.com/downloads>

  - accept default options
  - follow instructions
    [here](https://help.github.com/en/articles/set-up-git)

**Step3:** Fork the GitHub repository
[FabianRoger/Multifunc\_Lund](https://github.com/FabianRoger/Multifunc_Lund)

  - On GitHub, navigate to the FabianRoger/Multifunc\_Lund repository.
  - In the top-right corner of the page, click Fork.

(see instructions
[here](https://help.github.com/en/articles/fork-a-repo))

**Step4:** make local folder in which you want the repository

**Step5:** Open terminal (Mac) / Command Prompt (Windows)

**Step6:** navigate to folder

Mac: `cd path/to/folder` Windows: \``cmd path/to/folder`

(you can drag a folder into the terminal or command promt to get the
full path)

**Step7:** go to your forked GitHub repo and click on “clone or
download” –\> copy the link with
<https://github.com/YOUR_USERNAME/Multifunc_Lund>

**Step 8:** in terminal / Command Prompt (after navigating to your
folder in Step 5), type:

`git clone https://github.com/YOUR_USERNAME/Multifunc_Lund` \[paste
address cloned in Step 7\]

*this should download the git repo in you local folder*

-----

**To sync your repo with the original repo:**

**Step 9:** using the terminal, go into the folder with the git repo
(that you just downloaded)

**Step 10:** type `git remote add upstream
https://github.com/FabianRoger/Multifunc_Lund` (you can copy this line)

**Step 11:** type `git fetch upstream` **Step 12:** type `git merge
upstream/master`

*repeat step 11 & 12 each time you want to update your local git Fork*
