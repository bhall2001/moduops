### ModuOps 1.0.0d56 Release Notes

The first officially released version of ModuOps is out. If you were one of the lucky ones using earlier versions you'll notice the User Interface is totally re-designed (for the better).

Also of importance to prior Users is the data file format is completely different than the original format. This means that your old data will not load in the new versions. Not to worry, I have a conversion tool. Just eMail me your old data file and I'll convert it and send it back to you.

#### Scheduling Engine
ModuOps offers multiple scheduling engines. In this release you'll find our Free engine based on the software package called Mad River and Big Timber (MRBT). This is a stateless, unbiased random car generator which does an adequate job of simulating traffic.

Stateless - no information is stored about the current state or position of any Equipment in the system.

Unbiased - no skewing or weighting of the selection of Equipment by the scheduling engine. Every item is given an equal chance of selection.

#### What's Not Working...
At this point, it's probably better to give you the heads up as to what is not implemented yet.

This version is not "Feature Complete". That means you're going to find things that just don't work. Most significant of these items is Crew Instructions are not working yet. Also not implemented is most Cloning and Deleting of data in the software (next version will fix this).

Spots in a Module/Town have a "Direction" which is the direction the spot faces to be a trailing drop. Currently implemented are the A and B directions. What is not implemented yet is AB (a spot that is accessible from both directions). And yes, we know that a module could have any number of "directions". For version 1 you will find 2 directions, A and B with more options coming in future versions.

None of the Preferences screen fields are active yet. Data can be typed in to the fields, but the data is not used, nor is it saved or loaded to/from that data file.

Probably the other item that may trip you up is the "About ModuOps" menu is not working displaying an error if you select this menu option.

#### Feedback and Bugs
Your feedback and bug reports are important to us. There's big plans for ModuOps but we can't get there without your help.

Please use our [Forums](http://www.moduops.com/forums) to post Feedback you have on the software.

[Bug reports are tracked on Github](https://github.com/bhall2001/moduops/issues). However, we understand that you may not be familiar with the system so please feel free to post bug reports in our Forums as well.
