function mixfig

A=findobj('MenuBar','figure');

h=figure;
hold on;

for j=1:length(A)
    allLines=A(j).CurrentAxes.Children;
    for i=length(allLines):-1:1 %it is run in reverse because the blue line is generally the first. 
        plot(allLines(i).XData,allLines(i).YData,'Color',allLines(i).Color);
    end
end

end

