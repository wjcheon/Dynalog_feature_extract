clc
clear
close all
%%
[RTplanFileName,RTplanPathName,RTplanFilterIndex] = uigetfile('*.dcm','Select RTplan dicom file');
dicomInformation = dicominfo(fullfile(RTplanPathName,RTplanFileName));
nameOfBeamSequence = fieldnames(dicomInformation.BeamSequence);
numberOfBeamSequence = size(nameOfBeamSequence,1);
for iter1 = 1: numberOfBeamSequence
% for iter1 = 1: 1
    BeamNumber = getfield(dicomInformation,'BeamSequence',nameOfBeamSequence{iter1},'BeamNumber');
    NumberOfWedges = getfield(dicomInformation,'BeamSequence',nameOfBeamSequence{iter1},'NumberOfWedges');
    NumberOfCompensators = getfield(dicomInformation,'BeamSequence',nameOfBeamSequence{iter1},'NumberOfCompensators');
    NumberOfBoli = getfield(dicomInformation,'BeamSequence',nameOfBeamSequence{iter1},'NumberOfBoli');
    NumberOfBlocks = getfield(dicomInformation,'BeamSequence',nameOfBeamSequence{iter1},'NumberOfBlocks');
    ControlPointSequence = getfield(dicomInformation,'BeamSequence',nameOfBeamSequence{iter1},'ControlPointSequence');
    fieldnameOfControlPointSequence = fieldnames(ControlPointSequence);
    numberOfControlPointSequence = size(fieldnameOfControlPointSequence,1);
    %
    doseRate= zeros(numberOfControlPointSequence,1);
    gantryRotation= zeros(numberOfControlPointSequence,1);
    collimatorRotation= zeros(numberOfControlPointSequence,1);
    x1JawPosition = zeros(numberOfControlPointSequence,1);
    x2JawPosition = zeros(numberOfControlPointSequence,1);
    y1JawPosition = zeros(numberOfControlPointSequence,1);
    y2JawPosition = zeros(numberOfControlPointSequence,1);
    MLCPosition = zeros(numberOfControlPointSequence,120);
    CumulativeMetersetWeight = zeros(numberOfControlPointSequence,1);
    %
    Flag_ControlPointSequence = true;
    for iter2 = 1: size(fieldnameOfControlPointSequence,1)
        ControlPointSequnce_Item = getfield(ControlPointSequence,fieldnameOfControlPointSequence{iter2});
        if isfield(ControlPointSequnce_Item,'GantryAngle')
            gantryRotation(iter2,1) = getfield(ControlPointSequnce_Item,'GantryAngle');
        end
        %
        if isfield(ControlPointSequnce_Item,'BeamLimitingDeviceAngle')
            collimatorRotation(iter2,1) =  getfield(ControlPointSequnce_Item,'BeamLimitingDeviceAngle');
        end
        
        if isfield(ControlPointSequnce_Item,'DoseRateSet')
            doseRate(iter2,1) =  getfield(ControlPointSequnce_Item,'DoseRateSet');
        end
        
        if isfield(ControlPointSequnce_Item,'CumulativeMetersetWeight')
            CumulativeMetersetWeight(iter2,1) =  getfield(ControlPointSequnce_Item,'CumulativeMetersetWeight');
        end
        %
        BeamLimitingDevicePositionSequence = getfield(ControlPointSequnce_Item,'BeamLimitingDevicePositionSequence');
        fieldnameBeamLimitingDevicePositionSequence = fieldnames(BeamLimitingDevicePositionSequence);
        for iter3 = 1: size(fieldnameBeamLimitingDevicePositionSequence,1)
            DeviceType = getfield(BeamLimitingDevicePositionSequence,fieldnameBeamLimitingDevicePositionSequence{iter3},'RTBeamLimitingDeviceType');
            if strcmp(DeviceType,'ASYMX')
                XJawPositions = getfield(BeamLimitingDevicePositionSequence,fieldnameBeamLimitingDevicePositionSequence{iter3},'LeafJawPositions');
                x1JawPosition(iter2,1) = XJawPositions(1);
                x2JawPosition(iter2,1) = XJawPositions(2);
                clear XJawPositions
            elseif strcmp(DeviceType,'ASYMY')
                YJawPositions = getfield(BeamLimitingDevicePositionSequence,fieldnameBeamLimitingDevicePositionSequence{iter3},'LeafJawPositions');
                y1JawPosition(iter2,1) = YJawPositions(1);
                y2JawPosition(iter2,1) = YJawPositions(2);
                clear YJawPositions
            elseif strcmp(DeviceType,'MLCX')
                MLCPosition_buf= transpose(getfield(BeamLimitingDevicePositionSequence,fieldnameBeamLimitingDevicePositionSequence{iter3},'LeafJawPositions'));
                MLCPosition(iter2,:) = MLCPosition_buf;
                clear MLCPosition_buf
            end
            
        end
        
    end
    eval(sprintf('RTPlanAnalyzed.Item_%d.gantryRotation = gantryRotation',iter1))
    eval(sprintf('RTPlanAnalyzed.Item_%d.collimatorRotation = collimatorRotation',iter1))
    eval(sprintf('RTPlanAnalyzed.Item_%d.doseRate = doseRate',iter1))
    eval(sprintf('RTPlanAnalyzed.Item_%d.CumulativeMetersetWeight = CumulativeMetersetWeight',iter1))
    eval(sprintf('RTPlanAnalyzed.Item_%d.x1JawPosition = x1JawPosition',iter1))
    eval(sprintf('RTPlanAnalyzed.Item_%d.x2JawPosition = x2JawPosition',iter1))
    eval(sprintf('RTPlanAnalyzed.Item_%d.y1JawPosition = y1JawPosition',iter1))
    eval(sprintf('RTPlanAnalyzed.Item_%d.y2JawPosition = y2JawPosition',iter1))
    eval(sprintf('RTPlanAnalyzed.Item_%d.MLCPosition = MLCPosition',iter1))
end




