# CyberPatriot scoring engine for linux images

This is under construction. I will update this as I go.

This scoring engine has been tested against Mint21. I expect it will work 
against any linux distribution. YMMV.

## the scenario

Build the scenario by running ```sudo ./setup.sh```

The scenario contains some interesting real-world but nerfed vulnerabilities. 
They can be reversed from the check_* functions. You can run ```sudo 
./main.sh``` with debugging turned on to see a list of POSSIBLE points. The 
forensics questions should help lead you to answers for some of the more 
complex findings.

## setup

Create a new mint21 image from the .iso (use "Ubuntu" when VMWare asks you for 
the linux kernel or it will panic on startup).

Finish the installation and reboot.

Log in as the user you created (ensure you have sudoers access).

Run scripts using sudo to make sure you never clobber your logged in user.

1. $ sudo apt install git
2. $ git clone https://github.com/miketracy/csel-ncs
3. $ cd csel-ncs/
4. $ sudo git install pandoc
5. $ sudo ./setup.sh # this will setup the scenario that's been configured
6. $ sudo ./install.sh

You should have 2 forensics questions, a README and a scoring report on your 
desktop. Run through the README tasks and you're on your own for more points.

### NO CHEATING

## the story behind it

This is written in 100% bash as a science experiment.

I developed this for our cadets so they can train against a more difficult 
set of misconfigurations.

This is the property of Neotoma Composite Squadron, Civil Air Patrol.

----

MIT License

Copyright (c) 2024 mike.tracy@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy 
of this software and associated documentation files (the "Software"), to deal 
in the Software without restriction, including without limitation the rights 
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
