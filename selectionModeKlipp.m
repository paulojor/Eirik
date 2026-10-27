function [handles]=selectionModeKlipp(hObject,handles)

%% activates/deactivates the </> buttons.
if ~get(handles.toggleFinal,'Value')
    if handles.selectedTrace==1
        set(handles.pushDown,'Enable','Off');
     else
        set(handles.pushDown,'Enable','On');
    end 

    if handles.selectedTrace==size(handles.data,1)
        set(handles.pushUp,'Enable','Off');
    elseif handles.selectedTrace>size(handles.data,1)
        handles.indexTrace=1;
        set(handles.pushDown,'Enable','Off');
    else
        set(handles.pushUp,'Enable','On');
    end
end

%% updates the counters.
NTraces=size(handles.data,1);
set(handles.textNTotal,'String',strcat('/',num2str(NTraces)));
set(handles.editNTrace,'String',num2str(handles.selectedTrace));

%% checks the include/exclude status.
if get(handles.toggleFinal,'Value')
    if any(handles.include(:,handles.block,handles.Ch))
        set(handles.radioInc,'Value',1);
        set(handles.radioExc,'Value',0);
    else
        set(handles.radioInc,'Value',0);
        set(handles.radioExc,'Value',1);    
    end 
else
    if get(handles.toggleCut,'Value')
       if handles.include(handles.selectedTrace,handles.block,handles.Ch)
            set(handles.radioInc,'Value',1);
            set(handles.radioExc,'Value',0);
        else
            set(handles.radioInc,'Value',0);
            set(handles.radioExc,'Value',1);    
        end 
    else
       if any(handles.include(handles.selectedTrace,:,handles.Ch))
            set(handles.radioInc,'Value',1);
            set(handles.radioExc,'Value',0);
        else
            set(handles.radioInc,'Value',0);
            set(handles.radioExc,'Value',1);    
        end
    end
end


%% plots the line.
axes(handles.axes2);
cla;
hold on;

if strcmp(handles.unitY,'V'),
    unitFactor=1000;
else
    unitFactor=1000000000000;
end

if handles.cut==1 && handles.cutType==2 %in case the trace was cut using the RappReader method.
    [handles]=plotterKlipp2(hObject, handles);
    return
end
    
if get(handles.toggleFinal,'Value')
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
    if get(handles.toggleCut,'Value') %if the Cut button is pressed on.
        [handles]=includerFcn(hObject,handles);
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
    else %full traces (no cut)
        if handles.cut
            if get(handles.checkNorm,'Value') 
                if get(handles.checkTraces,'Value')
                    avrTrace=rebuildTrace(handles.avrPreFinalData(1,:,handles.Ch),handles.finalTrace(:,:,handles.Ch),handles.avrPostFinalData(1,:,handles.Ch));
                    avrTrace=normalizationFc(avrTrace,handles.time,handles.protocol.preStart);
                    plot(handles.time*1000,avrTrace*unitFactor,'Color',[0.7 0.7 0.7]);
                end
                trace=rebuildTrace(handles.preFinalData(handles.selectedTrace,:,handles.Ch),handles.finalData{handles.selectedTrace}(:,:,handles.Ch),handles.postFinalData(handles.selectedTrace,:,handles.Ch));
                trace=normalizationFc(trace,handles.time,handles.protocol.preStart);
                plot(handles.time*1000,trace*unitFactor,'b');
            else
                if get(handles.checkTraces,'Value')
                    avrTrace=rebuildTrace(handles.avrPreFinalData(1,:,handles.Ch),handles.finalTrace(:,:,handles.Ch),handles.avrPostFinalData(1,:,handles.Ch));
                    plot(handles.time*1000,avrTrace*unitFactor,'Color',[0.7 0.7 0.7]);
                end
                trace=rebuildTrace(handles.preFinalData(handles.selectedTrace,:,handles.Ch),handles.finalData{handles.selectedTrace}(:,:,handles.Ch),handles.postFinalData(handles.selectedTrace,:,handles.Ch));
                plot(handles.time*1000,trace*unitFactor,'b');
            end
        else
            if get(handles.checkNorm,'Value')
                if get(handles.checkTraces,'Value')
                    [traceInd]=normalizationFc(handles.trace(1,:,handles.Ch),handles.time,handles.protocol.preStart);
                    plot(handles.time*1000,traceInd*unitFactor,'Color',[0.7 0.7 0.7]);
                end
                [trace]=normalizationFc(handles.data(handles.selectedTrace,:,handles.Ch),handles.time,handles.protocol.preStart);
                plot(handles.time*1000,trace*unitFactor,'b');
            else
                if get(handles.checkTraces,'Value')
                    plot(handles.time*1000,handles.trace(1,:,handles.Ch)*unitFactor,'Color',[0.7 0.7 0.7]);
                end
                plot(handles.time*1000,handles.data(handles.selectedTrace,:,handles.Ch)*unitFactor,'b');
            end
        end
    end
end

xlabel('Time (ms)');
if strcmp(handles.unitY,'V'),
    ylabel('Membrane Potential (mV)');
else
    ylabel('Membrane Current(pA)');
end
    
guidata(hObject,handles);
end