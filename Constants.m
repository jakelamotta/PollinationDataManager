classdef Constants < uint32
    %Constants enum with definitions for where important columns
    %exist in the Observation cell. When changing the place of any of these
    %columns the value needs to be changed in Constants accordingly.
    %Their placement is easily found by opening the program, clearing data
    %and look for each position to the far right.
    
    enumeration
       %%Column position of "ID"
       IdPos (2)
       
       %These are variables that wont be averaged as these are "standard"
       %variables and not variables fetched from data but from the folder
       %structre. Such as Flower, id, date, positive, negative. All strings
       %should be within this limit aswell.
       StandardVarsPos (9);
       
       %%Column position of Spectro arrays
       SpectroXPos (49)
       SpectroYPos (50)
       SpectroXUpPos (51)
       SpectroYUpPos (52)
       
       %%Column position of Olfactory arrays
       OlfXPos (53)
       OlfYPos (54)
       
       %%Spectro
       SpectroJazStart (200)
       SpectroJazEnd (800)
       SpectroJazDP (601)
       
       SpectroStart (380)
       SpectroEnd (600)
       SpectroDP (221)
    end
end

