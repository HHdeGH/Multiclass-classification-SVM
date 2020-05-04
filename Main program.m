clear all
close all
clc
%%%%%%-------------------------------------------------------%%%%%%%
%%%% Enter input parameters
flag=0;
while (flag==0)
    prompt={'Enter number of total conditions = ',...
        'Total number of experiments for each conditions = ',...
        'Enter the number of samples',...
        'Enter exponent to calculate sample length (n in 2^n) = ',...
        'Enter sampling frequency'};
    num_lines = 1;
    iDef = {'3','1','50','8','4096'};
    dlg_title = 'Input data';
    dataInput=inputdlg(prompt,dlg_title,num_lines,iDef);
    nConditions=str2num(dataInput{1});
    nexperiments=str2num(dataInput{2});
    nBins=str2num(dataInput{3});
    nSamples=nBins*nexperiments;
    power_n=str2num(dataInput{4});
    sampleLength=2^power_n;
    Fs=str2num(dataInput{5}); % sampling frequency
    flag=1;
    if Fs==0
        h=error('Sampling frequency need to be entered')
        waitfor(h)
        flag=0;
    elseif str2num(dataInput{1})==1
        h=warndlg('Conditions need to be greater than 1')
        flag=0;
        waitfor(h)
    end
end
% label entering of the conditions
labelInput=cell(nConditions,1);
% for i=1:nConditions
%     dlg_title = 'Input label';
%     labelInput{i}=inputdlg(sprintf('Enter the label for %dth condition',i),dlg_title);
% end
labelInput{1}={'Normal'};
labelInput{2}={'Parallel Misalignment'};
labelInput{3}={'Angular Misalingment'};
% labelInput{1}={'At 19 Hz'};
% labelInput{2}={'At 29 Hz'};
% labelInput{3}={'At 43 Hz'};
% Input data 
for iCond=1:nConditions
    for iexp=1:nexperiments
        disp(sprintf('Open folder for "%s condition" and %dth experiment database: ',...
              cell2mat(labelInput{iCond}),iexp))
        h=msgbox(sprintf('Open folder for "%s condition" and %dth experiment database: ',...
              cell2mat(labelInput{iCond}),iexp));
        waitfor(h)
        defect_data=uiimport
        vars = fieldnames(defect_data)
        Data{iCond,iexp} = defect_data.(vars{1});
        iStart=10;
        for iBin=1:nBins
            iEnd=iStart+sampleLength-1;
            conditionData{iCond,iexp,iBin} = Data{iCond,iexp}(iStart:iEnd,:);
            iStart=iEnd+1;
        end
    end
end
%%
%a_nD is total number of data points in a signal
%b_nD is numbal of signal acquired from transducers
[a_nD b_nD]=size(conditionData{1,1,1});

%%%            Feature Selection
%---Time feature selection
timeFeatures = {'Mean','Max','Min','Range','Sum','Median','RMS',...
    'Variance','Kurtosis','Skewness','Crest factor',...
    'Shape factor'};
idx_choices = listdlg(...
    'promptstring','Select one or more features',...
    'liststring',timeFeatures,...
    'listsize',[160 160],...
    'initialvalue',[1 2 3 7 10 11]);
if isempty(idx_choices)
    h=warndlg('No choice made')
else
    idxTimeFeatures = timeFeatures(idx_choices); % a new list of just the chosen fruits
    h=msgbox(idxTimeFeatures,'Feature choices');
end
waitfor(h)
n_timeFeature=length(idxTimeFeatures);
totalFeatures= idxTimeFeatures;
% Total number of features = (time features)*no. of columns
nFeatures=(n_timeFeature)*b_nD;

%%%          Calculation of statistical features
featureAllCond=zeros(n_timeFeature,b_nD,nSamples,nConditions);
% ---Time features
for iCond=1:nConditions
    samInt=0;
    for iexp=1:nexperiments
        for iSam=1:nBins
            for iCol=1:b_nD
                featureAllCond(:,iCol,iSam+samInt,iCond)=timefeatures(conditionData{iCond,iexp,iSam}(:,iCol),...
                                            idxTimeFeatures);
            end
        end
        samInt=iexp*nBins;
    end
