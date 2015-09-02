function nodes = updateBeliefs(nodes)
nodes = initializeRoots(nodes);
nodes = passPi(nodes);
nodes = updateBEL(nodes);


function nodes = initializeRoots(nodes)
[roots children] = getRootsChildren(nodes);
for i = 1:length(roots)
nodes{roots(i)}.pi = nodes{roots(i)}.BEL;
end


function [roots children] = getRootsChildren(nodes)
j = 1;
numNodes = length(nodes);
for i = 1:numNodes
    if nodes{i}.attributes.root == true;
        roots(j) = i;
        j = j + 1;
    end
end

for i = 1:length(roots)
    for j = 1:length(nodes{roots(i)}.children)
        children(j) = nodes{roots(i)}.children(j);
    end
end


function nodes = marginalize(nodes, childNode)
numParents = length(nodes{childNode}.parents);
numRows = 2*numParents;
numColumns = 2^numParents;
M = nodes{childNode}.M;
%numRows+2 in order to store result at the bottom of the matrix
container = zeros(numRows+2,numColumns);
container(1:2,:) = M;
parentNumber = 1;
for j = 1:2:(numRows)
    columnCount = 1; 
    for k = 1:2:(numColumns);%number of "grabs"
       %get pi message from parent
        piMessage = nodes{nodes{childNode}.parents(parentNumber)}.pi;
        %grab the first square of M
        chunkM = container(j:j+1, k:k+1);
        %multiply the pi message by the conditional matrix
        container(j+2:j+3,columnCount) = piMessage' * chunkM';
        columnCount = columnCount+1;
    end
    parentNumber = parentNumber+1;
end
%grab the resultant pi message from the container
result = container((numParents*2)+1:end,1); 
%update beliefs
nodes{childNode}.BEL = result .* nodes{childNode}.lambda;
%update pi message to pass
nodes{childNode}.pi = result;
if nodes{childNode}.attributes.leaf == false
    for i = 1:length(nodes{childNode}.children)
        for k = 1:2
            if nodes{nodes{childNode}.children(i)}.lambda(k) ~= 0
                nodes{childNode}.pi(k) = nodes{childNode}.BEL(k) ./ nodes{nodes{childNode}.children(i)}.lambda(k);
            else
                nodes{childNode}.pi(k) = 0;
            end
        end
    end
end

function nodes = passPi(nodes)
[parentNodes childrenNodes] = getRootsChildren(nodes);

hasChildren = true;

while hasChildren
    for i = 1:length(childrenNodes)
        %marginalize each childe node of each root node
        nodes = marginalize(nodes, childrenNodes(i));
        %check if the children are leafs
        if nodes{childrenNodes(i)}.attributes.leaf == true
            childrenNodes(i) = 0;
        end
    end
    if sum(childrenNodes) == 0
        hasChildren = false;
    else
        childrenNodes = childrenNodes(childrenNodes~=0);
        parentNodes = childrenNodes;%parents become the old children
        for i = 1:length(parentNodes)
            for j = 1:length(nodes{parentNodes(i)}.children)
                childrenNodes(j) = nodes{parentNodes(i)}.children(j);
            end
        end
    end
end


function nodes = updateBEL(nodes)
numNodes = length(nodes);
for i = 1:numNodes
    if nodes{i}.attributes.root == false;
        nodes{i}.BEL = nodes{i}.pi.*nodes{i}.lambda;
        nodes{i}.BEL = normalize(nodes{i}.BEL);
    end
end

function normA = normalize(A)
normA = (1/sum(A)).*A;







