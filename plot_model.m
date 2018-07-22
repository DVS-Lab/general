function plot_model()
% ran this first: grep -v [A-Za-df-z] design.mat | grep [0-9] > design.mtx

maindir = pwd;
designf = fullfile(maindir,'data','design.mtx');
design = load(designf);
normed_design = design;
for i = 1:size(normed_design,2)
    normed_design(:,i) = rescale(normed_design(:,i),1,2);
end


%normed_design = design;

%y = 2*(x - min(x(:))/(max(x(:)) - min(x(:))) - 1);
%normed_design = y;
for i = 1:size(normed_design,2)
    normed_design(:,i) = normed_design(:,i) + i*1; %sets the spacing without changing variance/range
    %plot(normed_design(:,i))
end
figure,plot(normed_design)

keyboard

end


function C = rescale(A,new_min,new_max)
% rescales entire matrix. 
current_max = max(A(:));
current_min = min(A(:));
C =((A-current_min)*(new_max-new_min))/(current_max-current_min) + new_min;
end