end

%%%                    3D Feature matrix
featureMatrix=zeros(nSamples,nFeatures,nConditions);
for iCond=1:nConditions
    for iSam=1:nSamples
        featStart=1;
        for iFeat=1:n_timeFeature
            featEnd=featStart+b_nD-1;
            featureMatrix(iSam,featStart:featEnd,iCond)=featureAllCond(iFeat,:,iSam,iCond);
            featStart=featEnd+1;
        end
    end
end

%%           Compensation Distance Evaluation Technique (CDET)
%.....Y.Lei et al., Mechanical Systems and Signal Processing 22, 2008,419-455
%....X_ucj ...ucj subscripts are according to that paper
%     calling cdet.m
[indexFeature indexList]=cdet(featureMatrix,totalFeatures,...
                                  nFeatures,nConditions,nSamples);
senFeatureMatrix=featureMatrix;
senFeatureMatrix(:,~indexFeature,:) = [];
nSenFeatures=length(indexList);
fprintf('Number of sensitive parameters among %d is %d\n',nFeatures,nSenFeatures)
disp(' ')
disp('The selected features are')
indexList
fprintf('The most sensitive feature is Feature no - %d\n', indexList(1))

% ploting of most sensitive parameter
figure
cmap =  [1     0     0
     0     1     0
     0     0     1
     0     1     1
     1     1     0
     1     0     1];
for iCond=1:nConditions
    plot(featureMatrix(:,indexList(1),iCond),featureMatrix(:,indexList(1),iCond),...
              'd','MarkerSize',8,'MarkerEdgeColor','k',...
              'MarkerFaceColor',cmap(iCond,:));
    hold on
    legendLabel(iCond,1)=strtrim(cellstr(labelInput{iCond}));
end
hold off
title('Distribution of the most sensitive feature','FontSize',16)
set(gca,'FontSize',16)
xlabel(sprintf('Feature no - %d:',indexList(1,1)),'FontSize',16 );
ylabel(sprintf('Feature no - %d:',indexList(1,1)),'FontSize',16);
legend(legendLabel{:});

% ploting of least sensitive parameter 
figure
for iCond=1:nConditions
    plot(featureMatrix(:,indexList(length(indexList)),iCond),...
         featureMatrix(:,indexList(length(indexList)),iCond),...
              'd','MarkerSize',8,'MarkerEdgeColor','k',...
              'MarkerFaceColor',cmap(iCond,:));
    hold on
    legendLabel(iCond,1)=strtrim(cellstr(labelInput{iCond}));
end
hold off
title('Distribution of the least sensitive feature','FontSize',16)
set(gca,'FontSize',16)
xlabel(sprintf('Feature no - %d:',indexList(length(indexList))),'FontSize',16 );
ylabel(sprintf('Feature no - %d:',indexList(length(indexList))),'FontSize',16);
legend(legendLabel{:});

%% ploting all graphs in a feature 
% plot for all grpahs for transducers

CondColor = [1 0 0; 0 1 0; 0 0 1];
h=zeros(3,3);
featStart=1;
for iFeat = 1:n_timeFeature
    fig=figure;
    featEnd=featStart+b_nD-1;
    for iCond =1:nConditions
        i=1;
        for iCol = featStart:featEnd
            srtExp=1;
            for iexp = 1:nexperiments
                endExp = srtExp+nBins-1;
                h(:,iCond)=plot(zeros(nBins,1)+i,featureMatrix(srtExp:endExp,iCol,iCond),...
                      '*','Color',CondColor(iCond,:));
                hold on
            end
            endExp=endExp+1;
            i=i+1;
        end
        hold on
    end
    hold off
    xlabel('Transducer number','FontSize',16)
    ylabel(sprintf('%s',cell2mat(timeFeatures(iFeat))),'FontSize',16);
     legend(h(1,:),{'Normal','Parallel Misalignment','Angular Misalignment'});
%    legend(h(1,:),{'At 19 Hz','At 29 Hz', 'At 43 Hz'})
    set(gca,'FontSize',16)
    featStart=featEnd+1;
    saveas(fig,cell2mat(timeFeatures(iFeat)),'fig')
end







