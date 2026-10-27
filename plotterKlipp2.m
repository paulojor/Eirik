function [handles] = plotterKlipp2(hObject,handles)

if strcmp(handles.unitY,'V')
    unitFactor=1000;
else
    unitFactor=1000000000000;
end

if get(handles.toggleFinal,'Value')
    if get(handles.checkSelection,'Value')
        %fill in with the selection mode.
        if get(handles.checkNorm,'Value')
            if get(handles.checkTraces,'Value') 
                NormFFTRace=normalizationFc(handles.ffTrace(:,handles.Ch),handles.newTime,handles.protocol.baseline);
                plot(handles.newTime*1000,NormFFTRace*unitFactor,'Color',[0.7 0.7 0.7]);
            end
            if handles.include(:,handles.block,handles.Ch)
                [finalTraceNorm]=normalizationFc(handles.finalTrace(handles.block,:,handles.Ch),handles.newTime,handles.protocol.baseline);
                plot(handles.newTime*1000,finalTraceNorm*unitFactor,'b');
            else
                [finalTraceNorm]=normalizationFc(handles.finalTrace(handles.block,:,handles.Ch),handles.newTime,handles.protocol.baseline);
                plot(handles.newTime*1000,finalTraceNorm*unitFactor,'r'); 
            end
        else
            if get(handles.checkTraces,'Value')      
                plot(handles.newTime*1000,handles.ffTrace(:,handles.Ch)*unitFactor,'Color',[0.7 0.7 0.7]);
            end
            plot(handles.newTime*1000,handles.finalTrace(handles.block,:,handles.Ch)*unitFactor,'b');
        end
    else
        if get(handles.checkNorm,'Value'),
                if get(handles.checkTraces,'Value')
                   for i=1:size(handles.finalTrace,1)
                       NormFinalTrace=normalizationFc(handles.finalTrace(i,:,handles.Ch),handles.newTime,handles.protocol.baseline);
                       plot(handles.newTime*1000,NormFinalTrace*unitFactor,'Color',[0.7 0.7 0.7]); 
                   end
                end
                NormFFTRace=normalizationFc(handles.ffTrace(:,handles.Ch),handles.newTime,handles.protocol.baseline);
                plot(handles.newTime*1000,NormFFTRace*unitFactor,'b'); %plots the average of all blocks.
        else
                if get(handles.checkTraces,'Value')
                   for i=1:size(handles.finalTrace,1)
                      plot(handles.newTime*1000,handles.finalTrace(i,:,handles.Ch)*unitFactor,'Color',[0.7 0.7 0.7]); 
                   end
                end
                plot(handles.newTime*1000,handles.ffTrace(:,handles.Ch)*unitFactor,'b'); %plots the average of all blocks. 
        end
    end
