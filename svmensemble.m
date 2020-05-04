function   svmEnsemble = svmensemble(data,group,...
                            indexList,nEsemble,kfoldNum,p_method,kFunction,plotCond)

%% SVMs ensemble

%   Input:   data       = data for training (Rows - for samples & columns for each properties )
%                          size = nSamples x nFeatures
%            dataLabels = Names of features
%            group      = label of data with respect to condition
%            conditionLabel = Labels of two conditions.
%            indexList  = Index of selected parameters for ploting 
%            nEsemble   = Number of SVMs ensemble
%                         total numer of ensembles for k features
%                            = k(k-1)/2
%            kfoldNum   = kfold number for cross validation
%            p_method   = progamming method for ptimization (QP, SMO, or LS)
%            kFunction  = Kernel function
%            plotCond   = showing plots (for yes - true, no - false)

%   Output:  svmEnsemble= total svm structure for all ensembles (features)



%svm calculations
lng=length(data);
correctRateFeature=zeros(nEsemble,nEsemble);
noOfSvms=nEsemble*(nEsemble-1)/2; %% number of possible svms each class
svmEnsemble=cell(noOfSvms,1);
plotID=strcmpi(plotCond,'true');
% cross validation
% indices=crossvalind('Kfold',group,kfoldNum);
[train, test] = crossvalind('holdOut',group);
cp = classperf(group);
iStruct=1;
for iter=1:nEsemble
    for i_iter=iter+1:nEsemble
        for i=1:kfoldNum
%             test=(indices==i);
%             train=~test
            dataSvm=[data(:,iter),data(:,i_iter)];
            if plotID == 1
                figure;
            end

            % grid search for C and sigma 
%             [C sigma]=gridsearch(dataSvm(train,:),group(train),dataSvm(test,:),...
%                                 test,group,p_method);
             C=1; sigma=1;

            % svm trainig with optimized C and sigma
            if plotID == 1
            svmStruct = svmtrain(dataSvm(train,:),group(train),...
                'boxconstraint',C,'Kernel_Function',kFunction,'rbf_sigma',...
                sigma,'Method',p_method,'showplot',plotCond);
            else
            svmStruct = svmtrain(dataSvm(train,:),group(train),...
                'boxconstraint',C,'Kernel_Function',kFunction,'rbf_sigma',...
                sigma,'Method',p_method);
            end
            
            % SVM classification
            classes = svmclassify(svmStruct,dataSvm(test,:),'showplot',plotCond);

            % plot
            
            if plotID == 1
                set(gca,'FontSize',13)
                title(sprintf('SVMs classification for %dth validation',i))
                xlabel(sprintf('Feature no - %d:',indexList(iter,1)),'FontSize',16 );
                ylabel(sprintf('Feature no - %d:',indexList(i_iter,1)),'FontSize',16);
                labels = num2str((1:lng)','%d');  
                text(data(:,iter),data(:,i_iter),labels, ...
                    'horizontal','left', 'vertical','bottom',...
                    'FontSize',14,'FontWeight','Bold')
            end
            % classification rate
            cp=classperf(cp,classes,test);
            correctRateFeature(iter,i_iter)=cp.CorrectRate;

            % count errors
%             classes~=group(test,:)
%             errors(i)=mean(classes~=group(test,:));
        end
        svmEnsemble{iStruct}=svmStruct;
        iStruct=iStruct+1;
    end
end
% disp(['Cross validation error:',num2str(mean(errors))]);
sprintf('The correction diagnosis rate of the testing data %4f',cp.CorrectRate)
% trainingDoneMsg=msgbox({sprintf('The correction diagnosis rate of the testing data %4f',cp.CorrectRate),...
%     ' ','Training of SVM to distuinguise the fault with the normal condition'});
% waitfor(trainingDoneMsg);
