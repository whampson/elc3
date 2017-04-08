# The Extended LC-3
ECE 385 final project.

## Instructions for Git
### Getting a Local Copy of the Repository
1. Open the Command Prompt and naviage to the directory where you'd like to keep
   the project.
2. Run `git clone https://github.com/thehambone93/elc3.git` to clone the
   repository.
3. Open `elc3.qpf` and compile the project.

### Updating Your Local Copy of the Repository
You should **ALWAYS** update your repository before working.
1. Run `git pull origin master` at the command line to grab changes from the
   remote repository.
    * If you're working on a different branch, replace "master" with your current
      branch name.

### Adding Files to the Repository
1. Create all SystemVerilog files in the `hardware/` directory.
2. Create all C files in the `software/` directory under the accompanying project
   directory.
3. Make Git aware of the file by typing `git add file_name` at the command line.

### Committing and Pushing Your Changes
1. Commit by running `git commit -m "your message"` at the console.
2. Push to the remote repository by typing `git push origin master`.
    * If you're working on a different branch, replace "master" with your current
      branch name.

#### Some Tips
* Commit often! Once you get a working piece of code, you should commit it so the
  file can be rolled back should any significant bugs arise in the future.
* Keep commit messages short and sweet.
  * Commit messages are intended to be like email subjects. You can add a longer
    message (i.e. message body) by doing the following:  
    `git commit -m "My commit short summary" -m "A more detailed summary of the commit goes here."`  
* Push only when you have completed a feature or have working code. Never push
  code that is buggy or unfinished.
  * If you must push buggy/unfinished code, explain the details in the commit
    message body.
