function [handles]=plotterKlipp(hObject,handles)

%% updates the check status.
if get(handles.toggleCut,'Value') || (handles.cut==1 && handles.cutType==2)
    if get(handles.checkSelection,'Value')
        if handles.check(handles.selectedTrace,handles.block,handles.Ch)==1
            set(handles.checkCheck,'Value',1);
        else
            set(handles.checkCheck,'Value',0);
        end
    else 
        if handles.check(:,handles.block,handles.Ch)==1
            set(handles.checkCheck,'Value',1);
        else
            set(handles.checkCheck,'Value',0);
        end
    end
else
    if get(handles.checkSelection,'Value')
        if handles.check(handles.selectedTrace,:,handles.Ch)==1
            set(handles.checkCheck,'Value',1);
        else
            set(handles.checkCheck,'Value',0);
        end
    else
        if handles.check(:,:,handles.Ch)==1
            set(handles.checkCheck,'Value',1);
        else
            set(handles.checkCheck,'Value',0);
        end
    end
end


%% plots the result.
axes(handles.axes2);
cla;
hold on;

if strcmp(handles.unitY,'V')
    unitFactor=1000;
else
    unitFactor=1000000000000;
end

if handles.cut==1 && handles.cutType==2 %in case the trace was cut using the RappReader method.
    [handles]=plotterKlipp2(hObject, handles);
else %the other types of cutting.
    if get(handles.toggleFinal,'Value')
        if get(handles.checkSelection,'Value')
            [handles]=selectionModeKlipp(hObject,handles);
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
            [handles]=selectionModeKlipp(hObject,handles);
        else
            if get(handles.toggleCut,'Value') 
                if ~isempty(handles.finalData) && get(handles.checkTraces,'Value')
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
            else
                if handles.cut
                    %fill in with the reconstructed trace.
                    if get(handles.checkTraces,'Value')
                        for i=1:size(handles.data,1)
                            trace=rebuildTrace(handles.preFinalData(i,:,handles.Ch),handles.finalData{i}(:,:,handles.Ch),handles.postFinalData(i,:,handles.Ch));
                            if get(handles.checkNorm,'Value')
                                [trace]=normalizationFc(trace,handles.time,handles.protocol.baseline);
                            end
                            plot(handles.time*1000,trace*unitFactor,'Color',[0.7 0.7 0.7]);
                            clear trace;
                        end
                    end
                    trace=rebuildTrace(handles.avrPreFinalData(1,:,handles.Ch),handles.finalTrace(:,:,handles.Ch),handles.avrPostFinalData(1,:,handles.Ch));
                    if get(handles.checkNorm,'Value')
                        [trace]=normalizationFc(trace,handles.time,handles.protocol.baseline);
                    end
                    plot(handles.time*1000,trace*unitFactor,'b');
                else %in case the trace is original.
                    if ~isempty(handles.data) && get(handles.checkTraces,'Value'),
                        if get(handles.checkNorm,'Value')
                            for i=1:size(handles.data,1)
                                [traceInd]=normalizationFc(handles.data(i,:,handles.Ch),handles.time,handles.protocol.baseline);
                                plot(handles.time*1000,traceInd*unitFactor, 'Color',[0.7 0.7 0.7]); %plots the individual constituent traces.
                            end
                        else
                            for i=1:size(handles.data,1)
                               plot(handles.time*1000,handles.data(i,:,handles.Ch)*unitFactor, 'Color',[0.7 0.7 0.7]); %plots the individual constituent traces.
                            end
                        end
                    end
                    if get(handles.checkNorm,'Value')
                        [traceInd]=normalizationFc(handles.trace(1,:,handles.Ch),handles.time,handles.protocol.baseline);
                        plot(handles.time*1000,traceInd*unitFactor,'b');
                    else
                        plot(handles.time*1000,handles.trace(1,:,handles.Ch)*unitFactor,'b');
                    end
                end
            end
        end
    end
end

xlabel('Time (ms)');
if strcmp(handles.unitY,'V')
    ylabel('Membrane Potential (mV)');
else
    ylabel('Membrane Current (pA)');
end

guidata(hObject,handles);
end