# LocalEnv
An IDE is nice, but occasionally it's useful to shell out to the command line.  The problem is, without extra care and feeding, what's going on in your IDE with it's plugins and menus might not be accurately represented in your command line environment, leading to very different and confusing results.

Python virtualenvs are a great example of a case where it's useful to link your IDE and your terminal window. To link them, try the following:

Inside the root of your project, craft a file like '.localenv' pointing at where you put the virtualenv.  The file name
doesn't matter, it just has to contain the path where you decided to put your virtualenvs

        source <VIRTUALENV_DIR>/<PROJECT>/bin/activate
        
        
Then in your ~/.bash_profile put this:

        if [ -e "$(pwd)/.localenv" ]; then
          source $(pwd)/.localenv
        fi

Voila!  When you open a terminal window in IntelliJ, it automatically will source the virtualenv and any python commands will use that python, and those libraries.  Your normal, external terminal windows will still be pointing at your defaults, but
the terminal window in any given IntelliJ project will automatically open to that project's virtualenv.  Neat huh?

Interestingly enough, this trick works well for other languages and tools.  Works great for LaTeX for example, if you're into that.


