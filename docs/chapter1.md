# Getting to Know ModuOps

ModuOps makes assumptions based on it's roots for how an Operation Session runs. ModuOps takes into account the nuances of Operations Plans for Modular layouts. The original use cases for ModuOps come from Free-mo Operators. Home layouts have also had a hand in steering ModuOps development.

A Free-mo layout has many unique characteristics not found with other Model Railroad setups:
*  Layout is unique at each setup
*  Layout will never exist again
*  Layout exist for only a day or 2.
*  Starting state of the layout is unknown
*  Crew errors occur but should be self correcting
*  Rolling stock administration is cumbersome and error-prone

ModuOps 1.0 series is based on the original Mad River and Big Timber (MRBT) software. With this in mind and the constraints listed above, this Chapter helps new users understand some of the design decisions of the Application. ModuOps' features directly stem from the prior experience with MRBT and New England Free-mo.

## The ModuOps Difference
ModuOps is a random car type generator. The software essentially takes a list of car types and randomly assigns them to locations on the layout. Using car types IS the significant difference ModuOps offers.

The strict rules associated with reporting marks adds significant effort to an Operating Session. The administrative overhead to maintain car reporting marks takes an tremendous amount of time. In fact, the time invested in this task alone typically exceeds the life-span of the layout by many factors.

## Best Practices
ModuOps works best when there is a sourcing yard that sends cars to Consignees. Large layouts can be split into Districts with regional yards acting as the source of cars for an area of the Layout. It is even possible to simulate transfers between yards by making the yard itself a Consignee.

ModuOps is Stateless. That means that the system does not store any information about the past, present or future state of the layout. Another advantage in a layout where "Free-running" occurs between formal operations sessions. ModuOps does not need the layout to be setup in any particular manner prior to the operating session beginning.

ModuOps does not have the ability to schedule a "Pick Up". This is the direct result of the software being Stateless. Future stateful scheduling engines are planned.

ModuOps presently does not do any sophisticated car routing. The Application as it stands today is based on MRBT's logic. That means that all traffic originates at a yard and travels to a consignee. It is important to remember this sequence when creating Operations Plans.

ModuOps is a modular system allowing for scheduling engine Plugins. The initial release of the software ships with the Free Mad River and Big Timber scheduling engine. The MRBT scheduling engine is a basic random car type generator (each request has a 1/n chance of selection).

Also available is the sMarty scheduling engine. This is also a stateless engine with weighted random selection. The weighted selection uses the "Cars Per Week" (CPW) number given to the car type. In addition to the weighted selection, the system skews selections to facilitate car blocking.

## Home Layouts
ModuOps works GREAT with home layouts. In fact, there are quite a few home layouts switching from car cards to ModuOps for formal Operating Sessions. Many of the concerns that Free-mo Ops Chiefs have seem to transfer directly to home layout Ops Chiefs as well.

In fact, a home layout is the perfect place to start before diving in to be a Free-mo layout Ops Chief. Most home layouts are smaller than Modular Layouts. Starting with a small layout allows you to learn how ModuOps works.

## Agile Development Model
What the heck is that? If you've never heard of Agile Development don't worry. What it means is that we are fans of working on small, focused tasks and when the development on that task is complete, we send it out.

That means you're going to see new versions of the Application released at a faster pace than what you might be used to. But the plan is to add functionality in bite sized morsels instead of a full Holiday meal.

## How Much?
Good question. Developing a software such as this does incur costs. We've invested time in training, development tools, the web site and our time in creating this system. For now the software is going to remain a Donation-ware application. But the donation is a little different.

We are asking for $0.25 (twenty-five cents) per month donation. Why per month. To be honest, all our expenses are a monthly subscription plan (dev tools, web site, training). We hope that the Application provides you with twenty-five cents worth of entertainment a month. You can cancel at any time and your don't have to donate at all if you don't want to.

With that said, IF the donation model does not work out, we will switch the Application to a Free-mium model. Don't worry, we'll give you plenty of advanced warning on that when (if) it happens.



