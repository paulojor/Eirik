function [data2]=fusionGroups(data)
%fuses the datagroups into just one.

if numel(fieldnames(data))>2
    for G=1:length(data)
        data2(G).groupname=data(G).groupname;
        counter=length(data(G).group);
        counter2=length(data(G).CurrentSteps);
        if counter>0
            for i=1:counter
                data2(G).group(i)=data(G).group(i);
            end
        end
        if counter2>0
            for i=1:counter2
                data2(G).group(counter+i).name=data(G).CurrentSteps(i).name;
                data2(G).group(counter+i).rawdata=data(G).CurrentSteps(i).rawdata;
                data2(G).group(counter+i).intX=data(G).CurrentSteps(i).intX;
                data2(G).group(counter+i).unitY=data(G).CurrentSteps(i).unitY;
                data2(G).group(counter+i).listCh=data(G).CurrentSteps(i).listCh;
                data2(G).group(counter+i).include=data(G).CurrentSteps(i).include;
                data2(G).group(counter+i).AP=data(G).CurrentSteps(i).AP;
                data2(G).group(counter+i).check=data(G).CurrentSteps(i).check;
                data2(G).group(counter+i).CS=data(G).CurrentSteps(i).CS;
            end
        end
    end
else 
    data2=data;
end

end