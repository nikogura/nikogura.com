# Python Development on MacOS
Some potentially timesaving tips and tricks I've found on my Pythonic journey.

## Don't Use the Default Python Interpreter
You could, and it might not be a total disaster, pain in the butt, and it might not expose you to all sorts of interesting usability and security problems.

Then again, you could install the exact version of Python you desire, and configure it with the precise versions of the libaries you desire, and have developed against, and know to work with your application.  'Nuff said.  

## Pre Setup

### Install Homebrew
Homebrew is billed as ["The missing package manager for OS X"](http://brew.sh/). It rocks.  It's simple, it works, and all the cool kids are using it.

Not only does it install stuff, keeps versions and updates straight, gives reproducible results, is well documented and maintained, but it does its thing in userspace, so you don't need to use 'sudo'.  This is a good thing.  Install homebrew thusly:

        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

Once you have Homebrew, install Python 2.7 and virtualenv via homebrew:

        brew install python
        pip install virtualenv
        
You could go whole hog and install Python 3.  If you're working in a quazi-vacuum with no other Python development going on, you probably should do Python 3, as you'll be more future proof.

I work for iOS Systems, and we have more than a few Python apps in flight, and unfortunately they're all Python 2.7.x  so, I'm stuck writing for Python 2.7 for the time being until we can upgrade everything across the board.  If you're using my libraries, you're stuck too.  Sorry.  My only promise is that I'm well aware of the fact that eventually we'll all have to upgrade, and I'm writing things so that that upgrade shouldn't be too bad- in theory anyway.  Fingers crossed.

### Command Line Setup

Choose a location to store your virtual environments.  The author uses ~/src/python.  This directory will be referred to hereafter as VIRTUALENV_DIR
        
Create a virtualenv for your project:

        virtualenv <VIRTUALENV_DIR>/<PROJECT>
        
This will create the virtual environment.  You can use any path, just so long as you remember where you put it.  You'll need it later.

NOTE:  Do not perform this step if you're using IntelliJ IDEA or PyCharm as your IDE.  IntelliJ and PyCharm don't like virtualenv's they did not create themselves.  If you're using a JetBrains IDE, proceed to 'IDE Setup below'.

Then you can activate it thusly:
        
        source <VIRTUALENV_DIR>/<PROJECT>/bin/activate
        
And install the requirements:
        
        pip install -r requirements.txt
        
You could also use [virtualenvwrapper](https://virtualenvwrapper.readthedocs.io/en/latest/) if you're going to work mostly from the command line.  It's well thought of, and works well.  I use IntelliJ, so you'll have to follow the instructions in the link above for help with virtualenvwrapper.
        
  
### IDE Setup

If you're using a JetBrains IDE (Intellij or PyCharm), the following is how *I* do things.  There are other ways to do it, but some ways that *should* work give surprising or inconsistent results.  My methods are not the only legitimate ones, but they're the ones that work for me.

First thing you want to do is check out the code from the command line:

        git clone git@github.com/org/project.git
        
Then create a new project with File -> New -> Project -> Python and under SDK choose New -> Python -> create virtualenv.  There is a dialog for creating projects directly from a VCS url.  I've had mixed results with it in the past, and now prefer to clone the repos manually, then point the IDE at the code. YMMV.

You can also create an 'empty' generic project.  I've had bad luck with that.  IntelliJ IDEA is first and foremost a Java IDE, and Java is totally obsessed with the 'type' of everything.  IntelliJ does better if it knows the 'type' of your project.  This is best done when you create the project.  Setting it later doesn't always seem to work.  Maybe PyCharm doesn't have this issue, being focused specifically on Python.  It's not an option for me, who floats between Java, Python, Ruby, and all sorts of other things.  IntelliJ is my home.

Generally speaking, I specifically ignore the .iml and .idea directories in git, and don't check them in.  I don't hesitate to 'recreate' the project files when things get screwey.  Just use the File -> New -> Project -> Python menus, and it'll pop warnings about overwriting the .iml file and .idea directory.  Just let it overwrite, and often you're back in business just like that.  Again, YMMV.

The virtualenv's created by IntelliJ are exactly the same as the ones you create from the command line, but for some reason IntelliJ doesn't figure out where all the pieces are unless it creates it itself.  You could presumably tell it where
everything is and have it all work, but do you really need that kind of trouble?  

Intellij, with a properly configured virtualenv that it recognizes, will automatically monitor requirements.txt, and will ask you if you want to load modules that you don't have yet.  It's pretty slick.

### IDE Python Trick
Check out [LocalEnv](LocalEnv.md) for a method of giving you easy access to a command line automatically pre-prepped for working with the virtualenv your IDE is using.
