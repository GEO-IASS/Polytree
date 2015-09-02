function nodes = updateBeliefs(dataFile)
%dataFile = 'U:\Desktop\Classes\Spring 11\Probabalistic Modeling\burglary.xdsl';
nodes = importNetwork(dataFile);
nodes = propagateDown(nodes);
nodes = propagateUp(nodes);
nodes = propagateDown(nodes);

for i = 1:length(nodes)
    a(1,i) = i;
    a(2:3,i) = nodes{i}.BEL;
end

disp(a);
