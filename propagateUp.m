function nodes =  propagateUp(nodes)
%nodes{4}.lambda = [1 0]';
%nodes{5}.lambda = [1 0]';
%nodes{6}.lambda = [1 0]';
%nodes{7}.lambda = [1 0]';
nodes = cycle(nodes);

function [leafs parents] = getLeafsParents(nodes)
j = 1;
numNodes = length(nodes);
for i = 1:numNodes
    if nodes{i}.attributes.leaf == true;
        leafs(j) = i;
        j = j + 1;
    end
end
k = 1;
for i = 1:length(leafs)
    for j = 1:length(nodes{leafs(i)}.parents)
        parents(k) = nodes{leafs(i)}.parents(j);
        k = k+1;
    end
end 

function nodes = passLambda(nodes, childNode, margParent)
%This function gets the matrix P(childNode|ParentNode) 
%and multiplies it by lambda of childNode. It then 
%passes the message to its parent where it is multiplied with
%the existing lambda values
numParents = length(nodes{childNode}.parents);
numRows = 2*numParents;
numColumns = 2^numParents;
M = nodes{childNode}.M;
%numRows+2 in order to store result at the bottom of the matrix
container = zeros(numRows+2,numColumns);
mixedContainer = zeros(numRows+2,numColumns);
container(1:2,:) = M;

parents = nodes{childNode}.parents;

j = 0;
for i = 1:numParents
    chunkType(i) = 2^j;
    j = j+1;
end

if length(parents)==1
    chunkType = 1;
    parentNumber = 1;
else
    chunkType = chunkType(parents~=margParent);
    parentNumber = find(nodes{childNode}.parents~=margParent);
end

%if length(chunkType)>1
 %   chunkType = chunkType(1);
%end
nextColumn = 1;
m = 1;
for j = 1:2:numRows
    if chunkType == 1
        mixedContainer = container;
    else
        for n = 1:(numColumns/2)
            mixedContainer(j:j+1,nextColumn:nextColumn+1) = container(j:j+1,[n (n+chunkType)]);
            nextColumn = nextColumn + 2;
        end
    end
    columnCount = 1;
    for k = 1:2:numColumns
        if length(parentNumber) == 1
            piMessage = nodes{nodes{childNode}.parents(parentNumber)}.pi;
        else
            piMessage = nodes{nodes{childNode}.parents(parentNumber(m))}.pi;   
        end
        chunkM = mixedContainer(j:j+1,k:k+1);
        mixedContainer(j+2:j+3,columnCount) = piMessage' * chunkM';    
        columnCount = columnCount+1;
    end
    numColumns = numColumns/2;
    if chunkType > 1
        chunkType = chunkType-chunkType^(m-1);
    end
    m = m+1;
    nextColumn = 1;
    container = mixedContainer;
end

beginRow = (2*numParents)-1;
if length(parentNumber) == 1
    endColumn = 2;%((2^numParents)/(2^(parentNumber-1)));
else
    endColumn = 2;%((2^numParents)/(2^(parentNumber(m-1)-1)));
end
%grab P(childNode|parentNode) from the container
result = container(beginRow:beginRow+1, 1:endColumn);
%pass lambda to parent and multiply it by the parents lambda value
nodes{margParent}.lambda = (result' * nodes{childNode}.lambda) .* nodes{margParent}.lambda;
%update beliefs
nodes{margParent}.BEL = nodes{margParent}.lambda .* nodes{margParent}.pi;
%normalize beliefs
nodes{margParent}.BEL = normalize(nodes{margParent}.BEL);
%if the node is a root node then set beliefs to pi
%if nodes{margParent}.attributes.root == true;
%    nodes{margParent}.pi = nodes{margParent}.BEL;
%end


function nodes = cycle(nodes)
[childrenNodes parentNodes] = getLeafsParents(nodes);

hasParents = true;

while hasParents
    for i = 1:length(parentNodes)
        %marginalize P(childNode|parentNode)
        if length(childrenNodes)>1
            nodes = passLambda(nodes, childrenNodes(i), parentNodes(i));
        else
            nodes = passLambda(nodes, childrenNodes, parentNodes(i));   
        end
        %check if the parents are roots
        if nodes{parentNodes(i)}.attributes.root == true
            parentNodes(i) = 0;
        end
    end
    if sum(parentNodes) == 0
        hasParents = false;
    else
        parentNodes = unique(parentNodes(parentNodes~=0));
        childrenNodes = parentNodes;
        for i = 1:length(childrenNodes)
            for j = 1:length(nodes{childrenNodes(i)}.parents)
                parentNodes(j) = nodes{childrenNodes(i)}.parents(j);
            end
        end
    end
end



function nodes = updateBEL(nodes, i)
nodes{i}.BEL = nodes{i}.lambda .* nodes{i}.pi;
nodes{i}.BEL = normalize(nodes{i}.BEL);


function normA = normalize(A)
normA = (1/sum(A)).*A;

