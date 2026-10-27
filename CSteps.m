function CSteps(CSdata)

for k=1:size(CSdata,3),
    figure(k);
    hold on;

    for i=1:size(CSdata,1),
       trace=CSdata(i,:,k);
       plot(trace,'b');
    end
end

end
