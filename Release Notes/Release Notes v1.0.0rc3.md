### ModuOps 1.0.0drc3 Release Notes
Welcome to ModuOps version 1.0.0!

ModuOps is a random car generator for Model Railroad layouts. ModuOps takes a little different approach to this problem then most Operations software packages as we focus on working with rollingstock type and not reporting marks. Using type reduces the Administrative requirements of Operating Sessions and are self correcting to Operator errors.

ModuOps is originally designed to handle Free-mo layouts. Free-mo is a fantastic standard for model railroads allowing for more realistic layouts that are ripe for Operations. Free-mo layouts are ever-changing with each setup being unique for any other. The complexities and time required to create an Operations Plan for a modular layout such as Free-mo requires an tremendous amount of time. In fact, the time to simply enter reporting marks will easily take longer than the amount of time the layout will exist.

ModuOps allows Ops Chiefs to focus on creating an exciting plan of operations for the layout and do not have to worry about managing the reporting marks of all the cars that may be placed on the layout. With ModuOps, layouts come alive in minimal time with minimal Administration.

Is ModuOps just for Free-mo layouts? Absolutely not! ModuOps is PERFECT for home layouts too! ModuOps is designed to work on layouts that range from a shelf switching layout, all they way up to a layouts the size of a hockey rink.

Is ModuOps done? No. Not even close. This is the 1.0.0 release. We have ideas where the software is going and you can add input as well. Make sure you check out www.moduops.com and for updates and to provide feedback on the software.

#### Scheduling Engines
##### MRBT
The MRBT scheduling engine is a replication of the engine provided by the software package called "Mad River and Big Timber" by Lee Salomon. This engine is a stateless, non-biased random car generator based on rollingstock type. Each and every car move is given an equal chance of being selected. Rollingstock location is not tracked by the system (stateless). This scheduler does a good job of creating traffic on a layout especially when the number of Consignees is small.

##### sMarty
The sMarty scheduling engine is a stateless, biased psuedo-random car generator based on rollingstock type. Each car move is has a weighting for selection. The weighting does favor selection of rollingstock based on the percentage an individual weight has compared to all other possible movements for a given sample set. Furthermore, once a car type is selected, there is a significant probability the engine will select a matching move for the Consignee selected.

sMarty is intended for layouts operations where a better approximation of Prototypical car rates are desired for an Operating session.

#### New in this Version
- Changes made on Edit screens are now saved automatically when leaving the screen
- When quitting, Application now clears out all data after saving
- When opening, Application displays file dialog to open a data file
- fixed an issue where windows was not adding the .mop extension to data files
- fixed link to the manual

#### What's Not Working...
Drop Zones in a Module/Town have a "Direction" which is the direction the zone faces to be a trailing drop (A or B). Zones that are accessible by both sides of a module are not supporter (faces A & B). For now, designate these zones as either an A or B.

#### Feedback and Bugs
Your feedback and bug reports are important to us. There's big plans for ModuOps but we can't get there without your help.

Please use our [Forums](http://www.moduops.com/forums) to post Feedback you have on the software.

[Bug reports are tracked on Github](https://github.com/bhall2001/moduops/issues). However, we understand that you may not be familiar with the system so please feel free to post bug reports in our Forums as well.
