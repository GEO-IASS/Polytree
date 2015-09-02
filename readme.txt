%%%%%%%%%%%%%%%%%%%%%
%%Pearl's 1988 Polytree Algorithm
%%Jeff Annis
%%February 10, 2011
%%%%%%%%%%%%%%%%%%%%%

This implements the polytree algorithm in matlab. The program imports a .xdsl file from
GENIE and then computes the posterior probabilities.To import a network from GENIE, 
the xml toolbox must be installed.

In order to install the xml toolbox the 'xml_toolbox' (provided) folder 
should be added to the Matlab search path. This can be done by either of...

(1) If using the Matlab desktop, navigate to the 'Set Path' dialog 
 ('File' > 'Set Path'). Click the 'Add Folder' button and browse 
 to the directory containing the XML Toolbox, select 'OK' to 
 confirm. You may wish to click the 'Save' button to preserve 
 the configuration between sessions. Click 'Close' to dismiss 
 the dialog.

(2) If you are using Matlab via the Unix terminal you can instead 
 use the 'addpath' and 'savepath' functions at the Matlab command 
 line. 
     >> addpath /home/USER/GeodiseLab/XMLToolbox

To import a network type:
updateBeliefs('filename.xdsl')  
at the command line. This will compute the marginal probabilities for each node.
To compute the posterior probabilities given some evidence open 'propagateUp.m' and 
uncomment one of the nodes at the top of the function.