%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%This function imports a network from genie saved as an .xdsl file
%%and converts it to a matlab structure.
%%Jeff Annis 
%%February 4th 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nodes, tree] = importNetwork(filename)
xDoc = readFile(filename);
[nodes, tree] = makeDataStructure(xDoc);

function xDoc = readFile(filename)
%reads .xdsl file format 
%and returns the node structure
xDoc = xml_parseany(fileread(filename));
xDoc = xDoc.nodes;

function [n, tree] = makeDataStructure(nodes)
%This code makes only those nodes that 
%have parents, have a conditional matrix, M.
%Also assigns root and leaf node properties
tree = buildTree(nodes);
for i = 1:length(nodes{1}.cpt)
    
    if isfield(nodes{1}.cpt{i}, 'parents'); %check if has parents
        n{i}.M = getProbs(nodes, i); %assign conditional matrix
        n{i}.attributes.root = false; %has parents -> not root node 
        n{i}.parents = orderParents(nodes, i);
    else
        n{i}.attributes.root = true;
        n{i}.parents = 0;
    end
    
    numChildren = sum(tree);
    if numChildren(i) > 0 %check if it has children
        n{i}.attributes.leaf = false; %has children -> not leaf node
        n{i}.children = find(tree(:,i) == 1);
    else
        n{i}.attributes.leaf = true;
        n{i}.children = 0;
    end
    
    n{i}.BEL = getProbs(nodes,i);
    n{i}.pi = getProbs(nodes,i);
    n{i}.lambda = ones(getNumRows(nodes,i),1);
end

function a = orderParents(nodes, nodeOfInterest)
parents = getParents(nodes, nodeOfInterest);
nodeMap = mapNodes(nodes);
for i = 1:length(parents)
    a(i) = find(parents(i)==nodeMap);
end
a = fliplr(a);



function P = buildTree(nodes)
%Input is all nodes; 
%Output is table of nodes and their corresponding parents;
%Columns are parents; Rows are children 
P = zeros(length(nodes{1}.cpt));
numNodes = length(nodes{1}.cpt);
for j = 1:numNodes %for all nodes
    numParents = length(getParents(nodes, j));
    if numParents ~= 0
        for k = 1:numParents;
            parentLetters = getParents(nodes, j);
            nodeMap = mapNodes(nodes);
            P(j,nodeMap == parentLetters(k)) = 1;
        end
    end
end

function parents = getParents(nodes, nodeOfInterest)
%Input is node of interest and nodes
%Output is parents of node of interest
if isfield(nodes{1}.cpt{nodeOfInterest}, 'parents'); %check if has parents
parents = nodes{1}.cpt{nodeOfInterest}.parents{1}.CONTENT;
parents = parents(isletter(parents) == 1);
else
parents = [];
end

function nodeMap = mapNodes(nodes)
for i = 1:length(nodes{1}.cpt)
    nodeMap(i) = nodes{1}.cpt{i}.ATTRIBUTE.id;
end

function numColumns = getNumColumns(nodes, nodeOfInterest)
nodeMap = mapNodes(nodes);
parents = getParents(nodes, nodeOfInterest);
numParents = length(parents);
if isfield(nodes{1}.cpt{nodeOfInterest}, 'parents'); %check if has parents
for j = 1:numParents
    numStates(j) = length(nodes{1}.cpt{nodeMap == parents(j)}.state);
end
numColumns = prod(numStates);
else
numColumns = 1;    
end


function numRows = getNumRows(nodes, nodeOfInterest)
numRows = length(nodes{1}.cpt{nodeOfInterest}.state);

function probMatrix = getProbs(nodes, nodeOfInterest)
numRows = getNumRows(nodes, nodeOfInterest);
numColumns = getNumColumns(nodes, nodeOfInterest);
probabilities = nodes{1}.cpt{nodeOfInterest}.probabilities{1}.CONTENT;
probMatrix = reshape(strread(probabilities), numRows, numColumns);





