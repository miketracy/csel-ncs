# Simple Score README

### UNIQUE IDENTIFIER

There isn't one.

### FORENSICS QUESTIONS

If there are "Forensics Questions" on your Desktop, you will receive 
points for answering these questions correctly. Valid (scored) 
"Forensics Questions" will only be located directly on your Desktop. 
Please read all "Forensics Questions" thoroughly before modifying this 
computer, as you may change something that prevents you from answering 
the question correctly.

### COMPETITION SCENARIO

You work for no one, you are a self employed penetration tester who has a 
side gig fixing motorcycles at a local garage.

You want your dektop linux image to be as secure as possible within the 
bounds of usability. Your friends sometimes come over and play DOOM on your 
rig. You need to make sure they have secure passwords. You don't want them 
storing any media files or installing any weird applications that may get you 
in legal trouble. File sharing applications and unencrypted file servers are 
expressly forbidden.

Your mission, should you choose to accept it, is to secure your home 
workstation against threats both local and remote.

### Mint 21 Linux

You're a Linux person. You only use the trendiest and least supported 
operating systems because you love to tinker. You run Mint 21. Your display 
manager is lightdm and should remain lightdm. All other display managers 
should find their way to the bit-bucket.

Choosy hackers choose Opera as their browser. You, however, use Firefox as 
your default browser as a small rebellion. It should be installed using 
Mozilla's Personal Package Archive (PPA). No SNAP packages. Not now. Not 
ever. You also use Thunderbird for email. Your therapist obviously worries 
about this choice but hey, you're a rebel right?

Make sure things are up-to-date so you don't get haxored.

You run a firewall. Again so you don't get haxored. You chose UFW. Remember 
to configure UFW correctly and include an incoming allow rule for sshd 
(tcp/22).

No root logins. That would be bad. Make your administrator buddies use 
```sudo```.

Your new best friend is Jennifer. She wants to game on your rig. Add her as a 
user.

Jennifer and Barry are going to thunderdome some BO6 privates. Make a new 
group for them named 'warriors' and add them to it. You should also create 
the group 'noobs' for any new users you want to restrict later. No one goes 
in there for now. Maybe Garry? Nah.

Larry is an old-school coder who loves dead languages. Ruby is his favorite. 
Make sure it's installed.

You really can't stand solitaire games. Make sure they all find /dev/null.

Since people might be using your rig over ssh. You use openssh-server to provide 
ssh an sshd server on your rig. You want them to have a desktop environment to 
use over ssh. X2Go fits that bill exactly. Make sure it's available.

Critical service:
sshd

### AUTHORIZED USERS AND ADMINISTRATORS

Authorized Administrators:

| username | password |
| -------- | -------- |
campy (you) | Pat42#ncs
barry | Z!pit3do0D4h
larry | fnork

Authorized Users:

carry\
garry\
harry\
jerry\
kerri\
mary\
perry\
terry

### COMPETITION GUIDELINES

- Authorized administrator passwords need to be secure.
- Do not stop or disable simple_scoring services or processes.
- Do not remove any authorized users or their home directories.
- You can view your current scoring report by double-clicking the 
"scoring_report" desktop icon.

## ANSWER KEY

Yeah. Right.
