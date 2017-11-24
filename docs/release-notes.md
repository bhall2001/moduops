### ModuOps 2017.1 Release Notes {#moduops-1-0-0drc3-release-notes}

### Overview

ModuOps 2017.1 is updated to enhance the operations' realism and begin the process of ModuOps knowing more about the state of a layout during an Operations' Session. New in this version are the addition of car type codes and formal definition of Yards.

#### Scheduling Engines {#scheduling-engines}

##### MRBT {#mrbt}

The MRBT scheduling engine is a replication of the engine provided by the software package called "Mad River and Big Timber" by Lee Salomon. This engine is a stateless, non-biased random car generator based on rollingstock type. Each and every car move is given an equal chance of being selected. Rollingstock location is not tracked by the system \(stateless\). This scheduler does a good job of creating traffic on a layout especially when the number of Consignees is small.

##### sMarty {#smarty}

The sMarty scheduling engine is a stateless, biased psuedo-random car generator based on rollingstock type. Each car move is has a weighting for selection. The weighting does favor selection of rollingstock based on the percentage an individual weight has compared to all other possible movements for a given sample set. Furthermore, once a car type is selected, there is a significant probability the engine will select a matching move for the Consignee selected.

sMarty is intended for layouts operations where a better approximation of Prototypical car rates are desired for an Operating session.

#### New in this Version {#new-in-this-version}

* Expanded Car Type Classes

* Added Car Type Code. Intended to be AAR codes but can be any alpha-numeric code you choose. \(See Ops Sig [AAR Freight Car Codes](http://www.opsig.org/pdf/AARFreightCarCodes.pdf) and Eric Neubauer's [Guide to Car Types](http://eaneubauer.ipower.com/type.pdf) for AAR code references\)

* Added Modules/Town designation as a Yard

* Added Train origin/destination Yard selection

* Added Yard capacity planning based on Train routes and Consignee requests

* Added Reports \(finally\) for Equipment Register, Modules, Consignees, Drop Zones and Trains

### Prior .mop files and REQUIRE manual upgrading for Yards

The addition of Yards to the system unfortunately results in a little extra work to convert old data files. Before you are able to edit train information, you must define at least 1 Yard, Interchange or Staging Drop Zone. All Trains are required to originate and terminate at a Drop Zone designated as a Yard.

Steps required to convert data files prior to 2017.1

1. open the .mop data file in ModuOps

2. create a Drop Zone \(or 2, 3, etc...\) designated as a Yard. There is a check box on the Drop Zone Edit screen allowing you to signify the Zone is a Yard. Drop Zones are assigned to Modules/Towns

3. Edit Train details assigning Origin and Destination Yards for each Train defined

4. SAVE YOUR .mop FILE!

#### What's Not Working... {#what-s-not-working-}

Drop Zones in a Module/Town have a "Direction" which is the direction the zone faces to be a trailing drop \(A or B\). Zones that are accessible by both sides of a module are not supporter \(faces A & B\). For now, designate these zones as either an A or B.

### Platform Support

ModuOps supports a variety of platforms.

**Windows        
 **     Windows 7 \(both 32-bit and 64-bit\)  
      Windows 8.x \(Desktop\)  
      Windows 10

**Mac OS        
 **     10.9.x \(Mavericks\) on Intel  
      10.10.x \(Yosemite\) on Intel  
      10.11.x \(El Capitan\) on Intel  
      10.12.x \(Sierra\) on Intel

#### Feedback and Bugs {#feedback-and-bugs}

Your feedback and bug reports are important to us. There's big plans for ModuOps but we can't get there without your help.

Please use our [Forums](http://www.moduops.com/forums) to post Feedback you have on the software.

[Bug reports are tracked on Github](https://github.com/bhall2001/moduops/issues). However, we understand that you may not be familiar with the system so please feel free to post bug reports in our Forums as well.

