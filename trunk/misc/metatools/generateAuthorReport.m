function generateAuthorReport()
%% Generate the html contributing author reports

dest = fullfile(pmtk3Root(), 'docs', 'authors');
R    = pmtkTagReport(); % everything you ever wanted to know about tags
%%
pmtkRed = '#990000';
%% (1) Create a table of authors and the total lines of code contributed
fname = fullfile(dest, 'authorsLOC.html');
header = [...
    sprintf('<font align="left" style="color:%s"><h2>Contributing Authors</h2></font>\n', pmtkRed),...
    sprintf('<br>Revision Date: %s<br>\n', date()),...
    sprintf('<br>Auto-generated by generateAuthorReport.m<br>\n'),...
    sprintf('<br>\n')...
    ];
loc   = cellfuncell(@num2str, mat2cellRows(R.contribution));
ndx   = find(R.bincontrib);
for i=1:numel(ndx)
    loc{ndx(i)} = [loc{ndx(i)}, '+'];
end
colNames = {'AUTHOR'  , 'LINES OF CODE'};
htmlTable('data'      , [R.authorlist, loc]                     , ...
    'colNames'        , colNames                                , ...
    'colNameColors'   , {pmtkRed, pmtkRed}                      , ...
    'dataAlign'       , 'left'                                  , ...
    'header'          , header                                  , ...
    'caption'         , '<br>+ (binary files also contributed)' , ...
    'captionLoc'      , 'top'                                   , ...
    'captionFontSize' , 3                                       , ...
    'dosave'          , true                                    , ...
    'filename'        , fname                                   , ...
    'doshow'          , false);
%% (2) Create a table of package contributors
colNames = {'AUTHOR', 'PACKAGE NAME', 'SOURCE URL', 'DATE', 'DIRECTORY'};
fname    = fullfile(dest, 'packageAuthors.html');
packndx  = cellfun(R.filendx, R.tagmap.('PMTKtitle'))';
authors  = R.authors(packndx);
files    = R.files(packndx);
nlines   = sum(cellfun(@numel, authors));
tags     = R.tags(packndx);
tagtext  = R.tagtext(packndx);
data     = cell(nlines, length(colNames));
line     = 1;
for j=1:numel(files)
    nauth         = numel(authors{j});  % each file may have multiple authors
    directoryname = fileparts(files{j});
    directoryname = directoryname(length(pmtk3Root())+1:end);
    titlendx      = cellfind(tags{j}, 'PMTKtitle');
    if isempty(titlendx)
        title = '&nbsp;';
    else
        title = strtrim(tagtext{j}{titlendx});
    end
    urlndx = cellfind(tags{j}, 'PMTKurl');
    if isempty(urlndx)
        url =  '&nbsp;';
    else
        url = sprintf(' <a href="%s"> website ', strtrim(tagtext{j}{urlndx}));
    end
    datendx = cellfind(tags{j}, 'PMTKdate');
    if isempty(datendx)
        dateText = '&nbsp;';
    else
        dateText  = strtrim(tagtext{j}{datendx});
    end
    for k=1:nauth
        ndx = line+k-1;
        data{ndx, 1} = authors{j}{k};
        data{ndx, 2} = title;
        data{ndx, 3} = url;
        data{ndx, 4} = dateText;
        data{ndx, 5} = googleCodeLink(files{j}, directoryname);
    end
    line = line + nauth ;
end
header = [...
    sprintf('<font align="left" style="color:%s"><h2>Contributed Packages</h2></font>\n', pmtkRed),...
    sprintf('<br>Revision Date: %s<br>\n', date()),...
    sprintf('<br>Auto-generated by generateAuthorReport.m<br>\n'),...
    sprintf('<br>\n')...
    ];
perm = sortidx(cellfuncell(@(c)c{end}, cellfuncell(@(c)tokenize(c, ' '), data(:, 1))));
data = data(perm, :);
htmlTable('data'           , data           , ...
    'colNames'             , colNames       , ...
    'doSave'               , true           , ...
    'filename'             , fname          , ...
    'colNameColors'        , repmat({pmtkRed}, 1, numel(colNames)), ...
    'header'               , header         , ...
    'dataAlign'            , 'left'         , ...
    'caption', '<br> <br>' , ...
    'captionLoc', 'bottom' , ...
    'doshow', false);
%% Contributed Files
colNames   = {'AUTHOR', 'FILE NAME', 'SOURCE URL', 'DATE'};
fnameOnly  = @(m)argout(2, @fileparts, m);
fname      = fullfile(dest, 'fileAuthors.html');
packndx    = cellfun(R.filendx, R.tagmap.('PMTKtitle'))';
filendx    = setdiff(1:numel(R.files), packndx);
filenames  = R.files(filendx);
authors    = R.authors(filendx);
nlines     = sum(cellfun(@numel, authors));
tags       = R.tags(filendx);
tagtext    = R.tagtext(filendx);
data       = cell(nlines, 4);
line       = 1;
for j=1:numel(authors)
    nauth  = numel(authors{j});
    title  = googleCodeLink(filenames{j}, fnameOnly(filenames{j}));
    urlndx = cellfind(tags{j}, 'PMTKurl');
    if isempty(urlndx)
        url =  '&nbsp;';
    else
        url = sprintf(' <a href="%s"> website ',(tagtext{j}{urlndx}));
    end
    datendx = cellfind(tags{j}, 'PMTKdate');
    if isempty(datendx)
        dateText = '&nbsp;';
    else
        dateText  = strtrim(tagtext{j}{datendx});
    end
    for k=1:nauth % one line per author (not file)
        ndx = line+k-1;
        data{ndx, 1} = authors{j}{k};
        data{ndx, 2} = title;
        data{ndx, 3} = url;
        data{ndx, 4} = dateText;
    end
    line = line + nauth ;
end
%% Sort by last name
perm   = sortidx(...
    cellfuncell(@(c)c{end}, cellfuncell(@(c)tokenize(c, ' '), data(:, 1))));
data   = data(perm, :);
%%
header = [...
    sprintf('<font align="left" style="color:%s"><h2>Contributed Files</h2></font>\n', pmtkRed),...
    sprintf('<br>Revision Date: %s<br>\n', date()),...
    sprintf('<br>Auto-generated by generateAuthorReport.m<br>\n'),...
    sprintf('<br>\n')...
    ];
htmlTable('data'           , data                                  , ...
    'colNames'             , colNames                              , ...
    'doSave'               , true                                  , ...
    'filename'             , fname                                 , ...
    'colNameColors'        , {pmtkRed, pmtkRed, pmtkRed, pmtkRed}  , ...
    'header'               , header                                , ...
    'dataAlign'            , 'left'                                , ...
    'caption'              , '<br> <br>'                           , ...
    'captionLoc'           , 'bottom'                              , ...
    'doshow'               , false);
end