else 
     if get(handles.checkSelection,'Value')
        %fill in with the selection mode.
        if get(handles.checkTraces,'Value')
            if get(handles.checkNorm,'Value') 
                [finalTraceNorm]=normalizationFc(handles.finalTrace(handles.block,:,handles.Ch),handles.newTime,handles.protocol.baseline);
                plot(handles.newTime*1000,finalTraceNorm*unitFactor,'Color',[0.7 0.7 0.7]);
                [traceNorm]=normalizationFc(handles.cutData{handles.selectedTrace}(handles.block,:,handles.Ch),handles.newTime,handles.protocol.baseline);
                if handles.include(handles.selectedTrace,handles.block,handles.Ch) 
                    if get(handles.checkExcAPs,'Value')
                        if ~handles.AP(handles.selectedTrace,handles.block,handles.Ch)
                            plot(handles.newTime*1000,traceNorm*unitFactor,'b');
                        else
                            plot(handles.newTime*1000,traceNorm*unitFactor,'r'); 
                        end
                    else
                        plot(handles.newTime*1000,traceNorm*unitFactor,'b');
                    end
                else
                   plot(handles.newTime*1000,traceNorm*unitFactor,'r'); 
                end
            else
                plot(handles.newTime*1000,handles.finalTrace(handles.block,:,handles.Ch)*unitFactor,'Color',[0.7 0.7 0.7]);
                if handles.include(handles.selectedTrace,handles.block,handles.Ch)
                    if get(handles.checkExcAPs,'Value')
                        if ~handles.AP(handles.selectedTrace,handles.block,handles.Ch)
                            plot(handles.newTime*1000,handles.cutData{handles.selectedTrace}(handles.block,:,handles.Ch)*unitFactor,'b');
                        else
                            plot(handles.newTime*1000,handles.cutData{handles.selectedTrace}(handles.block,:,handles.Ch)*unitFactor,'r');
                        end
                    else
                        plot(handles.newTime*1000,handles.cutData{handles.selectedTrace}(handles.block,:,handles.Ch)*unitFactor,'b');
                    end
                else
                    plot(handles.newTime*1000,handles.cutData{handles.selectedTrace}(handles.block,:,handles.Ch)*unitFactor,'r');
                end
            end
        else
            if get(handles.checkNorm,'Value') 
                [traceNorm]=normalizationFc(handles.cutData{handles.selectedTrace}(handles.block,:,handles.Ch),handles.newTime,handles.protocol.baseline);
                if handles.include(handles.selectedTrace,handles.block,handles.Ch)
                     if get(handles.checkExcAPs,'Value')
                        if ~handles.AP(handles.selectedTrace,handles.block,handles.Ch)
                            plot(handles.newTime*1000,traceNorm*unitFactor,'b');
                        else
                            plot(handles.newTime*1000,traceNorm*unitFactor,'r');
                        end
                     else
                         plot(handles.newTime*1000,traceNorm*unitFactor,'b');
                     end
                else
                    plot(handles.newTime*1000,traceNorm*unitFactor,'r');
                end
            else
                if handles.include(handles.selectedTrace,handles.block,handles.Ch) 
                    if get(handles.checkExcAPs,'Value')
                        if ~handles.AP(handles.selectedTrace,handles.block,handles.Ch)
                            plot(handles.newTime*1000,handles.cutData{handles.selectedTrace}(handles.block,:,handles.Ch)*unitFactor,'b');
                        else
                            plot(handles.newTime*1000,handles.cutData{handles.selectedTrace}(handles.block,:,handles.Ch)*unitFactor,'r');
                        end
                    else
                        plot(handles.newTime*1000,handles.cutData{handles.selectedTrace}(handles.block,:,handles.Ch)*unitFactor,'b');
                    end
                else
                    plot(handles.newTime*1000,handles.cutData{handles.selectedTrace}(handles.block,:,handles.Ch)*unitFactor,'r');
                end
            end
        end
     else
        if get(handles.checkTraces,'Value')
                if get(handles.checkNorm,'Value')
                    for i=1:length(handles.finalData)
                       [traceInd]=normalizationFc(handles.finalData{i}(handles.block,:,handles.Ch),handles.time,handles.protocol.baseline);
                       plot(handles.newTime*1000,traceInd*unitFactor, 'Color',[0.7 0.7 0.7]); %plots the individual constituent traces.
                    end
                else
                    for i=1:length(handles.finalData)
                       plot(handles.newTime*1000,handles.finalData{i}(handles.block,:,handles.Ch)*unitFactor, 'Color',[0.7 0.7 0.7]); %plots the individual constituent traces.
                    end
                end
        end
        if get(handles.checkNorm,'Value')
            [traceInd]=normalizationFc(handles.finalTrace(handles.block,:,handles.Ch),handles.time,handles.protocol.baseline);
            plot(handles.newTime*1000,traceInd*unitFactor,'b');
        else
            plot(handles.newTime*1000,handles.finalTrace(handles.block,:,handles.Ch)*unitFactor,'b');
        end 
     end
end
    
    

guidata(hObject,handles);
end
