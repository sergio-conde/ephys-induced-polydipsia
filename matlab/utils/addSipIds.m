function outFileList = addSipIds(inFileList,fileType)

% outFileList = addSipIds(inFileList,fileType)
%
% addSipIds function adds:
%
% cohort_id
% animal_id
% session_id
% tet_id
% manipulation
%
% The function deals with all the variable folder and file naming
% specificaly of the SIP project.
%
%   Inputs:
%     in_list: structure containing at least one field with the session name
%       in_list(ifile).session: full name of the ifile                              [string]
%
%   Outputs:
%     out_list: Output struct containing the same fields of f_list + id fields  
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
        outFileList(ifile).cohort_id = str2double(cohort(2:end));
    else
        outFileList(ifile).cohort_id = str2double(cohort(end));
    end

    animal = outFileList(ifile).animal;
    outFileList(ifile).animal_id = str2double(animal(2:end));

    session = outFileList(ifile).session;
    if strcmp(session,'baseline1')
        outFileList(ifile).session_id = 101;
    elseif strcmp(session,'baseline2')
        outFileList(ifile).session_id = 102;
    elseif strcmp(session,'habituation')
        outFileList(ifile).session_id = 0;
    elseif strcmp(session(1:3),'sip')
        outFileList(ifile).session_id = str2double(session(4:5));
    elseif strcmp(session(1:2),'wn')
        outFileList(ifile).session_id = -1;
    end

    if isfield(inFileList,'name')
        f_name = outFileList(ifile).name;
        switch fileType
            case 'ntt'
                outFileList(ifile).tet_id = str2double(f_name(3:strfind(f_name,'.ntt') - 1));
                outFileList(ifile).file_label = f_name(1:strfind(f_name,'.ntt') - 1);
            case 'ncs'
                outFileList(ifile).tet_id = str2double(f_name(4:strfind(f_name,'.ncs') - 1));
                outFileList(ifile).file_label = f_name(1:strfind(f_name,'.ncs') - 1);
            case 'sorted'
                outFileList(ifile).tet_id = str2double(outFileList(ifile).tt(3:end));
                outFileList(ifile).file_label = f_name(1:strfind(f_name,'.mat') - 1);
            otherwise
                outFileList(ifile).file_label = f_name(1:strfind(f_name,'.mat') - 1);
        end
    end

    if isfield(inFileList,'tet')
        outFileList(ifile).tet_id = str2double(outFileList(ifile).tet(3:end));
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
