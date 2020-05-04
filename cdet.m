function [indexFeature indexList] = cdet(featureMatrix,totalFeatures,nFeatures,nCondition,nSamples)

%%Compensation Distance Evaluation Technique (CDET)........
%.....Y.Lei et al., Mechanical Systems and Signal Processing 22, 2008,419-455
%....X_ucj ...ucj subscripts are according to that paper
%
% Input:    featureMatris = 3D feature matrix of size
%                             nSample x nFeatures x nConditions
% 
% Output:   normAlpha = normalized alpha for all features
%                       distance evaluation criterion

avgDst_dcj=zeros(nFeatures,nCondition);
avgFeature_ucj=zeros(nFeatures,nCondition);
for iCond=1:nCondition
    for iFeat=1:nFeatures
        avgDst_dcj(iFeat,iCond)=0;
        avgFeature_ucj(iFeat,iCond)=0;
        for L=1:nSamples
            for m=1:nSamples
                if L~=m
                    avgDst_dcj(iFeat,iCond)=avgDst_dcj(iFeat,iCond)+((1/nSamples*(nSamples-1))*abs(featureMatrix(m,iFeat,iCond)-featureMatrix(L,iFeat,iCond)));
                end
            end
            avgFeature_ucj(iFeat,iCond)=avgFeature_ucj(iFeat,iCond)+((1/nSamples)*featureMatrix(L,iFeat,iCond));
        end
    end
end
totalAvgDst_dwj=zeros(nFeatures,1);
totalAvgDstAllCond_dbj=zeros(nFeatures,1);
varianceDst_vjw=zeros(nFeatures,1);
varianceDst_vjb=zeros(nFeatures,1);
for iFeat=1:nFeatures
    for iCond=1:nCondition
        totalAvgDst_dwj(iFeat,1)=totalAvgDst_dwj(iFeat,1)+((1/nCondition)*avgDst_dcj(iFeat,iCond));
    end
    i=1;
    for c=1:nCondition
        for e=1:nCondition
            if c~=e
                uej_ucj(iFeat,i)=(1/(nCondition*(nCondition-1)))*abs(avgFeature_ucj(iFeat,e)-avgFeature_ucj(iFeat,c));
                totalAvgDstAllCond_dbj(iFeat,1)=totalAvgDstAllCond_dbj(iFeat,1)+uej_ucj(iFeat,i);
                i=i+1;
            end
        end
    end
    varianceDst_vjw(iFeat,1)=max(avgDst_dcj(iFeat,:))/min(avgDst_dcj(iFeat,:));
    varianceDst_vjb(iFeat,1)=max(uej_ucj(iFeat,:))/min(uej_ucj(iFeat,:));
end

compensationFactor=zeros(nFeatures,1);
maxVarianceDst_vjw=max(varianceDst_vjw);
maxVarianceDst_vjb=max(varianceDst_vjb);
for iFeat=1:nFeatures
    compensationFactor(iFeat,1)=1/((varianceDst_vjw(iFeat,1)/maxVarianceDst_vjw)+(varianceDst_vjb(iFeat,1)/maxVarianceDst_vjb));
end
alpha=zeros(nFeatures,1);
normAlpha=zeros(nFeatures,1);
for iFeat=1:nFeatures
    alpha(iFeat,1)=compensationFactor(iFeat,1)*totalAvgDstAllCond_dbj(iFeat,1)/totalAvgDst_dwj(iFeat,1);
end
maxAlpha=max(alpha);
for iFeat=1:nFeatures
    normAlpha(iFeat,1)=alpha(iFeat,1)/maxAlpha;
end

%%
whileCondition = 0;
while (whileCondition==0)
    prompt={'Enter threshold value for feature extraction (0 - 1) = '};
    num_lines = 1;
    iDef = {'0.6'};
    dlg_title = 'Input data';
    dataInput=inputdlg(prompt,dlg_title,num_lines,iDef);
    phi=str2num(dataInput{1}); %%% assume threshold value
    figure;
    plot(1:nFeatures,normAlpha,'-bp','MarkerSize',10,'MarkerFaceColor','r')
    hold on
    phiMatrix=zeros(nFeatures,1);
    for iFeat=1:nFeatures
        phiMatrix(iFeat,1)=phi;
    end
    plot(1:nFeatures,phiMatrix,'-r')
    set(gca,'FontSize',16)
    xlabel('Feature number')
    ylabel('Distance evaluation creterion')
%     text(1:nFeatures,normAlpha,totalFeatures,'horizontal','left',...
%           'vertical','Middle','Rotation',90,'FontSize',12,...
%           'FontWeight','Bold','Color','b')
%     title('Distance evaluation criteria of all features.')
    hold off
        newprompt={'Do you statisfy with the threshold value (Yes or No)'};
    num_lines = 1;
    iDef = {'Yes'};
    decision_title = 'Decision';
    dataInput=inputdlg(newprompt,decision_title,num_lines,iDef);
    whileCondition=strcmp('Yes',dataInput{1});
end
%%
%%%%----Selection of sensitive parameters
[sortNormAlpha srtIX]=sort(normAlpha,'descend');
indexFeature=(sortNormAlpha>=phi);
indexList = srtIX(indexFeature);

