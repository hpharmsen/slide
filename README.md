# slide
Python code to control your Slide curtains. 

Includes setup for Alexa -> IFTTT -> AWS -> API Gateway -> AWS Labda

You can find the Slide devices at https://slide.store
and full api documentation at https://documenter.getpostman.com/view/6223391/S1Lu2pSf?version=latest#intro


###Prerequisites
Code is for Python 3.6 and higher.

Make sure you have the environment settings slide_email and slide_password set.\
In AWS: in the Environment variables box at the source code page\
In PyCharm: in the Run -> Edit Configurations dialog box

## usage

    sl = Slide() # Create slide object
    sl.print_overview() # Lists your slides
    print( sl.get_position("Livingroom") ) # Get slide position
    sl.move("Livingroom", .8) # Set slide to 80% closed

## Controling Slide with Alexa
_"Alexa, open the curtains"_

This is done by deploying slide.py and the slide_lambda.py scripts to AWS and connectting it to Alexa using IFTTT.

For deployment to AWS Lambda see documents/deploy_to_aws.txt.

For connecting it all with IFTTT see documents/connect_to_ifttt.txtx

---
## credits
Martijn Lemmmens for providing the first version of the Slide script
