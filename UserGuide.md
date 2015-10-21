# Introduction #

Here's a quick and dirty guide on what you need to do to get ModuOps to work.

The software is relatively flexible in how you can do things. There may be multiple ways to arrive at the same solution. With this flexibility comes a level of complication as well. It is possible to arrange things in such a manner that you do not end up with the results you'd expect.

And, to make matters worse, the software is under development and probably contains bugs that will that may make things act weird. Sorry.

Overall, if you stay within the bounds and for now do very simple workorders, things work just fine. If you are looking to do more complex movement of freight, you may be venturing into unknown territory and you'll be on your own.


# Save Often, Keep a Back Up #

You are using a development version (aka. it's really not ready for general release) of ModuOps. As such there are most likely bugs in the code. This may result in the system checking out unexpectedly.

Fear the worst for now and make sure you save often. I'd even go as far as saying that every once in a while, duplicate your data file just in case things get corrupt or don't act as you'd expect. This way you'll be able to go back to a time where things were better.

# Consider Whatever You Do A Throw-Away #

Again, as this is a development release, the data format for the files is not set in stone yet. As such, you should expect that anything you do with this version of the software will not work in a future version.

I will apologize in advance for this but I am still developing the software and things change. I do want to move the data files to an XML format which as of yet is not defined.

Right now I am focusing on the guts of the scheduler and the User Interface. Soon I will be going back to address the data files and their format.

# Steps To A Manifest #
Here's what you need to do to get things flowing.

  1. Create Car Types
  1. Create Modules
  1. Create Consignees for Modules
  1. Create Spots for Consignees
  1. Create Work Orders for Spots
  1. Create Trains
  1. Generate a Manifest

Each of these steps is outlined below. If you don't like to read directions you can give it a try but you may find that you get stuck on something. Eventually you should come back here and read what I've written to see if that helps.

# Create Car Types #
From the Main Menu, click on "Car Types" or select "Car Types" from the Navigation menu. You are taken to the Car Types editor. If there is not data entered the screen will be blank.

For our example, we'll create the good ole 50' standard Box Car. Chances are you'll need this on your layout.

You will notice items required for input in ModuOps are labeled with Red. These items are required and you will not be able to move on until valid data is entered in these fields.

To create a new car select the Car's Classification "X" from the Pop-Up menu. This is the general classification of a Box car.

Next, enter the description of the new car. Type "Boxcar".

Press < tab >

Now enter a short description. This is used when a 1/2 page width printout is desired. Short but descriptive is the rule here. Type "Box".

Press < tab >

Enter in the length in scale feet for this car. Type "50".

Press < tab >

Finally, you can enter a remark relevant to this car type. The remark is optional and is printed on a Manifest each time the car type is displayed.

Press the New button just below the data fields.

You will see a new car type is added to the Car Type table. COOL! Continue this process for all the car types that you'll need for your Operating Sessions.

You will notice that ModuOps does not ask for Reporting Marks for the cars. I feel this is one of the unique characteristics of this software. Specific car reporting marks are not needed in advance to generate Manifests.

Reporting marks are handwritten in on the Manifest by the crew building the train.

If you find a mistake or need to change some data, simply select the Car Type in the table and the data is populated into the data entry fields. Make any changes/corrections to the data and press the Update button to update the Car Type in the ModuOps database.

Now select Save in the File menu. Name your data file and store it at a location where you'll be able to find it again.

# Modules #
Using the Navigation menu go to the Modules screen.

Here is where you list all the modules. To create a new module, type Anytown in the Name field. Now type Anytown in the Short Name field. You'll notice the labels for these 2 items are in red. This indicates these items are required.

Now press the "New" button. A module is created.

Click Anytown in the Modules list and then press the Consignee button. This screen is where you add Consignees, Spots and Work Orders for a Module.

Under the list of consignees, you can enter a consignee name for the current module. Type Team Track and press the "New" button.

Next up is to set up the Spots for the Consignee. We'll start with the simplest possible example. A single spur for loading or unloading.

# Creating a Spot #
Click Team Track and click the "New Spot". A spot is any location where a car or string of cars could be Set Out. Each spot must have a number that identifies the track. Typically this is a 3 digit number. A single track number may have multiple spots associated with it.

It is also possible to have multiple track numbers on the same spur when multiple Consignees share a spur for pick ups and deliveries. A spot can also indicate Doors or Spots.

But let's start out with the simplest case.

Type 100 for the track number. Click the Consignee button. This makes the spot name the same as the Cosignee. In our case this is Team Track. Now enter 60 for the spot length. Next you will see a direction.

(Direction is not implement as of now, click anything)

Click Save to save you spot.

# Creating a Work Order #
Select the Team Track spot. Now click New Work Order button. Work orders are what moves cars to a Consignee. You will see a list of all the car types you can select from. In our case, you'll see the 50' boxcar we created.

Click on the boxcar to hilite it. Next we need to tell the system how many "Cars Per Week" the consignee would expect to get a boxcar. Enter 2. This number is a relative weighting of the work order. This number is not the actual number of times the car will be scheduled over a 7 day period.

However, I find that this number allows the random scheduler to schedule cars are a more realistic rate when using the Cars Per Week as a frame of reference.

Remarks are optional and we'll skip them for now. Click the Add button. A notice pops up letting you know that the work order was created. Clicking OK takes you back to create another work order. Click the Close button to go back to the Consignee screen.

You should now see this work order listed for the Team Track spur.

If your feeling adventurous, go back to the Modules screen and create a another module (you can name it anything you want) as well as a consignee, spot and work order. That way when we go to the "Trains" section it will be a little more interesting.

# Creating a Train #
Now that we have modules, Consignees, Spots and work orders, it's time to make a train to deliver goods.

Select Trains in the Navigation Menu. To create a new train, give you train a name, number, length, an origin and destination and click the New button.

Click on the train to highlight it. Now you can add modules as "Stops" the train will make. Click on a module in the list of modules. To add it to the train click the arrow pointing toward the train stops list. Now click the 2nd module and click the arrow again.

To re-order the stops, drag a stop to it's no position to re-locate it.

# Generate a Manifest #
Now that a train is created with stops, you can click the "Manifest" button to generate a Train Manifest. The system will randomly generate cars to set out from the work orders you've created.

If you'd like to create additional Manifests, click the Generate Manifest button to get a new manifest for the current train.

NOTE: The true benefits of this system will not be realized with very small work orders. You'll need to create more work orders before you'll see the power of the scheduler.
