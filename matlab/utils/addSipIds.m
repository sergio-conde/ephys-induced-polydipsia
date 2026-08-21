function outFileList = addSipIds(inFileList,fileType)

% outFileList = addSipIds(inFileList,fileType)
%
% addSipIds function adds:
%
% cohortID
% animalID
% sessionID
% tetrodeID
% manipulation
%
% The function deals with all the variable folder and file naming
% specificaly of the SIP project.
%
%   Inputs:
%     inFileList: structure containing at least one field with the session name
%       inFileList(ifile).session: full name of the ifile                              [string]
%
%   Outputs:
%     outFileList: Output struct containing the same fields of f_list + ID fields  
%
% v1.0: October 2023 
% v2.0: August 2026
%
% Sergio Conde-Ocazionez.
% Neuromodulation & Behavior Laboratory
% Netherlands Institute for Neuroscience.


outFileList = inFileList;
for ifile = 1:length(outFileList)

    cohort = outFileList(ifile).cohort;
    if strcmp(cohort(1), 'u')
        outFileList(ifile).cohortID = str2double(cohort(2:end));
    else
        outFileList(ifile).cohortID = str2double(cohort(end));
    end

    animal = outFileList(ifile).animal;
    outFileList(ifile).animalID = str2double(animal(2:end));

    session = outFileList(ifile).session;
    if strcmp(session,'baseline1')
        outFileList(ifile).sessionID = 101;
    elseif strcmp(session,'baseline2')
        outFileList(ifile).sessionID = 102;
    elseif strcmp(session,'habituation')
        outFileList(ifile).sessionID = 0;
    elseif strcmp(session(1:3),'sip')
        outFileList(ifile).sessionID = str2double(session(4:5));
    elseif strcmp(session(1:2),'wn')
        outFileList(ifile).sessionID = -1;
    end

    if isfield(inFileList,'name')
        fileName = outFileList(ifile).name;
        switch fileType
            case 'ntt'
                outFileList(ifile).tetrodeID = str2double(fileName(3:strfind(fileName,'.ntt') - 1));
                outFileList(ifile).fileLabel = fileName(1:strfind(fileName,'.ntt') - 1);
                outFileList(ifile).fileType = 'spike';
            case 'ncs'
                outFileList(ifile).tetrodeID = str2double(fileName(4:strfind(fileName,'.ncs') - 1));
                outFileList(ifile).fileLabel = fileName(1:strfind(fileName,'.ncs') - 1);
                outFileList(ifile).fileType = 'lfp';
            case 'med'
                outFileList(ifile).fileType = 'medpc';
            case 'sorted'
                outFileList(ifile).tetrodeID = str2double(outFileList(ifile).tt(3:end));
                outFileList(ifile).fileLabel = fileName(1:strfind(fileName,'.mat') - 1);
            otherwise
                outFileList(ifile).fileLabel = fileName(1:strfind(fileName,'.mat') - 1);
        end
    end

    if isfield(inFileList,'tet')
        outFileList(ifile).tetrodeID = str2double(outFileList(ifile).tet(3:end));
    end

    if strcmp(session(1:4),'base') || strcmp(session,'habituation') || strcmp(session,'unknown')
        outFileList(ifile).manipulation = session;
    elseif strcmp(session(1:2),'wn')
        outFileList(ifile).manipulation = 'wn';
    else
        if length(session) > 5
            outFileList(ifile).manipulation = session(7:end);
            if strcmp(outFileList(ifile).manipulation(1:3),'dri')
                outFileList(ifile).manipulation = 'drinksluis';
            end
        else
            outFileList(ifile).manipulation = 'none';
        end
    end
end
