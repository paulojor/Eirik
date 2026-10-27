function [tree,endian]=ImportHEKA2(datafile,pathname)
%Paulo Girão, January 2016

filename=datafile(1:end-4);
fullname=fullfile(pathname,datafile);

% Open file and get bundle header. Assume little-endian to begin with
endian='ieee-le';
fh=fopen(fullname, 'r', endian);
[bundle littleendianflag isBundled]=getBundleHeader(fh);
 
% Big endian so repeat process
if ~isempty(littleendianflag) && littleendianflag==false
    fclose(fh);
    endian='ieee-be';
    fh=fopen(fullname, 'r', endian);
    bundle=getBundleHeader(fh);
end
 
if isBundled
    ext={bundle.oBundleItems(1:12).oExtension};
    % Find the pulse data
    idx=strmatch('.pul', ext);
    start=bundle.oBundleItems(idx).oStart;
else
    % Or open pulse file if not bundled
    fclose(fh);
    start=0;
    fh=fopen(fullfile(pathname, [filename, '.pul']), 'r', endian);
end

% Base of tree
fseek(fh, start, 'bof');
Magic=fread(fh, 4, 'uint8=>char');
Levels=fread(fh, 1, 'int32=>int32');
Sizes=fread(fh, double(Levels), 'int32=>int32');

% Get the tree form the pulse file
Position=ftell(fh);
tree=getTree(fh, Sizes, Position);


if isBundled
    % Set offset for data
    idx=strmatch('.dat', ext);
    start=bundle.oBundleItems(idx).oStart;
else
    % Or open data file if not bundled
    fclose(fh);
    fh=fopen(fullname, 'r', endian);
    start=bundle.BundleHeaderSize;
end

%Saves the tree and all the other variables and clears the workspace.
%varfile=strcat(datafile(1:end-4),'.mat'); 
%save(varfile);
fclose(fh);
%clear all;


end


