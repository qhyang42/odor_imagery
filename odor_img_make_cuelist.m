function odor_img_make_cuelist(subID)
%%% make cuelist for inose task. 
%%% 40 trials of odor and no odor story. split into two runs. 
if ~exist([subID, '_cuelist'], "dir")
    mkdir([subID, '_cuelist']); 
end 
cat = repmat([1, 2], 20); 
cat = cat(:); 
catidx = randperm(40); 

story = repmat([1:20], 2); 
story = story(:); 
storyidx = randperm(40); 

story = story(storyidx); 
cat = cat(catidx); 

for runidx = 1:2 
    cuelist = []; 
    cuelist.story = story((runidx-1)*20+1:runidx*20); 
    cuelist.cat = cat((runidx-1)*20+1:runidx*20); 
    save(fullfile([subID, '_cuelist'], [subID, '_cuelist_', num2str(runidx)]), "cuelist"); 

end 

end 