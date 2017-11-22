# ModuOps 2017.2 Release Notes

## New in this Version

- Workaround of bug in compiler for Train Route re-ordering
- Fixed new Consignees were not scheduled
- Fixed error when loading files and there is no data
- Select File dialog no longer opens when launched
- Mac and Windows now include real installers!
- Moved to Levure Framework
- Built with Livecode 8.1.7

# ModuOps 2017.1 Release Notes

## New in this Version

- Drop Zone can now be designated as a Yard/Interchange/Staging
- Trains must originate and terminate at a Yard/Interchange/Staging
- Added Yard storage capacity based on percent or standard deviation of car requests
- Added AAR Code field to Car Types
- Added AAR Code as an option on Trainlists
- Added Report module (more reports coming soon)
- Fixed/Expanded options for Train Type
- Built with Livecode 8.1.3

## NOTICE

NEW Added "Yards" to the system. Old data files are compatible with one small caveat. Trains must now originate from a Drop Zone that is designated as a Yard. Until you define at least 1 Yard and assign trains to originate and terminate at Yards, YOU WILL NOT BE ABLE TO GENERATE TRAINLISTS.

This change was un-avoidable and needed for future enhancements.

Yards are Drop Zones marked as a Yard/Interchange/Staging. A Drop Zone designated as a yard should not have any Equipment Orders assigned it. The length of the drop zone should be the total length of all tracks making up the yard (aka. If there are 6 tracks in the yard each 500' long, the Drop Zone length should be 6 x 500 = 3000).

Trains must specify an origin and destination that is a Yard/Interchange/Staging drop zone. Trainlists are not generated unless a train originates and terminates at a Yard/Interchange/Staging drop zone.

## Feedback and Bugs
Your feedback and bug reports are important to us. There's big plans for ModuOps but we can't get there without your help.

Please use our [Facebook Page](https://www.facebook.com/groups/1029861033780522/) to post Feedback and to stay updated on progress with the software.

[Bug reports are tracked on Github](https://github.com/bhall2001/moduops/issues). However, we understand that you may not be familiar with the system so please feel free to post bug reports on our Facebook page as well.