%--------------------------------------------------------------------------
function [h littleendianflag isBundled]=getBundleHeader(fh)
%--------------------------------------------------------------------------
% Get the bundle header from a HEKA .dat file
fseek(fh, 0, 'bof');
h.oSignature=deblank(fread(fh, 8, 'uint8=>char')');
switch h.oSignature
    case 'DATA'
        % Old format: nothing to do
        h.oVersion=[];
        h.oTime=[];
        h.oItems=[];
        h.oIsLittleEndian=[];
        h.oBundleItems(1:12)=[];
        h.BundleHeaderSize=0;
        isBundled=false;
    case {'DAT1' 'DAT2'}
        % Newer format
        h.oVersion=fread(fh, 32, 'uint8=>char')';
        h.oTime=fread(fh, 1, 'double');
        h.oItems=fread(fh, 1, 'int32=>int32');
        h.oIsLittleEndian=fread(fh, 1, 'uint8=>logical');
        h.BundleHeaderSize=256;
        switch h.oSignature
            case 'DAT1'
                h.oBundleItems=[];
                isBundled=false;
            case 'DAT2'
                fseek(fh, 64, 'bof');
                for k=1:12
                    h.oBundleItems(k).oStart=fread(fh, 1, 'int32=>int32');
                    h.oBundleItems(k).oLength=fread(fh, 1, 'int32=>int32');
                    h.oBundleItems(k).oExtension=deblank(fread(fh, 8, 'uint8=>char')');
                    h.oBundleItems(k).BundleItemSize=16;
                end
                isBundled=true;
        end
    otherwise
        error('This legacy file format is not supported');
end
littleendianflag=h.oIsLittleEndian;
return
end

%--------------------------------------------------------------------------
function [Tree, Counter]=getTree(fh, Sizes, Position)
%--------------------------------------------------------------------------
% Main entry point for loading tree
[Tree, Counter]=getTreeReentrant(fh, {}, Sizes, 0, Position, 0);
return
end

%--------------------------------------------------------------------------
function [Tree, Position, Counter]=getTreeReentrant(fh, Tree, Sizes, Level, Position, Counter)
%--------------------------------------------------------------------------
% Recursive routine called from LoadTree
[Tree, Position, Counter, nchild]=getOneLevel(fh, Tree, Sizes, Level, Position, Counter);
for k=1:double(nchild)
    [Tree, Position, Counter]=getTreeReentrant(fh, Tree, Sizes, Level+1, Position, Counter);
end
return
end

%--------------------------------------------------------------------------
function [Tree, Position, Counter, nchild]=getOneLevel(fh, Tree, Sizes, Level, Position, Counter)
%--------------------------------------------------------------------------
% Gets one record of the tree and the number of children
[s Counter]=getOneRecord(fh, Level, Counter);
Tree{Counter, Level+1}=s;
Position=Position+Sizes(Level+1);
fseek(fh, Position, 'bof');
nchild=fread(fh, 1, 'int32=>int32');
Position=ftell(fh);
return
end

%--------------------------------------------------------------------------
function [rec Counter]=getOneRecord(fh, Level, Counter)
%--------------------------------------------------------------------------
% Gets one record
Counter=Counter+1;
switch Level
    case 0
        rec=getRoot(fh);
    case 1
        rec=getGroup(fh);
    case 2
        rec=getSeries(fh);
    case 3
        rec=getSweep(fh);
    case 4
        rec=getTrace(fh);
    otherwise
        error('Unexpected Level');
end
return
end

% The functions below return data as defined by the HEKA PatchMaster
% specification

%--------------------------------------------------------------------------
function p=getRoot(fh)
%--------------------------------------------------------------------------
p.RoVersion=fread(fh, 1, 'int32=>int32');
p.RoMark=fread(fh, 1, 'int32=>int32');%               =   4; (* INT32 *)
p.RoVersionName=deblank(fread(fh, 32, 'uint8=>char')');%        =   8; (* String32Type *)
p.RoAuxFileName=deblank(fread(fh, 80, 'uint8=>char')');%        =  40; (* String80Type *)
p.RoRootText=deblank(fread(fh, 400, 'uint8=>char')');% (* String400Type *)
p.RoStartTime=fread(fh, 1, 'double=>double') ;%        = 520; (* LONGREAL *)
p.RoStartTimeMATLAB=time2date(p.RoStartTime);
p.RoMaxSamples=fread(fh, 1, 'int32=>int32'); %        = 528; (* INT32 *)
p.RoCRC=fread(fh, 1, 'int32=>int32'); %                = 532; (* CARD32 *)
p.RoFeatures=fread(fh, 1, 'int16=>int16'); %           = 536; (* SET16 *)
p.RoFiller1=fread(fh, 1, 'int16=>int16');%         = 538; (* INT16 *)
p.RoFiller2=fread(fh, 1, 'int32=>int32');%         = 540; (* INT32 *)
p.RootRecSize= 544;
p=orderfields(p);
return
end

%--------------------------------------------------------------------------
function g=getGroup(fh)
%--------------------------------------------------------------------------
% Group
g.GrMark=fread(fh, 1, 'int32=>int32');%               =   0; (* INT32 *)
g.GrLabel=deblank(fread(fh, 32, 'uint8=>char')');%               =   4; (* String32Size *)
g.GrText=deblank(fread(fh, 80, 'uint8=>char')');%                =  36; (* String80Size *)
g.GrExperimentNumber=fread(fh, 1, 'int32=>int32');%   = 116; (* INT32 *)
g.GrGroupCount=fread(fh, 1, 'int32=>int32');%         = 120; (* INT32 *)
g.GrCRC=fread(fh, 1, 'int32=>int32');%                = 124; (* CARD32 *)
g.GroupRecSize=128;%     (* = 16 * 8 *)
g=orderfields(g);
return
end

%--------------------------------------------------------------------------
function s=getSeries(fh)
%--------------------------------------------------------------------------
s.SeMark=fread(fh, 1, 'int32=>int32');%               =   0; (* INT32 *)
s.SeLabel=deblank(fread(fh, 32, 'uint8=>char')');%              =   4; (* String32Type *)
s.SeComment=deblank(fread(fh, 80, 'uint8=>char')');%            =  36; (* String80Type *)
s.SeSeriesCount=fread(fh, 1, 'int32=>int32');%        = 116; (* INT32 *)
s.SeNumbersw=fread(fh, 1, 'int32=>int32');%       = 120; (* INT32 *)
s.SeAmplStateOffset=fread(fh, 1, 'int32=>int32');%    = 124; (* INT32 *)
s.SeAmplStateSeries=fread(fh, 1, 'int32=>int32');%    = 128; (* INT32 *)
s.SeSeriesType=fread(fh, 1, 'uint8=>uint8');%         = 132; (* BYTE *)
s.SeFiller1=fread(fh, 1, 'uint8=>uint8');%         = 133; (* BYTE *)
s.SeFiller2=fread(fh, 1, 'uint8=>uint8');%         = 134; (* BYTE *)
s.SeFiller3=fread(fh, 1, 'uint8=>uint8');%         = 135; (* BYTE *)
s.SeTime=fread(fh, 1, 'double=>double') ;%               = 136; (* LONGREAL *)
s.SeTimeMATLAB=time2date(s.SeTime);
s.SePageWidth=fread(fh, 1, 'double=>double') ;%          = 144; (* LONGREAL *)
for k=1:4
    s.SeSwUserParamDescr(k).Name=deblank(fread(fh, 32, 'uint8=>char')');%
    s.SeSwUserParamDescr(k).Unit=deblank(fread(fh, 8, 'uint8=>char')');%
end
s.SeFiller4=fread(fh, 32, 'uint8=>uint8');%         = 312; (* 32 BYTE *)
s.SeSeUserParams=fread(fh, 4, 'double=>double');%       = 344; (* ARRAY[0..3] OF LONGREAL *)
s.SeLockInParams=getSeLockInParams(fh);%       = 376; (* SeLockInSize = 96, see "Pulsed.de" *)
s.SeAmplifierState=getAmplifierState(fh);%     = 472; (* AmplifierStateSize = 400 *)
s.SeUsername=deblank(fread(fh, 80, 'uint8=>char')');%           = 872; (* String80Type *)
for k=1:4
    s.SeSeUserParamDescr(k).Name=deblank(fread(fh, 32, 'uint8=>char')');%
    s.SeSeUserParamDescr(k).Unit=deblank(fread(fh, 8, 'uint8=>char')');%
end                                                  % (* ARRAY[0..3] OF UserParamDescrType = 4*40 *)
s.SeFiller5=fread(fh, 1, 'int32=>int32');%         = 1112; (* INT32 *)
s.SeCRC=fread(fh, 1, 'int32=>int32');%                = 1116; (* CARD32 *)
s.SeriesRecSize=1120;%      (* = 140 * 8 *)
s=orderfields(s);
return
end

%--------------------------------------------------------------------------
function sw=getSweep(fh)
%--------------------------------------------------------------------------
sw.SwMark=fread(fh, 1, 'int32=>int32');%               =   0; (* INT32 *)
sw.SwLabel=deblank(fread(fh, 32, 'uint8=>char')');%              =   4; (* String32Type *)
sw.SwAuxDataFileOffset=fread(fh, 1, 'int32=>int32');%  =  36; (* INT32 *)
sw.SwStimCount=fread(fh, 1, 'int32=>int32');%          =  40; (* INT32 *)
sw.SwSweepCount=fread(fh, 1, 'int32=>int32');%         =  44; (* INT32 *)
sw.SwTime=fread(fh, 1, 'double=>double');%               =  48; (* LONGREAL *)
sw.SwTimeMATLAB=time2date(sw.SwTime);% Also add in MATLAB datenum format
sw.SwTimer=fread(fh, 1, 'double=>double');%              =  56; (* LONGREAL *)
sw.SwSwUserParams=fread(fh, 4, 'double=>double');%       =  64; (* ARRAY[0..3] OF LONGREAL *)
sw.SwTemperature=fread(fh, 1, 'double=>double');%        =  96; (* LONGREAL *)
sw.SwOldIntSol=fread(fh, 1, 'int32=>int32');%          = 104; (* INT32 *)
sw.SwOldExtSol=fread(fh, 1, 'int32=>int32');%          = 108; (* INT32 *)
sw.SwDigitalIn=fread(fh, 1, 'int16=>int16');%          = 112; (* SET16 *)
sw.SwSweepKind=fread(fh, 1, 'int16=>int16');%          = 114; (* SET16 *)
sw.SwFiller1=fread(fh, 1, 'int32=>int32');%         = 116; (* INT32 *)
sw.SwMarkers=fread(fh, 4, 'double=>double');%            = 120; (* ARRAY[0..3] OF LONGREAL *)
sw.SwFiller2=fread(fh, 1, 'int32=>int32');%         = 152; (* INT32 *)
sw.SwCRC=fread(fh, 1, 'int32=>int32');%                = 156; (* CARD32 *)
sw.SweepRecSize         = 160;%      (* = 20 * 8 *)
sw=orderfields(sw);
return
end

%--------------------------------------------------------------------------
function tr=getTrace(fh)
%--------------------------------------------------------------------------
tr.TrMark=fread(fh, 1, 'int32=>int32');%               =   0; (* INT32 *)
tr.TrLabel=deblank(fread(fh, 32, 'uint8=>char')');%              =   4; (* String32Type *)
tr.TrTraceCount=fread(fh, 1, 'int32=>int32');%         =  36; (* INT32 *)
tr.TrData=fread(fh, 1, 'int32=>int32');%               =  40; (* INT32 *)
tr.TrDataPoints=fread(fh, 1, 'int32=>int32');%         =  44; (* INT32 *)
tr.TrInternalSolution=fread(fh, 1, 'int32=>int32');%   =  48; (* INT32 *)
tr.TrAverageCount=fread(fh, 1, 'int32=>int32');%       =  52; (* INT32 *)
tr.TrLeakCount=fread(fh, 1, 'int32=>int32');%          =  56; (* INT32 *)
tr.TrLeakTraces=fread(fh, 1, 'int32=>int32');%         =  60; (* INT32 *)
tr.TrDataKind=fread(fh, 1, 'uint16=>uint16');%           =  64; (* SET16 *) NB Stored unsigned
tr.TrFiller1=fread(fh, 1, 'int16=>int16');%         =  66; (* SET16 *)
tr.TrRecordingMode=fread(fh, 1, 'uint8=>uint8');%      =  68; (* BYTE *)
tr.TrAmplIndex=fread(fh, 1, 'uint8=>uint8');%          =  69; (* CHAR *)
tr.TrDataFormat=fread(fh, 1, 'uint8=>uint8');%         =  70; (* BYTE *)
tr.TrDataAbscissa=fread(fh, 1, 'uint8=>uint8');%       =  71; (* BYTE *)
tr.TrDataScaler=fread(fh, 1, 'double=>double');%         =  72; (* LONGREAL *)
tr.TrTimeOffset=fread(fh, 1, 'double=>double');%         =  80; (* LONGREAL *)
tr.TrZeroData=fread(fh, 1, 'double=>double');%           =  88; (* LONGREAL *)
tr.TrYUnit=deblank(fread(fh, 8, 'uint8=>char')');%              =  96; (* String8Type *)
tr.TrXInterval=fread(fh, 1, 'double=>double');%          = 104; (* LONGREAL *)
tr.TrXStart=fread(fh, 1, 'double=>double');%             = 112; (* LONGREAL *)
% 17.04.10 TrXUnit bytes may include some trailing characters after NULL
% byte
tr.TrXUnit=deblank(fread(fh, 8, 'uint8=>char')');%              = 120; (* String8Type *)
tr.TrYRange=fread(fh, 1, 'double=>double');%             = 128; (* LONGREAL *)
tr.TrYOffset=fread(fh, 1, 'double=>double');%            = 136; (* LONGREAL *)
tr.TrBandwidth=fread(fh, 1, 'double=>double');%          = 144; (* LONGREAL *)
tr.TrPipetteResistance=fread(fh, 1, 'double=>double');%  = 152; (* LONGREAL *)
tr.TrCellPotential=fread(fh, 1, 'double=>double');%      = 160; (* LONGREAL *)
tr.TrSealResistance=fread(fh, 1, 'double=>double');%     = 168; (* LONGREAL *)
tr.TrCSlow=fread(fh, 1, 'double=>double');%              = 176; (* LONGREAL *)
tr.TrGSeries=fread(fh, 1, 'double=>double');%            = 184; (* LONGREAL *)
tr.TrRsValue=fread(fh, 1, 'double=>double');%            = 192; (* LONGREAL *)
tr.TrGLeak=fread(fh, 1, 'double=>double');%              = 200; (* LONGREAL *)
tr.TrMConductance=fread(fh, 1, 'double=>double');%       = 208; (* LONGREAL *)
tr.TrLinkDAChannel=fread(fh, 1, 'int32=>int32');%      = 216; (* INT32 *)
tr.TrValidYrange=fread(fh, 1, 'uint8=>logical');%        = 220; (* BOOLEAN *)
tr.TrAdcMode=fread(fh, 1, 'uint8=>uint8');%            = 221; (* CHAR *)
tr.TrAdcChannel=fread(fh, 1, 'int16=>int16');%         = 222; (* INT16 *)
tr.TrYmin=fread(fh, 1, 'double=>double');%               = 224; (* LONGREAL *)
tr.TrYmax=fread(fh, 1, 'double=>double');%               = 232; (* LONGREAL *)
tr.TrSourceChannel=fread(fh, 1, 'int32=>int32');%      = 240; (* INT32 *)
tr.TrExternalSolution=fread(fh, 1, 'int32=>int32');%   = 244; (* INT32 *)
tr.TrCM=fread(fh, 1, 'double=>double');%                 = 248; (* LONGREAL *)
tr.TrGM=fread(fh, 1, 'double=>double');%                 = 256; (* LONGREAL *)
tr.TrPhase=fread(fh, 1, 'double=>double');%              = 264; (* LONGREAL *)
tr.TrDataCRC=fread(fh, 1, 'int32=>int32');%            = 272; (* CARD32 *)
tr.TrCRC=fread(fh, 1, 'int32=>int32');%                = 276; (* CARD32 *)
tr.TrGS=fread(fh, 1, 'double=>double');%                 = 280; (* LONGREAL *)
tr.TrSelfChannel=fread(fh, 1, 'int32=>int32');%        = 288; (* INT32 *)
tr.TrFiller2=fread(fh, 1, 'int16=>int16');%         = 292; (* SET16 *)
tr.TraceRecSize         = 296;%      (* = 37 * 8 *)
tr=orderfields(tr);
return
end

%--------------------------------------------------------------------------
function L=getSeLockInParams(fh)
%--------------------------------------------------------------------------
offset=ftell(fh);
L.loExtCalPhase=fread(fh, 1, 'double=>double') ;%        =   0; (* LONGREAL *)
L.loExtCalAtten=fread(fh, 1, 'double=>double') ;%        =   8; (* LONGREAL *)
L.loPLPhase=fread(fh, 1, 'double=>double') ;%            =  16; (* LONGREAL *)
L.loPLPhaseY1=fread(fh, 1, 'double=>double') ;%          =  24; (* LONGREAL *)
L.loPLPhaseY2=fread(fh, 1, 'double=>double') ;%          =  32; (* LONGREAL *)
L.loUsedPhaseShift=fread(fh, 1, 'double=>double') ;%     =  40; (* LONGREAL *)
L.loUsedAttenuation=fread(fh, 1, 'double=>double');%    =  48; (* LONGREAL *)
skip=fread(fh, 1, 'double=>double');
L.loExtCalValid=fread(fh, 1, 'uint8=>logical') ;%        =  64; (* BOOLEAN *)
L.loPLPhaseValid=fread(fh, 1, 'uint8=>logical') ;%       =  65; (* BOOLEAN *)
L.loLockInMode=fread(fh, 1, 'uint8=>uint8') ;%         =  66; (* BYTE *)
L.loCalMode=fread(fh, 1, 'uint8=>uint8') ;%            =  67; (* BYTE *)
L.LockInParamsSize=96;
fseek(fh, offset+L.LockInParamsSize, 'bof');
return
end

%--------------------------------------------------------------------------
function A=getAmplifierState(fh)
%--------------------------------------------------------------------------
offset=ftell(fh);
A.E9StateVersion=fread(fh, 1, 'double=>double');%       =   0; (* 8 = SizeStateVersion *)
A.E9RealCurrentGain=fread(fh, 1, 'double=>double');%    =   8; (* LONGREAL *)
A.E9RealF2Bandwidth=fread(fh, 1, 'double=>double');%    =  16; (* LONGREAL *)
A.E9F2Frequency=fread(fh, 1, 'double=>double');%        =  24; (* LONGREAL *)
A.E9RsValue=fread(fh, 1, 'double=>double');%            =  32; (* LONGREAL *)
A.E9RsFraction=fread(fh, 1, 'double=>double');%         =  40; (* LONGREAL *)
A.E9GLeak=fread(fh, 1, 'double=>double');%              =  48; (* LONGREAL *)
A.E9CFastAmp1=fread(fh, 1, 'double=>double');%          =  56; (* LONGREAL *)
A.E9CFastAmp2=fread(fh, 1, 'double=>double');%          =  64; (* LONGREAL *)
A.E9CFastTau=fread(fh, 1, 'double=>double');%           =  72; (* LONGREAL *)
A.E9CSlow=fread(fh, 1, 'double=>double');%              =  80; (* LONGREAL *)
A.E9GSeries=fread(fh, 1, 'double=>double');%            =  88; (* LONGREAL *)
A.E9StimDacScale=fread(fh, 1, 'double=>double');%       =  96; (* LONGREAL *)
A.E9CCStimScale=fread(fh, 1, 'double=>double');%        = 104; (* LONGREAL *)
A.E9VHold=fread(fh, 1, 'double=>double');%              = 112; (* LONGREAL *)
A.E9LastVHold=fread(fh, 1, 'double=>double');%          = 120; (* LONGREAL *)
A.E9VpOffset=fread(fh, 1, 'double=>double');%           = 128; (* LONGREAL *)
A.E9VLiquidJunction=fread(fh, 1, 'double=>double');%    = 136; (* LONGREAL *)
A.E9CCIHold=fread(fh, 1, 'double=>double');%            = 144; (* LONGREAL *)
A.E9CSlowStimVolts=fread(fh, 1, 'double=>double');%     = 152; (* LONGREAL *)
A.E9CCtr.TrackVHold=fread(fh, 1, 'double=>double');%       = 160; (* LONGREAL *)
A.E9TimeoutLength=fread(fh, 1, 'double=>double');%      = 168; (* LONGREAL *)
A.E9SearchDelay=fread(fh, 1, 'double=>double');%        = 176; (* LONGREAL *)
A.E9MConductance=fread(fh, 1, 'double=>double');%       = 184; (* LONGREAL *)
A.E9MCapacitance=fread(fh, 1, 'double=>double');%       = 192; (* LONGREAL *)
A.E9SerialNumber=fread(fh, 1, 'double=>double');%       = 200; (* 8 = SizeSerialNumber *)
A.E9E9Boards=fread(fh, 1, 'int16=>int16');%           = 208; (* INT16 *)
A.E9CSlowCycles=fread(fh, 1, 'int16=>int16');%        = 210; (* INT16 *)
A.E9IMonAdc=fread(fh, 1, 'int16=>int16');%            = 212; (* INT16 *)
A.E9VMonAdc=fread(fh, 1, 'int16=>int16');%            = 214; (* INT16 *)
A.E9MuxAdc=fread(fh, 1, 'int16=>int16');%             = 216; (* INT16 *)
A.E9TstDac=fread(fh, 1, 'int16=>int16');%             = 218; (* INT16 *)
A.E9StimDac=fread(fh, 1, 'int16=>int16');%            = 220; (* INT16 *)
A.E9StimDacOffset=fread(fh, 1, 'int16=>int16');%      = 222; (* INT16 *)
A.E9MaxDigitalBit=fread(fh, 1, 'int16=>int16');%      = 224; (* INT16 *)
A.E9SpareInt1=fread(fh, 1, 'int16=>int16');%       = 226; (* INT16 *)
A.E9SpareInt2=fread(fh, 1, 'int16=>int16');%       = 228; (* INT16 *)
A.E9SpareInt3=fread(fh, 1, 'int16=>int16');%       = 230; (* INT16 *)

A.E9AmplKind=fread(fh, 1, 'uint8=>uint8');%           = 232; (* BYTE *)
A.E9IsEpc9N=fread(fh, 1, 'uint8=>uint8');%            = 233; (* BYTE *)
A.E9ADBoard=fread(fh, 1, 'uint8=>uint8');%            = 234; (* BYTE *)
A.E9BoardVersion=fread(fh, 1, 'uint8=>uint8');%       = 235; (* BYTE *)
A.E9ActiveE9Board=fread(fh, 1, 'uint8=>uint8');%      = 236; (* BYTE *)
A.E9Mode=fread(fh, 1, 'uint8=>uint8');%               = 237; (* BYTE *)
A.E9Range=fread(fh, 1, 'uint8=>uint8');%              = 238; (* BYTE *)
A.E9F2Response=fread(fh, 1, 'uint8=>uint8');%         = 239; (* BYTE *)

A.E9RsOn=fread(fh, 1, 'uint8=>uint8');%               = 240; (* BYTE *)
A.E9CSlowRange=fread(fh, 1, 'uint8=>uint8');%         = 241; (* BYTE *)
A.E9CCRange=fread(fh, 1, 'uint8=>uint8');%            = 242; (* BYTE *)
A.E9CCGain=fread(fh, 1, 'uint8=>uint8');%             = 243; (* BYTE *)
A.E9CSlowToTstDac=fread(fh, 1, 'uint8=>uint8');%      = 244; (* BYTE *)
A.E9StimPath=fread(fh, 1, 'uint8=>uint8');%           = 245; (* BYTE *)
A.E9CCtr.TrackTau=fread(fh, 1, 'uint8=>uint8');%         = 246; (* BYTE *)
A.E9WasClipping=fread(fh, 1, 'uint8=>uint8');%        = 247; (* BYTE *)

A.E9RepetitiveCSlow=fread(fh, 1, 'uint8=>uint8');%    = 248; (* BYTE *)
A.E9LastCSlowRange=fread(fh, 1, 'uint8=>uint8');%     = 249; (* BYTE *)
A.E9Locked=fread(fh, 1, 'uint8=>uint8');%             = 250; (* BYTE *)
A.E9CanCCFast=fread(fh, 1, 'uint8=>uint8');%          = 251; (* BYTE *)
A.E9CanLowCCRange=fread(fh, 1, 'uint8=>uint8');%      = 252; (* BYTE *)
A.E9CanHighCCRange=fread(fh, 1, 'uint8=>uint8');%     = 253; (* BYTE *)
A.E9CanCCtr.Tracking=fread(fh, 1, 'uint8=>uint8');%      = 254; (* BYTE *)
A.E9HasVmonPath=fread(fh, 1, 'uint8=>uint8');%        = 255; (* BYTE *)

A.E9HasNewCCMode=fread(fh, 1, 'uint8=>uint8');%       = 256; (* BYTE *)
A.E9Selector=fread(fh, 1, 'uint8=>char');%           = 257; (* CHAR *)
A.E9HoldInverted=fread(fh, 1, 'uint8=>uint8');%       = 258; (* BYTE *)
A.E9AutoCFast=fread(fh, 1, 'uint8=>uint8');%          = 259; (* BYTE *)
A.E9AutoCSlow=fread(fh, 1, 'uint8=>uint8');%          = 260; (* BYTE *)
A.E9HasVmonX100=fread(fh, 1, 'uint8=>uint8');%        = 261; (* BYTE *)
A.E9TestDacOn=fread(fh, 1, 'uint8=>uint8');%          = 262; (* BYTE *)
A.E9QMuxAdcOn=fread(fh, 1, 'uint8=>uint8');%          = 263; (* BYTE *)

A.E9RealImon1Bandwidth=fread(fh, 1, 'double=>double');% = 264; (* LONGREAL *)
A.E9StimScale=fread(fh, 1, 'double=>double');%          = 272; (* LONGREAL *)

A.E9Gain=fread(fh, 1, 'uint8=>uint8');%               = 280; (* BYTE *)
A.E9Filter1=fread(fh, 1, 'uint8=>uint8');%            = 281; (* BYTE *)
A.E9StimFilterOn=fread(fh, 1, 'uint8=>uint8');%       = 282; (* BYTE *)
A.E9RsSlow=fread(fh, 1, 'uint8=>uint8');%             = 283; (* BYTE *)
A.E9Old1=fread(fh, 1, 'uint8=>uint8');%            = 284; (* BYTE *)
A.E9CCCFastOn=fread(fh, 1, 'uint8=>uint8');%          = 285; (* BYTE *)
A.E9CCFastSpeed=fread(fh, 1, 'uint8=>uint8');%        = 286; (* BYTE *)
A.E9F2Source=fread(fh, 1, 'uint8=>uint8');%           = 287; (* BYTE *)

A.E9TestRange=fread(fh, 1, 'uint8=>uint8');%          = 288; (* BYTE *)
A.E9TestDacPath=fread(fh, 1, 'uint8=>uint8');%        = 289; (* BYTE *)
A.E9MuxChannel=fread(fh, 1, 'uint8=>uint8');%         = 290; (* BYTE *)
A.E9MuxGain64=fread(fh, 1, 'uint8=>uint8');%          = 291; (* BYTE *)
A.E9VmonX100=fread(fh, 1, 'uint8=>uint8');%           = 292; (* BYTE *)
A.E9IsQuadro=fread(fh, 1, 'uint8=>uint8');%           = 293; (* BYTE *)
A.E9SpareBool4=fread(fh, 1, 'uint8=>uint8');%      = 294; (* BYTE *)
A.E9SpareBool5=fread(fh, 1, 'uint8=>uint8');%      = 295; (* BYTE *)

A.E9StimFilterHz=fread(fh, 1, 'double=>double');%       = 296; (* LONGREAL *)
A.E9RsTau=fread(fh, 1, 'double=>double');%              = 304; (* LONGREAL *)
A.E9FilterOffsetDac=fread(fh, 1, 'int16=>int16');%    = 312; (* INT16 *)
A.E9ReferenceDac=fread(fh, 1, 'int16=>int16');%       = 314; (* INT16 *)
A.E9SpareInt6=fread(fh, 1, 'int16=>int16');%       = 316; (* INT16 *)
A.E9SpareInt7=fread(fh, 1, 'int16=>int16');%       = 318; (* INT16 *)
A.E9Spares1=320;

A.E9CalibDate=fread(fh, 2, 'double=>double');%          = 344; (* 16 = SizeCalibDate *)
A.E9SelHold=fread(fh, 1, 'double=>double');%            = 360; (* LONGREAL *)
A.AmplifierStateSize   = 400;
fseek(fh, offset+A.AmplifierStateSize, 'bof');
return
end


%--------------------------------------------------------------------------
function str=time2date(t)
%--------------------------------------------------------------------------
t=t-1580970496;
if t<0
    t=t+4294967296;
end
t=t+9561652096;
str=datestr(t/(24*60*60)+datenum(1601,1,1));
return
end
%--------------------------------------------------------------------------
    
